package main

import "core:fmt"
import "core:log"
import "core:mem"
import os "core:os/os2"
import "core:slice"
import "core:strings"
import "core:sync"
import "core:thread"

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

av_error :: avutil.av_error


Decoder :: struct {
    format_ctx: ^Format_Context,
    ctx:        ^Codec_Context,
    frames:     Queue(^Frame),
    index:      i32,
    active:     bool,
}

Video_State :: struct {
    filename:     cstring,
    v_decoder:    Decoder,
    a_decoder:    Decoder,

    // packets
    packets:      Queue(^Packet),
    packets2:     Queue(^Packet),

    // conversion
    sws_ctx:      ^Sws_Context,
    swr_ctx:      ^Swr_Context,
    out_frame:    ^Frame,
    audio_stream: rl.AudioStream,
    audio_buffer: []u8,

    // state
    is_split:     bool,
    video_active: bool,
    io_active:    bool,

    // clock
    duration:     f64,
    fps:          i32,
    video_clock:  i64,
    audio_clock:  i64,
}

// The io thread
io_thread_func :: proc(state: ^Video_State) {
    state.io_active = true
    done: bool
    ret: i32

    for {
        if rl.IsWindowReady() && rl.WindowShouldClose() do break

        if !queue_full(&state.packets) {
            packet := queue_back(&state.packets)
            ret = avformat.read_frame(state.v_decoder.format_ctx, packet)
            if av_error(ret) == .EOF {
                done = true
            } else if ret < 0 {
                log.warn("reading frame,", av_error(ret))
            } else {
                queue_inc(&state.packets)
            }
        }
        // split stream
        if state.is_split {
            if queue_full(&state.packets2) do continue
            packet := queue_back(&state.packets2)
            ret = avformat.read_frame(state.a_decoder.format_ctx, packet)
            if av_error(ret) == .EOF && done {
                break
            } else if ret < 0 && av_error(ret) != .EOF {
                log.warn("Reading audio frame,", av_error(ret))
            } else {
                queue_inc(&state.packets2)
            }
        } else if done {
            break
        }
    }
    state.io_active = false
}

decode :: proc(packet: ^Packet, decoder: ^Decoder) -> bool {
    ret: i32
    ret = avcodec.send_packet(decoder.ctx, packet)
    err := av_error(ret)
    if err == .EAGAIN {
        return false
    } else if ret != 0 && err != .EOF {
        log.warn("Sending packet,", err)
        return false
    }

    frame := queue_back(&decoder.frames)
    for !queue_full(&decoder.frames) {
        ret = avcodec.receive_frame(decoder.ctx, frame)
        if ret != 0 do break
        queue_inc(&decoder.frames)
        frame = queue_back(&decoder.frames)
    }
    err = av_error(ret)
    if err == .EOF {
        return true
    } else if ret < 0 && err != .EAGAIN {
        log.warn("Receiving frame,", err)
    }

    return false
}

// The decoder thread
decode_thread_func :: proc(state: ^Video_State) {
    state.v_decoder.active = true
    state.a_decoder.active = true

    v_frames := &state.v_decoder.frames
    a_frames := &state.a_decoder.frames
    for state.v_decoder.active && state.a_decoder.active {
        if rl.IsWindowReady() && rl.WindowShouldClose() do break

        if !queue_empty(&state.packets) {
            packet := queue_peek(&state.packets)
            if packet.stream_index == state.v_decoder.index {
                if !queue_full(v_frames) {
                    packet = dequeue(&state.packets)
                    done := decode(packet, &state.v_decoder)
                    state.v_decoder.active = !done
                }
            } else if !state.is_split && packet.stream_index == state.a_decoder.index {
                if (!queue_full(a_frames)) {
                    packet = dequeue(&state.packets)
                    done := decode(packet, &state.a_decoder)
                    state.a_decoder.active = !done
                }
            }
        } else if !state.io_active {
            // No more packets
            state.v_decoder.active = false
            state.a_decoder.active = false
            log.info("Decoding Done!")
        }

        // for split streaming
        if state.is_split {
            if !queue_empty(&state.packets2) && !queue_full(a_frames) {
                packet := dequeue(&state.packets2)
                decode(packet, &state.a_decoder)
            }
        }
    }
}

