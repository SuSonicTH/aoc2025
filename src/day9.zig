const std = @import("std");
pub const stdout = @import("stdout.zig");

const Point = struct {
    x: usize,
    y: usize,
};

const Rect = struct {
    min: Point,
    max: Point,

    pub fn init(p1: Point, p2: Point) Rect {
        return .{
            .min = .{
                .x = @min(p1.x, p2.x),
                .y = @min(p1.y, p2.y),
            },
            .max = .{
                .x = @max(p1.x, p2.x),
                .y = @max(p1.y, p2.y),
            },
        };
    }

    pub fn area(self: Rect) usize {
        return (self.max.x - self.min.x + 1) * (self.max.y - self.min.y + 1);
    }

    pub fn intersects(self: Rect, edges: []Edge) bool {
        for (edges) |edge| {
            if (self.min.y < edge.max.y and self.max.y > edge.min.y and self.min.x < edge.max.x and self.max.x > edge.min.x)
                return true;
        }
        return false;
    }
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
            const area = Rect.init(p1, p2).area();
            if (area > max) {
                max = area;
            }
        }
    }
    return max;
}

const Edge = struct {
    min: Point,
    max: Point,

    pub fn init(p1: Point, p2: Point) Edge {
        return .{
            .min = .{
                .x = @min(p1.x, p2.x),
                .y = @min(p1.y, p2.y),
            },
            .max = .{
                .x = @max(p1.x, p2.x),
                .y = @max(p1.y, p2.y),
            },
        };
    }
};

pub fn part2(input: []const u8, allocator: std.mem.Allocator) !usize {
    var points = try parse(input, allocator);
    defer points.deinit();

    var edges = std.array_list.AlignedManaged(Edge, null).init(allocator);
    defer edges.deinit();

    var last = points.items[0];
    for (1..points.items.len) |p| {
        const current = points.items[p];
        try edges.append(Edge.init(last, current));
        last = current;
    }
    try edges.append(Edge.init(last, points.items[0]));

    var max: usize = 0;
    for (0..points.items.len) |a| {
        const p1 = points.items[a];
        for (a + 1..points.items.len) |b| {
            const p2 = points.items[b];
            const rect = Rect.init(p1, p2);
            const area = rect.area();
            if (area > max and !rect.intersects(edges.items)) {
                max = area;
            }
        }
    }
    return max;
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
    try std.testing.expectEqual(@as(usize, 24), try part2(input, std.testing.allocator));
}

test "real data" {
    const inputFile = @embedFile("day9.txt");
    try std.testing.expectEqual(@as(usize, 4777824480), try part1(inputFile, std.testing.allocator));
    try std.testing.expectEqual(@as(usize, 1542119040), try part2(inputFile, std.testing.allocator));
}
