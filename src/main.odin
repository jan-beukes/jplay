package main

import "core:c/libc"
import "core:fmt"
import "core:log"
import "core:mem"
import os "core:os/os2"
import "core:strings"

import rl "vendor:raylib"

Mouse_Focus :: enum {
    NONE,
    AUDIO,
}

DEFAULT_WINDOW_HEIGHT :: 600
MIN_WINDOW_HEIGHT :: 200
VOLUME_STEP: f32 : 0.1
MAX_VOLUME: f32 : 3.0

// Video Player state
volume: f32 = 1.0
muted := false
buffering := false
paused := false
mouse_focus: Mouse_Focus = .NONE


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

get_time_cstring :: proc(buf: []u8, seconds: int) -> cstring {
    if (seconds < 60 * 60) {
        s := seconds % 60
        m := seconds / 60
        libc.snprintf(raw_data(buf), len(buf), "%02d:%02d", m, s)
        return cstring(raw_data(buf))
    } else {
        s := seconds % 60
        m := seconds / 60
        h := seconds / (60 * 60) % 60
        libc.snprintf(raw_data(buf), len(buf), "%02d:%02d:%02d", h, m, s)
        return cstring(raw_data(buf))
    }
}

// ui
// scales based screen render rect
PAUSE_SCALE: f32 : 0.1
TIME_FONT_SCALE: f32 : 0.03
VOLUME_BAR_SCALE: f32 : 0.1

ROUNDNESS :: 0.4
CURVE_RES :: 20

handle_ui :: proc(state: ^Video_State, rect: rl.Rectangle) {

    screen_width, screen_height := rl.GetScreenWidth(), rl.GetScreenHeight()

    font_size := rect.height * TIME_FONT_SCALE
    faded_black := rl.Color{0, 0, 0, 100}

    //---Time---
    padding := font_size * 0.2
    current_time := int(state.audio_clock) / int(state.audio_stream.sampleRate)
    current_buf, duration_buf: [128]u8
    time_str := get_time_cstring(current_buf[:], current_time)
    duration_str := get_time_cstring(duration_buf[:], int(state.duration))
    text := rl.TextFormat("%s/%s", time_str, duration_str)
    text_width := f32(rl.MeasureText(text, i32(font_size)))

    bottom := rect.y + rect.height
    right := rect.x + rect.width
    time_rect := rl.Rectangle {
        x      = right - text_width - 2 * padding,
        y      = bottom - font_size - padding,
        width  = text_width + 2 * padding,
        height = font_size + 2 * padding,
    }
    rl.DrawRectangleRounded(time_rect, ROUNDNESS, CURVE_RES, faded_black)
    rl.DrawText(
        text,
        i32(right - text_width - padding),
        i32(bottom - font_size),
        i32(font_size),
        rl.RAYWHITE,
    )

    //---Volume---
    max_width := rect.width * VOLUME_BAR_SCALE + 2 * padding
    volume_bar := rl.Rectangle{rect.x, bottom - font_size, max_width, font_size}

    mouse_pos := rl.GetMousePosition()
    hover_volume: f32

    // mouse select
    if rl.CheckCollisionPointRec(mouse_pos, volume_bar) {
        mouse_focus = .AUDIO
        rl.SetMouseCursor(.POINTING_HAND)
        hover_volume = MAX_VOLUME * (mouse_pos.x - volume_bar.x) / max_width
        if rl.IsMouseButtonDown(.LEFT) {
            volume = hover_volume
            muted = false
            rl.SetAudioStreamVolume(state.audio_stream, volume)
        }
    } else {
        rl.SetMouseCursor(.DEFAULT)
        mouse_focus = .NONE
    }

    // Render
    inner_max_width := (max_width - 2 * padding)
    rl.DrawRectangleRounded(volume_bar, ROUNDNESS, CURVE_RES, faded_black)
    volume_bar = rl.Rectangle {
        x      = rect.x + padding,
        y      = bottom - font_size + padding,
        width  = (volume / MAX_VOLUME) * inner_max_width,
        height = font_size - 2.0 * padding,
    }
    if mouse_focus == .AUDIO && !muted {
        hover_bar := volume_bar
        faded_gray := rl.Color{200, 200, 200, 50}
        hover_bar.width = (hover_volume / MAX_VOLUME) * inner_max_width
        rl.DrawRectangleRounded(hover_bar, ROUNDNESS, CURVE_RES, faded_gray)
    }
    color := muted ? rl.GRAY : rl.RAYWHITE
    rl.DrawRectangleRounded(volume_bar, ROUNDNESS, CURVE_RES, color)

    // Pause
    if paused {
        pause_height := i32(rect.height * PAUSE_SCALE)
        pause_width := i32(f32(pause_height) * 0.25)
        y := (screen_height - pause_height) / 2
        x := screen_width / 2 - 2 * pause_width
        rl.DrawRectangle(x, y, pause_width, pause_height, rl.RAYWHITE)
        rl.DrawRectangleLines(x, y, pause_width, pause_height, rl.BLACK)
        x += 2 * pause_width
        rl.DrawRectangle(x, y, pause_width, pause_height, rl.RAYWHITE)
        rl.DrawRectangleLines(x, y, pause_width, pause_height, rl.BLACK)
    }

    // buffering :)
    if buffering {
        size := rect.height * PAUSE_SCALE
        time := rl.GetTime()
        start_angle := f32((time - f64(int(time))) * 360)
        end_angle := f32(start_angle + 270)
        center := rl.Vector2{(rect.x + rect.width) / 2, (rect.y + rect.height) / 2}
        rl.DrawRing(center, size, size - 0.1 * size, start_angle, end_angle, 20, rl.RED)
    }
}

