const std = @import("std");
const aozig = @import("aozig");
const stdout = @import("stdout.zig");

pub var alloc: std.mem.Allocator = undefined;

pub fn parse(input: []const u8) ![][]const u8 {
    var iterator = std.mem.tokenizeScalar(u8, input, '\n');
    var lines: [][]const u8 = try alloc.alloc([]const u8, 5);
    for (0..5) |i| {
        if (iterator.next()) |line| {
            lines[i] = line;
        } else {
            lines[i] = "#";
        }
    }
    return lines;
}

pub fn solve1(lines: [][]const u8) !usize {
    var result: usize = 0;
    const numbers: usize = if (lines[4][0] == '#') 3 else 4;
    var pos: usize = 0;
    var next: usize = 0;
    while (pos < lines[0].len) {
        var calc: usize = 0;
        for (0..numbers) |l| {
            var s = pos;
            while (lines[l][s] == ' ') s += 1;
            var e = s + 1;
            while (e < lines[l].len and lines[l][e] != ' ') e += 1;
            if (e > next) next = e;
            const number = try std.fmt.parseInt(usize, lines[l][s..e], 10);
            if (l == 0) {
                calc = number;
            } else {
                const op = lines[numbers][pos];
                if (op == '+') {
                    calc += number;
                } else if (op == '*') {
                    calc *= number;
                } else {
                    @panic("unknown operator expecting +/*");
                }
            }
        }
        result += calc;
        pos = next + 1;
    }
    return result;
}

pub fn solve2(input: [][]const u8) !usize {
    const result: usize = 0;
    _ = input;
    return result;
}

test "example" {
    alloc = std.testing.allocator;
    const input =
        \\123 328  51 64 
        \\ 45 64  387 23 
        \\  6 98  215 314
        \\*   +   *   +
    ;
    const lines = try parse(input);
    defer alloc.free(lines);
    try std.testing.expectEqual(@as(usize, 4277556), try solve1(lines));
    try std.testing.expectEqual(@as(usize, 3263827), try solve2(lines));
}
