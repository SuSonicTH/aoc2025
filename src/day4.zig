const std = @import("std");
pub const stdout = @import("stdout.zig");
const Grid = @import("Grid.zig");

pub fn part1(input: []const u8, allocator: std.mem.Allocator) !usize {
    var grid = try Grid.init(input, allocator);
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

pub fn part2(input: []const u8, allocator: std.mem.Allocator) !usize {
    var grid = try Grid.init(input, allocator);
    defer grid.deinit();

    var count: usize = 0;
    var candidates = std.array_list.AlignedManaged(Pos, null).init(allocator);
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

pub fn main() !void {
    try @import("main.zig").aocRun(@src(), @This());
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

    const allocator = std.testing.allocator;
    try std.testing.expectEqual(@as(usize, 13), try part1(input, allocator));
    try std.testing.expectEqual(@as(usize, 43), try part2(input, allocator));
}
