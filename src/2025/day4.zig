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
    var count: usize = 0;
    for (0..grid.height) |y| {
        for (0..grid.width) |x| {
            if (grid.get(x, y) == '@' and grid.countAdjacent(x, y, '@') < 4) {
                count += 1;
            }
        }
    }
    return count;
}

const Pos = struct {
    x: usize,
    y: usize,
};

pub fn solve2(grid: *Grid) !usize {
    var count: usize = 0;
    var candidates = std.array_list.AlignedManaged(Pos, null).init(alloc);
    defer candidates.deinit();

    while (true) {
        for (0..grid.height) |y| {
            for (0..grid.width) |x| {
                if (grid.get(x, y) == '@' and grid.countAdjacent(x, y, '@') < 4) {
                    try candidates.append(.{ .x = x, .y = y });
                }
            }
        }
        if (candidates.items.len == 0) {
            return count;
        }
        count += candidates.items.len;
        for (candidates.items) |pos| {
            grid.set(pos.x, pos.y, 'x');
        }
        candidates.clearRetainingCapacity();
    }
    return count;
}

test "example" {
    alloc = std.testing.allocator;
    const input =
        \\..@@.@@@@.
        \\@@@.@.@.@@
        \\@@@@@.@.@@
        \\@.@@@@..@.
        \\@@.@@@@.@@
        \\.@@@@@@@.@
        \\.@.@.@.@@@
        \\@.@@@.@@@@
        \\.@@@@@@@@.
        \\@.@.@@@.@.
    ;

    var grid: *Grid = try parse(input);
    defer alloc.destroy(grid);
    defer grid.deinit();

    try std.testing.expectEqual(@as(usize, 13), try solve1(grid));
    try std.testing.expectEqual(@as(usize, 43), try solve2(grid));
}
