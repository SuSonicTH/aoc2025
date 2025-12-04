const std = @import("std");
const Grid = @This();

allocator: std.mem.Allocator,
grid: []u8,
width: usize,
height: usize,

pub fn init(input: []const u8, allocator: std.mem.Allocator) !Grid {
    const rowLen = std.mem.indexOfScalar(u8, input, '\n').?;
    return .{
        .allocator = allocator,
        .grid = try allocator.dupe(u8, input),
        .width = rowLen,
        .height = input.len / rowLen,
    };
}

pub fn deinit(self: *Grid) void {
    self.allocator.free(self.grid);
}

pub fn get(self: *Grid, x: usize, y: usize) u8 {
    if (x >= self.width or y >= self.height) {
        return 0;
    }
    return self.grid[y * (self.width + 1) + x];
}

pub fn set(self: *Grid, x: usize, y: usize, v: u8) void {
    if (x >= self.width or y >= self.height) {
        return;
    }
    self.grid[y * (self.width + 1) + x] = v;
}

pub fn countAdjacent(self: *Grid, x: usize, y: usize, i: u8) usize {
    var count: usize = 0;
    inline for ([_]i2{ -1, 0, 1 }) |yv| {
        inline for ([_]i2{ -1, 0, 1 }) |xv| {
            if (xv == 0 and yv == 0) continue;

            const yc: i64 = @as(i64, @intCast(y)) + yv;
            const xc: i64 = @as(i64, @intCast(x)) + xv;

            if (xc >= 0 and yc >= 0) {
                if (self.get(@as(usize, @intCast(xc)), @as(usize, @intCast(yc))) == i) {
                    count += 1;
                }
            }
        }
    }
    return count;
}

const testInput =
    \\A...B
    \\C...D
    \\..E..
    \\F...G
;

test "init,size,deinit" {
    var grid = try Grid.init(testInput, std.testing.allocator);
    defer grid.deinit();

    try std.testing.expectEqual(5, grid.width);
    try std.testing.expectEqual(4, grid.height);
}

test "get" {
    var grid = try Grid.init(testInput, std.testing.allocator);
    defer grid.deinit();

    try std.testing.expectEqual('A', grid.get(0, 0));
    try std.testing.expectEqual('B', grid.get(4, 0));
    try std.testing.expectEqual('C', grid.get(0, 1));
    try std.testing.expectEqual('D', grid.get(4, 1));
    try std.testing.expectEqual('E', grid.get(2, 2));
    try std.testing.expectEqual('F', grid.get(0, 3));
    try std.testing.expectEqual('G', grid.get(4, 3));

    try std.testing.expectEqual(@as(u8, 0), grid.get(5, 0));
    try std.testing.expectEqual(@as(u8, 0), grid.get(0, 4));
}

test "set" {
    var grid = try Grid.init(testInput, std.testing.allocator);
    defer grid.deinit();

    grid.set(0, 0, 'a');
    try std.testing.expectEqual('a', grid.get(0, 0));

    grid.set(4, 0, 'b');
    try std.testing.expectEqual('b', grid.get(4, 0));

    grid.set(0, 1, 'c');
    try std.testing.expectEqual('c', grid.get(0, 1));

    grid.set(4, 1, 'd');
    try std.testing.expectEqual('d', grid.get(4, 1));

    grid.set(2, 2, 'e');
    try std.testing.expectEqual('e', grid.get(2, 2));

    grid.set(0, 3, 'f');
    try std.testing.expectEqual('f', grid.get(0, 3));

    grid.set(4, 3, 'g');
    try std.testing.expectEqual('g', grid.get(4, 3));
}

test "countAdjacent" {
    const input =
        \\xxx..
        \\x.x..
        \\xxx..
        \\.....
    ;
    var grid = try Grid.init(input, std.testing.allocator);
    defer grid.deinit();

    try std.testing.expectEqual(@as(usize, 2), grid.countAdjacent(0, 0, 'x'));
    try std.testing.expectEqual(@as(usize, 4), grid.countAdjacent(1, 0, 'x'));
    try std.testing.expectEqual(@as(usize, 8), grid.countAdjacent(1, 1, 'x'));
    try std.testing.expectEqual(@as(usize, 0), grid.countAdjacent(4, 3, 'x'));
    try std.testing.expectEqual(@as(usize, 1), grid.countAdjacent(3, 3, 'x'));
}
