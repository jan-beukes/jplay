package main

import "core:log"
import os "core:os/os2"
import "core:strings"

import "ffmpeg/avcodec"
import "ffmpeg/avformat"
import "ffmpeg/avutil"
import "ffmpeg/swresample"
import "ffmpeg/swscale"
import "ffmpeg/types"
import rl "vendor:raylib"

Format_Context :: types.Format_Context
Codec_Context :: types.Codec_Context
Codec :: types.Codec
Media_Type :: types.Media_Type
Sws_Context :: types.Sws_Context
Swr_Context :: types.Software_Resample_Context
Frame :: types.Frame
Packet :: types.Packet


Decoder :: struct {
    format_ctx: ^Format_Context,
    ctx:        ^Codec_Context,
    //frames: 
    index:      i32,
}

Video_State :: struct {
    filename:     cstring,
    v_decoder:    Decoder,
    a_decoder:    Decoder,

    // conversion
    sws_ctx:      ^Sws_Context,
    swr_ctx:      ^Swr_Context,
    out_frame:    ^Frame,
    audio_stream: rl.AudioStream,
    audio_buffer: []u8,

    // state
    is_split:     bool,
    video_active: bool,

    // clock
    duration:     f64,
    fps:          i32,
    video_clock:  i64,
    audio_clock:  i64,
}

decoder_init :: proc(decoder: ^Decoder, format_ctx: ^Format_Context, media_type: Media_Type) {

    codec: ^Codec
    ret := avformat.find_best_stream(format_ctx, media_type, -1, -1, &codec, 0)
    if ret < 0 {
        log.error("Could not find", media_type, "stream")
        os.exit(1)
    }

    decoder.index = ret
    decoder.format_ctx = format_ctx
    stream := format_ctx.streams[decoder.index]
    decoder.ctx = avcodec.alloc_context3(codec)

    if avcodec.parameters_to_context(decoder.ctx, stream.codecpar) < 0 {
        log.error("Could not create", media_type, "codec context")
        os.exit(1)
    }

    // time base and framerate
    decoder.ctx.time_base = stream.time_base
    decoder.ctx.framerate = stream.avg_frame_rate

    if media_type == .Video {
        fps := decoder.ctx.framerate.numerator / decoder.ctx.framerate.denominator
        log.infof("Video %dx%d at %dfps", decoder.ctx.width, decoder.ctx.height, fps)
    } else {
        ctx := decoder.ctx
        log.infof(
            "Audio %d channels, sample rate %dHZ, sample fmt %s",
            ctx.ch_layout.nb_channels,
            ctx.sample_rate,
            avutil.get_sample_fmt_name(ctx.sample_fmt),
        )

    }
    log.infof("Codec %s ID %d", codec.long_name, codec.id)

    if avcodec.open2(decoder.ctx, codec, nil) < 0 {
        log.error("Could not open", media_type, "codec")
        os.exit(1)
    }

}

video_conversion_init :: proc(state: ^Video_State) {

    // Pixel conversion
    format := state.v_decoder.ctx.pix_fmt
    width, height := state.v_decoder.ctx.width, state.v_decoder.ctx.height
    state.sws_ctx = swscale.getContext(
        width,
        height,
        format,
        width,
        height,
        .RGB24,
        i32(types.Software_Scale_Method_Flag.SWS_BILINEAR),
        nil,
        nil,
        nil,
    )
    if state.sws_ctx == nil {
        log.error("Failed to get sws context")
        os.exit(1)
    }

    state.out_frame = avutil.frame_alloc()
    state.out_frame.width = width
    state.out_frame.height = height
    //data: [4][^]u8
    //linesizes: [4]i32
    if (avutil.image_alloc(
               raw_data(&state.out_frame.data),
               raw_data(&state.out_frame.linesize),
               width,
               height,
               .RGB24,
               1,
           ) <
           0) {
        log.error("Failed to allocate image buffer")
        os.exit(1)
    }

    // Sample conversion
    ctx := state.a_decoder.ctx
    ret := swresample.alloc_set_opts2(
        &state.swr_ctx,
        &ctx.ch_layout,
        .FLT,
        ctx.sample_rate,
        &ctx.ch_layout,
        ctx.sample_fmt,
        ctx.sample_rate,
        0,
        nil,
    )
    if ret < 0 {
        log.error("Could not alloc swresample")
        os.exit(1)
    }
    if swresample.init(state.swr_ctx) < 0 {
        log.error("Could not init swresample")
        os.exit(1)
    }
}

video_state_init :: proc(state: ^Video_State, video_file: string, yt_args: []cstring) {

    is_url := false
    state.is_split = false
    format_ctx, format_ctx2: ^Format_Context
    state.filename = strings.clone_to_cstring(video_file)

    log.info("Loading Video")
    format_ctx = avformat.alloc_context()

    if avformat.open_input(&format_ctx, state.filename, nil, nil) != 0 {
        log.error("Could not open video file", video_file)
        os.exit(1)
    }
    if avformat.find_stream_info(format_ctx, nil) < 0 {
        log.error("Could not find stream info")
        os.exit(1)
    }
    format_ctx2 = format_ctx

    split_str := state.is_split ? "| split stream" : ""
    log.info("Format", format_ctx.input_format.long_name, split_str)

    // Packets

    // Decoders
    decoder_init(&state.v_decoder, format_ctx, .Video)
    decoder_init(&state.a_decoder, format_ctx2, .Audio)

    // extract fps and duration
    framerate := state.v_decoder.ctx.framerate
    state.fps = framerate.numerator / framerate.denominator
    state.duration = f64(state.v_decoder.format_ctx.duration) / f64(types.TIME_BASE)

    video_conversion_init(state)
}

video_state_deinit :: proc() {

}


audio_init :: proc() {

}
