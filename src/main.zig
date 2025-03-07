const std = @import("std");
const rl = @import("raylib");
const video = @import("video.zig");
const c = @import("c.zig");

const VideoState = video.VideoState;
const print = std.debug.print;
const exit = std.process.exit;
const info = std.log.info;
const err = std.log.err;

const default_window_height = 600;

// Video Player state
var paused = false;
var muted = false;
var volume: f32 = 1.0;

fn showUsage() void {
    print(
        \\USAGE: jplay [OPTIONS] <input file/url>
        \\yt-dlp: jplay [-- [yt-dlp options]] <url>
        \\Options:
        \\
        \\-q    quite
        \\
    , .{});
}

fn mainLoop(state: *VideoState, surface: rl.Texture) void {
    while (!rl.windowShouldClose()) {
        state.update();

        rl.beginDrawing();
        rl.clearBackground(rl.Color.black);

        if (state.video_active) {
            surface.draw(0, 0, rl.Color.white);
        }

        rl.endDrawing();
    }
}

fn parseArgs(args: [][:0]u8) struct { [:0]u8, ?[][:0]u8 } {
    if (args.len < 2) {
        showUsage();
        exit(1);
    }

    return .{ args[args.len - 1], null };
}

pub fn main() !void {
    const alloc = std.heap.c_allocator;
    const args = try std.process.argsAlloc(alloc);
    defer std.process.argsFree(alloc, args);

    const video_file, const yt_args = parseArgs(args);

    // Initialization
    var state = VideoState.initVideo(video_file, yt_args);

    rl.setTraceLogLevel(.warning);
    rl.initWindow(default_window_height, default_window_height, "Epic");
    defer rl.closeWindow();

    const width, const height = .{ state.v_decoder.ctx.width, state.v_decoder.ctx.height };
    const img = rl.Image{
        .width = width,
        .height = height,
        .mipmaps = 1,
        .format = .uncompressed_r8g8b8,
        .data = state.out_frame.data[0],
    };
    const surface = try rl.loadTextureFromImage(img);

    mainLoop(&state, surface);
}
