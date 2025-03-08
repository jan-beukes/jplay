package main

import "core:fmt"
import "core:log"
import os "core:os/os2"

import "ffmpeg/avcodec"
import "ffmpeg/avformat"
import "ffmpeg/types"
import rl "vendor:raylib"

DEFAULT_WINDOW_HEIGHT :: 600

volume: f32 = 1.0
muted := false
paused := false

show_usage :: proc() {

}

main_loop :: proc(state: ^Video_State, surface: rl.Texture) {
    rl.PlayAudioStream(state.audio_stream)
    for !rl.WindowShouldClose() {
        if state.video_active {
            video_update(state, surface)
        }

        //---Events---

        rl.BeginDrawing()
        rl.ClearBackground(rl.RED)

        if state.video_active {
            rl.DrawTexture(surface, 0, 0, rl.WHITE)
        }

        rl.EndDrawing()
    }

}

parse_args :: proc() -> (string, []string) {
    args := os.args

    return "puss.webm", nil
}

main :: proc() {
    context.logger = log.create_console_logger(opt = log.Options{.Level, .Terminal_Color})

    video_file, yt_args := parse_args()

    state: Video_State
    video_state_init(&state, video_file, yt_args)

    // Init raylib
    width, height := state.v_decoder.ctx.width, state.v_decoder.ctx.height
    rl.SetConfigFlags(rl.ConfigFlags{.WINDOW_RESIZABLE})
    rl.SetTraceLogLevel(.WARNING)
    rl.InitWindow(DEFAULT_WINDOW_HEIGHT * width / height, DEFAULT_WINDOW_HEIGHT, state.filename)
    rl.InitAudioDevice()

    img := rl.Image {
        width   = state.v_decoder.ctx.width,
        height  = state.v_decoder.ctx.height,
        mipmaps = 1,
        format  = .UNCOMPRESSED_R8G8B8,
    }
    surface := rl.LoadTextureFromImage(img)
    rl.SetTextureFilter(surface, .BILINEAR)

    // Audio
    audio_init(&state)
    rl.SetAudioStreamVolume(state.audio_stream, volume)

    main_loop(&state, surface)

    rl.CloseWindow()
    rl.CloseAudioDevice()
    video_state_deinit(&state)
}