main_loop :: proc(state: ^Video_State, surface: rl.Texture) {
    rl.PlayAudioStream(state.audio_stream)
    for !rl.WindowShouldClose() {

        if state.video_active && !paused && !buffering {
            video_update(state, surface)
        }

        // buffering for split youtube steams
        if !buffering && state.is_split && queue_empty(&state.packets2) {
            buffering = true
        } else if buffering && queue_full(&state.packets2) {
            buffering = false
        }

        //---Events---
        if rl.IsKeyPressed(.SPACE) || mouse_focus == .NONE && rl.IsMouseButtonPressed(.LEFT) {
            paused = !paused
        }
        // maximize
        if rl.IsKeyPressed(.F) {
            if rl.IsWindowMaximized() {
                rl.RestoreWindow()
            } else {
                rl.MaximizeWindow()
            }
        }
        // Volume
        scroll := rl.GetMouseWheelMoveV().y
        if rl.IsKeyPressed(.UP) || scroll > 0.0 {
            if !muted {
                step := scroll != 0.0 ? VOLUME_STEP : VOLUME_STEP * 2.0
                volume = min(volume + step, MAX_VOLUME)
                rl.SetAudioStreamVolume(state.audio_stream, volume)
            }
        } else if rl.IsKeyPressed(.DOWN) || scroll < 0.0 {
            if !muted {
                step := scroll != 0.0 ? VOLUME_STEP : VOLUME_STEP * 2.0
                volume = max(volume - step, 0)
                rl.SetAudioStreamVolume(state.audio_stream, volume)
            }
        }
        if rl.IsKeyPressed(.M) {
            if muted {
                rl.SetAudioStreamVolume(state.audio_stream, volume)
            } else {
                rl.SetAudioStreamVolume(state.audio_stream, 0.0)
            }
            muted = !muted
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

        handle_ui(state, dst)

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
            } else if strings.compare(arg, "-m") == 0 {
                muted = true
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
    rl.SetWindowMinSize(MIN_WINDOW_HEIGHT * width / height, MIN_WINDOW_HEIGHT)
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
    if muted {
        rl.SetAudioStreamVolume(state.audio_stream, 0.0)
    } else {
        rl.SetAudioStreamVolume(state.audio_stream, volume)
    }

    main_loop(&state, surface)

    rl.CloseWindow()
    rl.CloseAudioDevice()
    video_state_deinit(&state)
}
