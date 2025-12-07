const std = @import("std");
pub const stdout = @import("stdout.zig");

fn parse(input: []const u8, allocator: std.mem.Allocator) ![]i32 {
    var res = std.array_list.AlignedManaged(i32, null).init(allocator);
    var lines = std.mem.tokenizeScalar(u8, input, '\n');

    while (lines.next()) |line| {
        const value = try std.fmt.parseInt(i32, line[1..], 10);
        const direction: i2 = if (line[0] == 'L') -1 else 1;
        try res.append(value * direction);
    }
    return try res.toOwnedSlice();
}

pub fn part1(input: []const u8, allocator: std.mem.Allocator) !usize {
    const data = try parse(input, allocator);
    defer allocator.free(data);

    var position: i32 = 50;
    var zeroes: usize = 0;

    for (data) |item| {
        position = @mod(position + item, 100);
        if (position == 0) zeroes += 1;
    }
    return zeroes;
}

pub fn part2(input: []const u8, allocator: std.mem.Allocator) !i32 {
    const data = try parse(input, allocator);
    defer allocator.free(data);

    var position: i32 = 50;
    var zeroes: i32 = 0;
    for (data) |item| {
        if (item < 0) {
            if (position == 0) zeroes -= 1;
            position += item;
            zeroes -= @divFloor(position, 100);
            if (@mod(position, 100) == 0) {
                zeroes += 1;
            }
        } else {
            position += item;
            zeroes += @divFloor(position, 100);
        }
        position = @intCast(@mod(position, 100));
    }
    return zeroes;
}

pub fn main() !void {
    try @import("main.zig").aocRun(@src(), @This());
}

test "example" {
    const input =
        \\L68
        \\L30
        \\R48
        \\L5
        \\R60
        \\L55
        \\L1
        \\L99
        \\R14
        \\L82
    ;
    const allocator = std.testing.allocator;

    try std.testing.expectEqual(@as(usize, 3), try part1(input, allocator));
    try std.testing.expectEqual(@as(i32, 10), try part2("R1000", allocator));
    try std.testing.expectEqual(@as(i32, 1), try part2("L51", allocator));
    try std.testing.expectEqual(@as(i32, 6), try part2(input, allocator));
}
