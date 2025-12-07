const std = @import("std");
const aozig = @import("aozig");

pub var alloc: std.mem.Allocator = undefined;

pub fn parse(input: []const u8) ![]i32 {
    var res = std.array_list.AlignedManaged(i32, null).init(std.heap.page_allocator);
    var lines = std.mem.tokenizeScalar(u8, input, '\n');

    while (lines.next()) |line| {
        const value = try std.fmt.parseInt(i32, line[1..], 10);
        const direction: i2 = if (line[0] == 'L') -1 else 1;
        try res.append(value * direction);
    }
    return try res.toOwnedSlice();
}

pub fn solve1(data: []i32) !usize {
    var position: i32 = 50;
    var zeroes: usize = 0;

    for (data) |item| {
        position = @mod(position + item, 100);
        if (position == 0) zeroes += 1;
    }
    return zeroes;
}

pub fn solve2(data: []i32) !i32 {
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
    _ = try parse(input);
    try std.testing.expectEqual(@as(usize, 3), try solve1(try parse(input)));
    try std.testing.expectEqual(@as(i32, 10), try solve2(try parse("R1000")));
    try std.testing.expectEqual(@as(i32, 1), try solve2(try parse("L51")));
    try std.testing.expectEqual(@as(i32, 6), try solve2(try parse(input)));
}