// update the audio stream and surface with new video data
video_update :: proc(state: ^Video_State, surface: rl.Texture) {

    v_frames := &state.v_decoder.frames
    a_frames := &state.a_decoder.frames

    // Video finished
    decoding_active := state.a_decoder.active && state.v_decoder.active
    if !decoding_active && queue_empty(v_frames) {
        state.video_active = false
        return
    }

    //log.info(
    //    queue_size(&state.packets),
    //    queue_size(&state.packets2),
    //    queue_size(v_frames),
    //    queue_size(a_frames),
    //)

    // Audio
    if !queue_empty(a_frames) && rl.IsAudioStreamProcessed(state.audio_stream) {
        frame := dequeue(a_frames)

        assert(state.audio_buffer != nil)
        ptr := raw_data(state.audio_buffer)
        swresample.convert(
            state.swr_ctx,
            &ptr,
            i32(len(state.audio_buffer)),
            raw_data(frame.data[:]),
            frame.nb_samples,
        )

        state.audio_clock += i64(frame.nb_samples)
        rl.UpdateAudioStream(state.audio_stream, raw_data(state.audio_buffer), frame.nb_samples)
        avutil.frame_unref(frame)
    }
    // Video
    if !queue_empty(v_frames) {
        sync.mutex_lock(&v_frames.mutex)
        frame := queue_peek_no_lock(v_frames)
        next_ts := f64(frame.pts) * avutil.q2d(state.v_decoder.ctx.time_base)
        audio_time := f64(state.audio_clock) / f64(state.audio_stream.sampleRate)

        if audio_time >= next_ts {
            state.video_clock = frame.pts
            dequeue_no_lock(v_frames)

            // convert to rgb
            if frame.data[0] == nil {
                log.error("Null Frame")
                os.exit(1)
            }
            ret := swscale.scale_frame(state.sws_ctx, state.out_frame, frame)
            rl.UpdateTexture(surface, state.out_frame.data[0])
            avutil.frame_unref(frame)
        }
        sync.mutex_unlock(&v_frames.mutex)
    }

}

