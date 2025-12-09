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

fn fullyCoverd(p1: Point, p2: Point) bool {
    _ = p1;
    _ = p2;
    return false;
}
pub fn part2(input: []const u8, allocator: std.mem.Allocator) !usize {
    var points = try parse(input, allocator);
    defer points.deinit();

    var max: usize = 0;
    for (0..points.items.len) |a| {
        const p1 = points.items[a];
        for (a + 1..points.items.len) |b| {
            const p2 = points.items[b];
            const area = (@max(p1.x, p2.x) - @min(p1.x, p2.x) + 1) * (@max(p1.y, p2.y) - @min(p1.y, p2.y) + 1);
            if (area > max and fullyCoverd(p1, p2)) {
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
