const std = @import("std");
const Builder = std.build.Builder;
const LibExeObjectStep = std.build.LibExeObjStep;

pub fn build(b: *Builder) void {
    const optimize = b.standardOptimizeOption(.{});

    const test_step = b.step("test", "Test the program");
    test_step.dependOn(b.getInstallStep());

    const exe = b.addExecutable(.{
        .name = "test",
        .optimize = optimize,
    });
    exe.addCSourceFile("main.c", &[0][]const u8{});
    exe.linkLibC();
    exe.linkFrameworkWeak("Cocoa");

    const check = exe.checkObject(.macho);
    check.checkStart("cmd LOAD_WEAK_DYLIB");
    check.checkNext("name {*}Cocoa");
    test_step.dependOn(&check.step);

    const run_cmd = exe.run();
    test_step.dependOn(&run_cmd.step);
}