// use yt-dlp to get the urls of video/*audio stream and open the format
DEFAULT_ARGS :: []string{"-f", "b*[height<=1080]+ba"}
get_yt_format :: proc(
    video_file: string,
    yt_args: []string,
    is_split: ^bool,
) -> (
    ^Format_Context,
    ^Format_Context,
) {
    log.info("Fetching youtube stream")
    args := yt_args == nil ? DEFAULT_ARGS : yt_args

    // need to keep space for yt-dlp, --get-url and video_file in the cmd
    cmd := make([]string, len(args) + 3, context.temp_allocator)
    defer delete(cmd)
    size := len(cmd)
    cmd[0] = "yt-dlp"
    copy_slice(cmd[1:], args)
    cmd[size - 2] = "--get-url"
    cmd[size - 1] = video_file

    desc := os.Process_Desc {
        command = cmd,
    }

    state, stdout, stderr, err := os.process_exec(desc, context.temp_allocator)

    if err != nil {
        log.error("Could not run yt-dlp:", os.error_string(err))
        os.exit(1)
    } else if state.exit_code != 0 {
        fmt.eprintln(string(stderr))
    }

    files := strings.split_lines(string(stdout), context.temp_allocator)
    is_split^ = len(files) > 1

    video := strings.clone_to_cstring(files[0], context.temp_allocator)

    format_ctx, format_ctx2: ^Format_Context
    format_ctx = avformat.alloc_context()
    if avformat.open_input(&format_ctx, video, nil, nil) != 0 {
        log.error("Could not open video file", video)
        os.exit(1)
    }
    if avformat.find_stream_info(format_ctx, nil) < 0 {
        log.error("Could not find stream info")
        os.exit(1)
    }
    if is_split^ {
        audio := strings.clone_to_cstring(files[1], context.temp_allocator)
        format_ctx2 = avformat.alloc_context()
        if avformat.open_input(&format_ctx2, audio, nil, nil) != 0 {
            log.error("Could not open audio file", audio)
            os.exit(1)
        }
        if avformat.find_stream_info(format_ctx2, nil) < 0 {
            log.error("Could not find audio stream info")
            os.exit(1)
        }
    } else {
        format_ctx2 = format_ctx
    }
    free_all(context.temp_allocator)
    return format_ctx, format_ctx2
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

    queue_init(&decoder.frames)
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
        1,
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
    state.out_frame.format.video = .RGB24
    if (avutil.image_alloc(
               raw_data(state.out_frame.data[:]),
               raw_data(state.out_frame.linesize[:]),
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
    if swresample.init(state.swr_ctx) != 0 {
        log.error("Could not init swresample")
        os.exit(1)
    }
}

YT_DOMAINS :: []string{"https://www.youtu", "https://youtu", "youtu"}
video_state_init :: proc(state: ^Video_State, video_file: string, yt_args: []string) {
    avutil.log_set_level(.ERROR)
    state.filename = strings.clone_to_cstring(video_file)
    format_ctx, format_ctx2: ^Format_Context
    // check for youtube domain
    is_url := false
    for domain in YT_DOMAINS {
        if strings.starts_with(video_file, domain) {
            is_url = true
        }
    }
    if is_url {
        format_ctx, format_ctx2 = get_yt_format(video_file, yt_args, &state.is_split)
    } else {
        state.is_split = false
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
    }

    split_str := state.is_split ? "| split stream" : ""
    log.info("Format", format_ctx.input_format.long_name, split_str)

    // Packets
    queue_init(&state.packets)
    if state.is_split do queue_init(&state.packets2)

    // Decoders
    decoder_init(&state.v_decoder, format_ctx, .Video)
    decoder_init(&state.a_decoder, format_ctx2, .Audio)

    // extract fps and duration
    framerate := state.v_decoder.ctx.framerate
    state.fps = framerate.numerator / framerate.denominator
    state.duration = f64(state.v_decoder.format_ctx.duration) / f64(types.TIME_BASE)

    video_conversion_init(state)

    // spawn threads
    thread.run_with_poly_data(state, io_thread_func, context)
    thread.run_with_poly_data(state, decode_thread_func, context)
    state.video_active = true
}

video_state_deinit :: proc(state: ^Video_State) {
    // free queues
    queue_deinit(&state.packets)
    queue_deinit(&state.v_decoder.frames)
    queue_deinit(&state.a_decoder.frames)

    avutil.frame_free(&state.out_frame)
    avcodec.free_context(&state.v_decoder.ctx)
    avcodec.free_context(&state.a_decoder.ctx)

    avformat.free_context(state.v_decoder.format_ctx)
    if state.is_split {
        queue_deinit(&state.packets2)
        avformat.free_context(state.a_decoder.format_ctx)
    }

    swscale.freeContext(state.sws_ctx)
    swresample.close(state.swr_ctx)
    swresample.free(&state.swr_ctx)
    if state.audio_buffer != nil {
        delete(state.audio_buffer)
        state.audio_buffer = nil
    }
}

SAMPLE_SIZE :: 32
audio_init :: proc(state: ^Video_State) {
    // Because of buffer filling issues when frame size is unknown
    // we scan the frames for a good value
    sample_count := state.a_decoder.ctx.frame_size
    a_frames := &state.a_decoder.frames
    if sample_count == 0 {
        // make sure we have some frames
        for queue_size(a_frames) < 10 {}
        for i := a_frames.rindex; i < a_frames.windex; i += 1 {
            frame := a_frames.items[i]
            sample_count = max(sample_count, frame.nb_samples)
        }
    }
    assert(sample_count != 0)

    rl.SetAudioStreamBufferSizeDefault(sample_count)
    ctx := state.a_decoder.ctx
    state.audio_stream = rl.LoadAudioStream(
        u32(ctx.sample_rate),
        SAMPLE_SIZE,
        u32(ctx.ch_layout.nb_channels),
    )

    // DDUDUUDUDUDE
    buffer_size := sample_count * ctx.ch_layout.nb_channels * SAMPLE_SIZE
    state.audio_buffer = make([]u8, buffer_size)
}
