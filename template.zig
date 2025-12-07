const std = @import("std");
const stdout = @import("stdout.zig");

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
    const day = comptime (@src().file[0..std.mem.indexOfScalar(u8, @src().file, '.').?]);
    try @import("main.zig").aocRun(day, stdout, part1, part2);
}

test "example" {
    const input =
        \\
    ;
    try std.testing.expectEqual(@as(usize, 0), try part1(input, std.testing.allocator));
    try std.testing.expectEqual(@as(usize, 0), try part2(input, std.testing.allocator));
}
