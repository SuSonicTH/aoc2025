const std = @import("std");
const aozig = @import("aozig");
const Grid = @import("Grid.zig");
const stdout = @import("stdout.zig");

pub var alloc: std.mem.Allocator = undefined;

pub fn parse(input: []const u8) !*Grid {
    const ptr = try alloc.create(Grid);
    ptr.* = try Grid.init(input, alloc);
    return ptr;
}

pub fn solve1(grid: *Grid) !usize {
    var beams = std.array_list.AlignedManaged(usize, null).init(std.heap.page_allocator);
    defer beams.deinit();

    var newBeams = std.array_list.AlignedManaged(usize, null).init(std.heap.page_allocator);
    defer newBeams.deinit();

    const start = std.mem.indexOfScalar(u8, grid.grid, 'S').?;
    try beams.append(start);

    var splited: usize = 0;
    for (1..grid.height - 1) |y| {
        for (beams.items) |x| {
            if (grid.get(x, y) == '^') {
                splited += 1;
                if (!contains(newBeams.items, x - 1)) try newBeams.append(x - 1);
                if (!contains(newBeams.items, x + 1)) try newBeams.append(x + 1);
            } else {
                if (!contains(newBeams.items, x)) try newBeams.append(x);
            }
        }
        const tmp = beams;
        beams = newBeams;
        newBeams = tmp;

        newBeams.clearRetainingCapacity();
    }
    return splited;
}

fn contains(beams: []usize, item: usize) bool {
    for (beams) |beam| {
        if (beam == item) {
            return true;
        }
    }
    return false;
}

pub fn solve2(grid: *Grid) usize {
    _ = grid;
    return 0;
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
    try std.testing.expectEqual(@as(usize, 0), solve2(grid));
}
