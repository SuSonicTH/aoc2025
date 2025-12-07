const std = @import("std");
const stdout = @import("stdout.zig");
const Grid = @import("Grid.zig");

pub fn part1(input: []const u8, allocator: std.mem.Allocator) !usize {
    var grid = try Grid.init(input, allocator);
    defer grid.deinit();

    var beams = try allocator.alloc(bool, grid.width);
    defer allocator.free(beams);
    @memset(beams, false);

    const start = std.mem.indexOfScalar(u8, grid.grid, 'S').?;
    beams[start] = true;

    var split: usize = 0;
    for (1..grid.height - 1) |y| {
        for (0..grid.width) |x| {
            if (grid.get(x, y) == '^' and beams[x]) {
                split += 1;
                beams[x - 1] = true;
                beams[x + 1] = true;
                beams[x] = false;
            }
        }
    }
    return split;
}

pub fn part2(input: []const u8, allocator: std.mem.Allocator) !usize {
    var grid = try Grid.init(input, allocator);
    defer grid.deinit();

    var beams = try allocator.alloc(usize, grid.width);
    defer allocator.free(beams);
    @memset(beams, 0);

    const start = std.mem.indexOfScalar(u8, grid.grid, 'S').?;
    beams[start] = 1;

    for (1..grid.height - 1) |y| {
        for (0..grid.width) |x| {
            if (grid.get(x, y) == '^') {
                beams[x - 1] += beams[x];
                beams[x + 1] += beams[x];
                beams[x] = 0;
            }
        }
    }

    var timelines: usize = 0;
    for (beams) |beam| {
        timelines += beam;
    }
    return timelines;
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
        \\.......S.......
        \\...............
        \\.......^.......
        \\...............
        \\......^.^......
        \\...............
        \\.....^.^.^.....
        \\...............
        \\....^.^...^....
        \\...............
        \\...^.^...^.^...
        \\...............
        \\..^...^.....^..
        \\...............
        \\.^.^.^.^.^...^.
        \\...............
    ;
    const allocator = std.testing.allocator;
    try std.testing.expectEqual(@as(usize, 21), try part1(input, allocator));
    try std.testing.expectEqual(@as(usize, 40), try part2(input, allocator));
}
