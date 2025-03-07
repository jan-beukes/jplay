const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "jplay",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Raylib
    const raylib_dep = b.dependency("raylib_zig", .{});
    const raylib = raylib_dep.module("raylib");
    const libraylib = raylib_dep.artifact("raylib");
    exe.linkLibrary(libraylib);
    exe.root_module.addImport("raylib", raylib);

    // ffmpeg
    exe.addLibraryPath(b.path("lib"));
    exe.linkSystemLibrary("avcodec");
    exe.linkSystemLibrary("avutil");
    exe.linkSystemLibrary("avformat");
    exe.linkSystemLibrary("swscale");
    exe.linkSystemLibrary("swresample");

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
