const std = @import("std");
pub const stdout = @import("stdout.zig");

const Point = struct {
    x: usize,
    y: usize,
};

fn parse(input: []const u8, allocator: std.mem.Allocator) !std.array_list.AlignedManaged(Point, null) {
    var points = std.array_list.AlignedManaged(Point, null).init(allocator);

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    while (lines.next()) |line| {
        var coordinates = std.mem.tokenizeScalar(u8, line, ',');
        try points.append(.{
            .x = try std.fmt.parseInt(usize, coordinates.next().?, 10),
            .y = try std.fmt.parseInt(usize, coordinates.next().?, 10),
        });
    }
    return points;
}

pub fn part1(input: []const u8, allocator: std.mem.Allocator) !usize {
    var points = try parse(input, allocator);
    defer points.deinit();

    var max: usize = 0;
    for (0..points.items.len) |a| {
        const p1 = points.items[a];
        for (a + 1..points.items.len) |b| {
            const p2 = points.items[b];
            const area = (@max(p1.x, p2.x) - @min(p1.x, p2.x) + 1) * (@max(p1.y, p2.y) - @min(p1.y, p2.y) + 1);
            if (area > max) {
                max = area;
            }
        }
    }
    return max;
}

fn Grid(comptime T: type) type {
    return struct {
        const Self = @This();
        allocator: std.mem.Allocator,
        height: usize,
        width: usize,
        grid: []T = undefined,

        pub fn init(width: usize, height: usize, fill: T, allocator: std.mem.Allocator) !Self {
            const grid = try allocator.alloc(T, height * width);
            @memset(grid, fill);
            return .{
                .allocator = allocator,
                .width = width,
                .height = height,
                .grid = grid,
            };
        }

        pub fn deinit(self: Self) void {
            self.allocator.free(self.grid);
        }

        pub fn set(self: Self, x: usize, y: usize, value: T) !void {
            if (x >= self.width) return error.xOutOfBounds;
            if (y >= self.height) return error.yOutOfBounds;
            self.grid[y * self.width + x] = value;
        }

        pub fn get(self: Self, x: usize, y: usize) !T {
            if (x >= self.width) return error.xOutOfBounds;
            if (y >= self.height) return error.yOutOfBounds;
            return self.grid[y * self.width + x];
        }

        pub fn print(self: Self, writer: *std.Io.Writer) !void {
            for (0..self.height) |y| {
                for (0..self.width) |x| {
                    try writer.print("{c}", .{try self.get(x, y)});
                }
                try writer.print("\n", .{});
            }
        }
    };
}

fn drawLine(grid: Grid(u8), p1: Point, p2: Point) !void {
    try grid.set(p2.x, p2.y, '#');
    if (p1.x == p2.x) {
        const from = @min(p1.y, p2.y);
        const to = @max(p1.y, p2.y);
        for (from + 1..to) |y| {
            try grid.set(p2.x, y, 'X');
        }
    } else if (p1.y == p2.y) {
        const from = @min(p1.x, p2.x);
        const to = @max(p1.x, p2.x);
        for (from + 1..to) |x| {
            try grid.set(x, p2.y, 'X');
        }
    } else {
        return error.expectingHorizontalOrVerticalLines;
    }
}

fn fillInner(grid: Grid(u8)) !void {
    for (0..grid.height) |y| {
        var inside = false;
        for (0..grid.width) |x| {
            if (inside) {
                if (try grid.get(x, y) == '.') {
                    try grid.set(x, y, 'X');
                } else {
                    inside = false;
                }
            } else {
                if (try grid.get(x, y) != '.' and x + 1 < grid.width and try grid.get(x + 1, y) == '.') {
                    inside = true;
                }
            }
        }
    }
}

pub fn part2(input: []const u8, allocator: std.mem.Allocator) !usize {
    var points = try parse(input, allocator);
    defer points.deinit();

    var maxX: usize = 0;
    var maxY: usize = 0;
    for (points.items) |point| {
        if (point.x > maxX) maxX = point.x;
        if (point.y > maxY) maxY = point.y;
    }
    stdout.printfl("size: {d}x{d}\n", .{ maxX, maxY });

    var grid = try Grid(u8).init(maxX + 1, maxY + 1, '.', allocator);
    defer grid.deinit();

    var last = points.items[0];
    try grid.set(last.x, last.y, '#');
    for (1..points.items.len) |p| {
        const current = points.items[p];
        try drawLine(grid, last, current);
        last = current;
    }
    try drawLine(grid, last, points.items[0]);

    try fillInner(grid);

    try grid.print(stdout.getWriter());
    stdout.flush();
    return 0;
}

pub fn main() !void {
    try @import("main.zig").aocRun(@src(), @This());
}

test "example" {
    const input =
        \\7,1
        \\11,1
        \\11,7
        \\9,7
        \\9,5
        \\2,5
        \\2,3
        \\7,3
    ;
    try std.testing.expectEqual(@as(usize, 50), try part1(input, std.testing.allocator));
    try std.testing.expectEqual(@as(usize, 0), try part2(input, std.testing.allocator));
}

test "grid" {
    var grid = try Grid(u8).init(10, 10, '.', std.testing.allocator);
    defer grid.deinit();

    try std.testing.expectEqual('.', try grid.get(0, 0));
    try std.testing.expectEqual('.', try grid.get(9, 0));
    try std.testing.expectEqual('.', try grid.get(0, 9));
    try std.testing.expectEqual('.', try grid.get(9, 9));

    try grid.set(0, 0, '#');
    try grid.set(9, 0, 'X');
    try grid.set(0, 9, '#');
    try grid.set(9, 9, 'X');

    try std.testing.expectEqual('#', try grid.get(0, 0));
    try std.testing.expectEqual('X', try grid.get(9, 0));
    try std.testing.expectEqual('#', try grid.get(0, 9));
    try std.testing.expectEqual('X', try grid.get(9, 9));

    try std.testing.expectEqual(error.xOutOfBounds, grid.get(10, 0));
    try std.testing.expectEqual(error.yOutOfBounds, grid.get(0, 10));
}
