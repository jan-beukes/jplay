package jplay

import "core:fmt"
import "core:log"
import os "core:os/os2"

import "ffmpeg/avcodec"
import "ffmpeg/avformat"
import "ffmpeg/types"
import rl "vendor:raylib"


main :: proc() {
    context.logger = log.create_console_logger(opt = log.Options{.Level, .Terminal_Color})

    video_file: cstring = "puss.webm"
    format_ctx := avformat.alloc_context()
    avformat.open_input(&format_ctx, video_file, nil, nil)
    avformat.find_stream_info(format_ctx, nil)

    params := format_ctx.streams[0].codecpar
    codec: ^types.Codec
    ret := avformat.find_best_stream(format_ctx, .Video, -1, -1, &codec, 0)

    ctx := avcodec.alloc_context3(codec)
    avcodec.parameters_to_context(ctx, params)

    log.info(ctx.width, ctx.height, ctx.pix_fmt)
}
