const std = @import("std");
const aozig = @import("aozig");

pub fn build(b: *std.Build) !void {
    const dep = b.dependency("aozig", .{});
    try aozig.defaultBuild(b, .{
        .default_year = 2025,
        .binary_name = "aoc",
        .runtime_dependency = dep,
    });
}
