const std = @import("std");
pub const stdout = @import("stdout.zig");

pub fn part1(input: []const u8, allocator: std.mem.Allocator) !usize {
    _ = input;
    _ = allocator;
    return 0;
}

pub fn part2(input: []const u8, allocator: std.mem.Allocator) !usize {
    _ = input;
    _ = allocator;
    return 0;
}

pub fn main() !void {
    try @import("main.zig").aocRun(@src(), @This());
}

test "example" {
    const input =
        \\
    ;
    try std.testing.expectEqual(@as(usize, 0), try part1(input, std.testing.allocator));
    try std.testing.expectEqual(@as(usize, 0), try part2(input, std.testing.allocator));
}
