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
    const input = @embedFile(day ++ ".txt");
    const allocator = std.heap.smp_allocator;

    stdout.printfl("{s} part1: {any} ", .{ day, part1(input, allocator) });
    stdout.printfl("part2: {any} \n", .{part2(input, allocator)});
}

test "example" {
    const input =
        \\
    ;
    try std.testing.expectEqual(@as(usize, 0), try part1(input, std.testing.allocator));
    try std.testing.expectEqual(@as(usize, 0), try part2(input, std.testing.allocator));
}
