const std = @import("std");
const rl = @import("raylib");
const c = @import("c.zig");

const info = std.log.info;
const warn = std.log.warn;
const err = std.log.err;

const Queue = @import("queue.zig").Queue;

fn ioThreadFunc(state: *VideoState) void {
    _ = state;
}

fn decodeThreadFunc(state: *VideoState) void {
    _ = state;
}

pub const VideoState = struct {
    allocator: std.mem.Allocator = undefined,

    v_decoder: VideoDecoder,
    a_decoder: AudioDecoder,

    // seperate packets to handle split streams
    packets: Queue(*c.AVPacket),
    packets2: ?Queue(*c.AVPacket) = null,

    // output
    out_frame: *c.AVFrame,
    audio_stream: ?rl.AudioStream = null,
    audio_buffer: ?[]u8 = null,

    is_split: bool = false,
    video_active: bool = false,

    duration: f64 = 0,
    video_clock: i64 = 0,
    audio_clock: i64 = 0,

    pub fn initAudio(self: *VideoState, alloc: std.mem.Allocator) void {
        self.allocator = alloc;
    }

    pub fn beginVideo(self: *VideoState) void {
        self.v_decoder.active = true;
        self.a_decoder.active = true;
        self.video_active = true;

        // Threads
    }

    fn initYtFormat(url: [:0]u8, yt_args: ?[][:0]u8) [2]?*c.AVFormatContext {
        //
        _ = url;
        _ = yt_args;
    }

    const yt_domains = [_][:0]const u8{ "https://www.youtu", "https://youtu", "youtu" };
    // initializes the video context from the given input file/url
    pub fn initVideo(video_file: [:0]u8, yt_args: ?[][:0]u8) VideoState {
        c.av_log_set_level(c.AV_LOG_ERROR);

        const is_yt_url = blk: {
            for (yt_domains) |domain| {
                const len = @min(domain.len, video_file.len);
                if (std.mem.eql(u8, video_file[0..len], domain))
                    break :blk true;
            }
            break :blk false;
        };

        var format_ctx: ?*c.AVFormatContext = undefined;
        var format_ctx2: ?*c.AVFormatContext = undefined;
        var is_split = false;
        if (is_yt_url) {
            // TODO: implement
            _ = yt_args;
            is_split = true;
        } else {
            info("Loading Video", .{});
            format_ctx = c.avformat_alloc_context();
            // open video file and read into format
            if (c.avformat_open_input(&format_ctx, video_file, null, null) != 0) {
                err("Could not open video file {s}", .{video_file});
                std.process.exit(1);
            }
            if (c.avformat_find_stream_info(format_ctx, null) < 0) {
                err("Could not find stream info", .{});
                std.process.exit(1);
            }
            // Video and audio are 'muxed'
            format_ctx2 = format_ctx;
        }
        const split_text = if (is_split) "| split stream" else "";
        info("Format {s}{s}", .{ format_ctx.?.iformat.*.long_name, split_text });

        const duration = @as(f32, @floatFromInt(format_ctx.?.duration)) /
            @as(f32, @floatFromInt(c.AV_TIME_BASE));

        const packets = Queue(*c.AVPacket).init();
        const packets2 = if (is_split) Queue(*c.AVPacket).init() else null;

        const v_decoder = VideoDecoder.init(format_ctx.?);
        const a_decoder = AudioDecoder.init(format_ctx.?);

        const out_frame: *c.AVFrame = c.av_frame_alloc();
        out_frame.width = v_decoder.ctx.width;
        out_frame.height = v_decoder.ctx.height;
        if (c.av_image_alloc(
            &out_frame.data,
            &out_frame.linesize,
            out_frame.width,
            out_frame.height,
            c.AV_PIX_FMT_RGB24,
            1,
        ) < 0) {
            err("Failed to allocate image buffer", .{});
            std.process.exit(1);
        }

        return VideoState{
            .v_decoder = v_decoder,
            .a_decoder = a_decoder,
            .packets = packets,
            .packets2 = packets2,
            .out_frame = out_frame,
            .duration = duration,
        };
    }

    pub fn deinit(self: *VideoState) void {
        // free queues

        c.avcodec_free_context(self.v_decoder.ctx);
        c.avcodec_free_context(self.a_decoder.ctx);
        c.avformat_free_context(self.v_decoder.format_ctx);
        if (self.is_split) {
            c.avformat_free_context(self.a_decoder.format_ctx);
        }
        c.sws_freeContext(self.v_decoder.sws_ctx);
        c.swr_close(self.a_decoder.swr_ctx);
        c.swr_free(&self.a_decoder.swr_ctx);
        if (self.audio_buffer) |buffer|
            self.allocator.free(buffer);
        self.audio_buffer = null;
    }

    pub fn update(state: *VideoState) void {
        _ = state;
    }
};

