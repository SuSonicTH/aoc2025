const std = @import("std");
pub const stdout = @import("stdout.zig");

const shapes = 6;
const shapeSize = 16;

pub fn part1(input: []const u8, allocator: std.mem.Allocator) !usize {
    _ = allocator;

    var lines = std.mem.tokenizeScalar(u8, input[shapes * shapeSize ..], '\n');

    var validRegions: usize = 0;
    while (lines.next()) |line| {
        var packages = std.mem.tokenizeScalar(u8, line[6..], ' ');
        var packageCount: u16 = 0;
        while (packages.next()) |package| {
            packageCount += try std.fmt.parseInt(u16, package, 10);
        }

        const widht = try std.fmt.parseInt(u16, line[0..2], 10);
        const height = try std.fmt.parseInt(u16, line[3..5], 10);
        const availablePackageArea = widht / 3 * height / 3;
        if (availablePackageArea >= packageCount) {
            validRegions += 1;
        }
    }
    return validRegions;
}

pub fn part2(input: []const u8, allocator: std.mem.Allocator) !usize {
    _ = input;
    _ = allocator;
    return 0;
}

pub fn main() !void {
    try @import("main.zig").aocRun(@src(), @This());
}

test "example" {}
