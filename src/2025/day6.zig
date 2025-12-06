const std = @import("std");
const aozig = @import("aozig");
const stdout = @import("stdout.zig");

pub var alloc: std.mem.Allocator = undefined;

pub fn parse(input: []const u8) !std.array_list.AlignedManaged([]const u8, null) {
    var iterator = std.mem.tokenizeScalar(u8, input, '\n');
    var res = std.array_list.AlignedManaged([]const u8, null).init(alloc);
    while (iterator.next()) |line| {
        try res.append(line);
    }
    return res;
}

pub fn solve1(data: std.array_list.AlignedManaged([]const u8, null)) !usize {
    const numbers = data.items[0 .. data.items.len - 1];
    const ops = data.items[data.items.len - 1];

    var result: usize = 0;

    var pos: usize = 0;
    var next: usize = 0;
    while (pos < numbers[0].len) {
        var calc: usize = 0;
        for (numbers, 0..) |current, n| {
            var start = pos;
            while (current[start] == ' ') start += 1;
            var end = start + 1;
            while (end < current.len and current[end] != ' ') end += 1;
            if (end > next) next = end;

            const number = try std.fmt.parseInt(usize, current[start..end], 10);
            if (n == 0) {
                calc = number;
            } else {
                const op = ops[pos];
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

pub fn solve2(data: std.array_list.AlignedManaged([]const u8, null)) !usize {
    const result: usize = 0;
    _ = data;
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
    var lines = try parse(input);
    defer lines.deinit();
    try std.testing.expectEqual(@as(usize, 4277556), try solve1(lines));
    //try std.testing.expectEqual(@as(usize, 3263827), try solve2(lines));
}