const VideoDecoder = struct {
    format_ctx: *c.AVFormatContext,
    ctx: *c.AVCodecContext,
    sws_ctx: *c.SwsContext,
    frames: Queue(*c.AVFrame),
    index: i32,
    fps: i32,
    active: bool = false,

    fn init(format_ctx: *c.AVFormatContext) VideoDecoder {
        var ret: i32 = 0;
        var codec: [*c]const c.AVCodec = undefined;

        ret = c.av_find_best_stream(format_ctx, c.AVMEDIA_TYPE_VIDEO, -1, -1, &codec, 0);
        if (ret < 0) {
            err("Could not find a video stream", .{});
            std.process.exit(1);
        }
        const index = ret;
        const ctx: *c.AVCodecContext = c.avcodec_alloc_context3(codec);
        const stream = format_ctx.streams[@intCast(index)];

        if (c.avcodec_parameters_to_context(ctx, stream.*.codecpar) < 0) {
            err("Could not create a video context", .{});
            std.process.exit(1);
        }

        // fps and time base
        const framerate = stream.*.avg_frame_rate;
        const fps = @divTrunc(framerate.num, framerate.den);
        ctx.*.time_base = stream.*.time_base;

        info("Video {}x{} at {}fps", .{ ctx.width, ctx.height, fps });
        info("Codec {s} ID {}", .{ codec.*.long_name, codec.*.id });

        // scaling context
        const format = ctx.pix_fmt;
        const vid_width = ctx.width;
        const vid_height = ctx.height;
        const sws_ctx = c.sws_getContext(vid_width, vid_height, format, vid_width, vid_height, c.AV_PIX_FMT_RGB24, c.SWS_BILINEAR, null, null, null);
        if (sws_ctx == null) {
            err("Failed to get sws context", .{});
            std.process.exit(1);
        }

        // open codec
        if (c.avcodec_open2(ctx, codec, null) < 0) {
            err("Could not open video codec", .{});
        }

        return VideoDecoder{
            .format_ctx = format_ctx,
            .ctx = ctx,
            .sws_ctx = sws_ctx.?,
            .index = index,
            .frames = Queue(*c.AVFrame).init(),
            .fps = fps,
        };
    }

    fn decode(packet: *c.AVPacket) void {
        _ = packet;
    }

    fn convert(frame: *c.AVFrame, out_frame: *c.AVFrame) void {
        _ = frame;
        _ = out_frame;
    }
};

const AudioDecoder = struct {
    format_ctx: *c.AVFormatContext,
    ctx: *c.AVCodecContext,
    swr_ctx: *c.SwrContext,
    frames: Queue(*c.AVFrame),
    index: i32,
    active: bool = false,

    fn init(format_ctx: *c.AVFormatContext) AudioDecoder {
        var ret: i32 = 0;
        var codec: [*c]const c.AVCodec = undefined;

        ret = c.av_find_best_stream(format_ctx, c.AVMEDIA_TYPE_AUDIO, -1, -1, &codec, 0);
        if (ret < 0) {
            err("Could not find a audio stream", .{});
            std.process.exit(1);
        }
        const index = ret;
        const ctx: *c.AVCodecContext = c.avcodec_alloc_context3(codec);
        const stream = format_ctx.streams[@intCast(index)];

        if (c.avcodec_parameters_to_context(ctx, stream.*.codecpar) < 0) {
            err("Could not create a audio context", .{});
            std.process.exit(1);
        }

        info("Audio {} chanels, sample rate {}HZ, sample fmt {s}", .{
            ctx.ch_layout.nb_channels,
            ctx.sample_rate,
            c.av_get_sample_fmt_name(ctx.sample_fmt),
        });
        info("Codec {s} ID {}", .{ codec.*.long_name, codec.*.id });

        // init sample conversion
        var swr_ctx: ?*c.SwrContext = null;

        ret = c.swr_alloc_set_opts2(
            &swr_ctx,
            &ctx.ch_layout,
            c.AV_SAMPLE_FMT_FLT,
            ctx.sample_rate,
            &ctx.ch_layout,
            ctx.sample_fmt,
            ctx.sample_rate,
            0,
            null,
        );
        if (ret < 0) {
            err("Could not alloc swresample", .{});
            std.process.exit(1);
        }
        _ = c.swr_init(swr_ctx);

        // open codec
        if (c.avcodec_open2(ctx, codec, null) < 0) {
            err("Could not open audio codec", .{});
        }

        return AudioDecoder{
            .format_ctx = format_ctx,
            .ctx = ctx,
            .swr_ctx = swr_ctx.?,
            .index = index,
            .frames = Queue(*c.AVFrame).init(),
        };
    }

    fn decode(packet: *c.AVPacket) void {
        _ = packet;
    }

    fn convert(frame: *c.AVFrame, audio_buffer: []u8) void {
        _ = frame;
        _ = audio_buffer;
    }
};
