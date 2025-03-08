package main

import "core:fmt"
import "core:log"
import "core:mem"
import os "core:os/os2"
import "core:strings"

import "ffmpeg/avcodec"
import "ffmpeg/avformat"
import "ffmpeg/types"
import rl "vendor:raylib"

DEFAULT_WINDOW_HEIGHT :: 600
MIN_WINDOW_HEIGHT :: 200
VOLUME_STEP :: 0.1
MAX_VOLUME :: 5.0

// Video Player state
volume: f32 = 1.0
muted := false
paused := false

// flag
quiet := false


show_usage :: #force_inline proc() {
    fmt.eprintln(
        `
USAGE: jplay [OPTIONS] <input file/url>
yt-dlp: jplay [-- [yt-dlp options]] <url>

Options:
-q  quite
`,
    )
}

main_loop :: proc(state: ^Video_State, surface: rl.Texture) {
    rl.PlayAudioStream(state.audio_stream)
    for !rl.WindowShouldClose() {
        if state.video_active {
            video_update(state, surface)
        }

        //---Events---
        if rl.IsKeyPressed(.F) {
            if rl.IsWindowMaximized() {
                rl.RestoreWindow()
            } else {
                rl.MaximizeWindow()
            }
        }
        if rl.IsKeyPressed(.UP) {
            volume = min(volume + VOLUME_STEP, MAX_VOLUME)
            rl.SetAudioStreamVolume(state.audio_stream, volume)
        } else if rl.IsKeyPressed(.DOWN) {
            volume = max(volume - VOLUME_STEP, 0)
            rl.SetAudioStreamVolume(state.audio_stream, volume)
        }

        //---Drawing---
        rl.BeginDrawing()
        rl.ClearBackground(rl.BLACK)

        // Handle Window resizing
        src := rl.Rectangle{0, 0, f32(surface.width), f32(surface.height)}
        screen_height := rl.GetScreenHeight()
        screen_width := rl.GetScreenWidth()
        height := screen_height
        width := screen_height * surface.width / surface.height
        if screen_width < width {
            width = screen_width
            height = screen_width * surface.height / surface.width
        }
        x := (screen_width - width) / 2
        y := (screen_height - height) / 2
        dst := rl.Rectangle{f32(x), f32(y), f32(width), f32(height)}

        if state.video_active {
            rl.DrawTexturePro(surface, src, dst, rl.Vector2(0), 0, rl.WHITE)
        }

        rl.EndDrawing()
    }

}

parse_args :: proc() -> (string, []string) {
    args := os.args
    if len(args) < 2 {
        show_usage()
        os.exit(1)
    }

    yt_args: []string
    if len(args) >= 3 {
        for i := 1; i < len(args) - 1; i += 1 {
            arg := args[i]

            if strings.compare(arg, "--") == 0 {
                // yt args
                yt_args = args[i + 1:len(args) - 1]
                break
            } else if strings.compare(arg, "-q") == 0 {
                // quiet
                quiet = true
            } else {
                show_usage()
                os.exit(1)
            }
        }
    }

    video_file := args[len(args) - 1]
    return video_file, yt_args
}

main :: proc() {

    video_file, yt_args := parse_args()
    min_level: log.Level = quiet ? .Error : .Info
    context.logger = log.create_console_logger(min_level, log.Options{.Level, .Terminal_Color})

    state: Video_State
    video_state_init(&state, video_file, yt_args)

    // Init raylib
    width, height := state.v_decoder.ctx.width, state.v_decoder.ctx.height
    rl.SetConfigFlags(rl.ConfigFlags{.WINDOW_RESIZABLE})
    rl.SetTraceLogLevel(.WARNING)
    rl.InitWindow(DEFAULT_WINDOW_HEIGHT * width / height, DEFAULT_WINDOW_HEIGHT, state.filename)
    rl.InitAudioDevice()
    rl.SetTargetFPS(120)

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
