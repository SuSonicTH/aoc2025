const std = @import("std");
const aozig = @import("aozig");
const Grid = @import("Grid.zig");

pub var alloc: std.mem.Allocator = undefined;

pub fn parse(input: []const u8) !*Grid {
    const ptr = try alloc.create(Grid);
    ptr.* = try Grid.init(input, alloc);
    return ptr;
}

pub fn solve1(grid: *Grid) !usize {
    var beams = try alloc.alloc(bool, grid.width);
    defer alloc.free(beams);
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

pub fn solve2(grid: *Grid) !usize {
    var beams = try alloc.alloc(usize, grid.width);
    defer alloc.free(beams);
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

test "example" {
    alloc = std.testing.allocator;
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
    var grid: *Grid = try parse(input);
    defer alloc.destroy(grid);
    defer grid.deinit();

    try std.testing.expectEqual(@as(usize, 21), try solve1(grid));
    try std.testing.expectEqual(@as(usize, 40), try solve2(grid));
}
