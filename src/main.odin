package main

import "core:fmt"
import "core:log"
import os "core:os/os2"

import "ffmpeg/avcodec"
import "ffmpeg/avformat"
import "ffmpeg/types"
import rl "vendor:raylib"

DEFAULT_WINDOW_HEIGHT :: 600

main :: proc() {
    context.logger = log.create_console_logger(opt = log.Options{.Level, .Terminal_Color})

    video_file: string = "puss.webm"

    state: Video_State
    video_state_init(&state, video_file, nil)

    rl.SetConfigFlags(rl.ConfigFlags{.WINDOW_RESIZABLE})
    rl.SetTraceLogLevel(.WARNING)
    rl.InitWindow(DEFAULT_WINDOW_HEIGHT, DEFAULT_WINDOW_HEIGHT, state.filename)
    for !rl.WindowShouldClose() {

        rl.BeginDrawing()
        rl.ClearBackground(rl.RED)
        rl.EndDrawing()
    }

}
