const std = @import("std");
const aozig = @import("aozig");
const Grid = @import("Grid.zig");
const stdout = @import("stdout.zig");

pub var alloc: std.mem.Allocator = undefined;

pub fn parse(input: []const u8) ![]const u8 {
    return input;
}

pub fn solve1(input: []const u8) !usize {
    var grid = try Grid.init(input, std.heap.page_allocator);
    defer grid.deinit();

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

pub fn solve2(input: []const u8) !usize {
    var grid = try Grid.init(input, std.heap.page_allocator);
    defer grid.deinit();

    var count: usize = 0;
    var candidates = std.array_list.AlignedManaged(Pos, null).init(std.heap.page_allocator);
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

    try std.testing.expectEqual(@as(usize, 13), try solve1(input));
    try std.testing.expectEqual(@as(usize, 43), try solve2(input));
}
