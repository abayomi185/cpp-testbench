// See:
// https://github.com/ggerganov/ggml/blob/master/build.zig
// and
// https://github.com/raysan5/raylib/blob/master/src/build.zig
// for examples of how to build a C++ project with Zig
const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const src_dir = try std.fs.cwd().openDir("src");
    var it = try src_dir.iterate();

    const exe = b.addExecutable(.{ .name = "main", .target = target, .optimize = optimize });

    while (try it.next()) |entry| {
        if (entry.kind == .File and entry.name.endsWith(".cpp")) {
            exe.addCSourceFile(.{
                .file = .{ .path = "src/" ++ entry.name },
                .flags = &.{"-std=c++14"},
            });
        }
    }

    exe.linkSystemLibrary("c++");
    exe.linkLibCpp();
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
