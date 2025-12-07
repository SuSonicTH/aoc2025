const std = @import("std");
pub const stdout = @import("stdout.zig");

pub var alloc: std.mem.Allocator = undefined;

pub fn parse(input: []const u8, allocator: std.mem.Allocator) !std.array_list.AlignedManaged([]const u8, null) {
    var iterator = std.mem.tokenizeScalar(u8, input, '\n');
    var res = std.array_list.AlignedManaged([]const u8, null).init(allocator);
    while (iterator.next()) |line| {
        try res.append(line);
    }
    return res;
}

pub fn part1(input: []const u8, allocator: std.mem.Allocator) !usize {
    const data = try parse(input, allocator);
    defer data.deinit();

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
                switch (ops[pos]) {
                    '+' => calc += number,
                    '*' => calc *= number,
                    else => @panic("unknown operator expecting +/*"),
                }
            }
        }
        result += calc;
        pos = next + 1;
    }
    return result;
}

pub fn part2(input: []const u8, allocator: std.mem.Allocator) !usize {
    const data = try parse(input, allocator);
    defer data.deinit();

    const numbers = data.items[0 .. data.items.len - 1];
    const ops = data.items[data.items.len - 1];

    var result: usize = 0;
    var pos: usize = ops.len - 1;
    while (pos > 0) {
        var o = pos;
        while (ops[o] == ' ') o -= 1;
        const op = ops[o];

        var firstNumber: bool = true;
        var calc: usize = 0;
        while (pos >= o) {
            const number = parseNumber(numbers, pos);
            if (firstNumber) {
                calc = number;
                firstNumber = false;
            } else {
                switch (op) {
                    '+' => calc += number,
                    '*' => calc *= number,
                    else => @panic("unknown operator expecting +/*"),
                }
            }
            if (pos == 0) {
                return result + calc;
            }
            pos -= 1;
        }
        result += calc;
        pos -= 1;
    }
    unreachable;
}

fn parseNumber(numbers: []const []const u8, pos: usize) usize {
    var number: usize = 0;
    var firstDigit: bool = true;
    for (0..numbers.len) |p| {
        if (numbers[p][pos] >= '0' and numbers[p][pos] <= '9') {
            if (!firstDigit) {
                number *= 10;
            } else {
                firstDigit = false;
            }
            number += (numbers[p][pos] - '0');
        }
    }
    return number;
}

pub fn main() !void {
    try @import("main.zig").aocRun(@src(), @This());
}

test "example" {
    const input =
        \\123 328  51 64 
        \\ 45 64  387 23 
        \\  6 98  215 314
        \\*   +   *   +  
    ;
    const allocator = std.testing.allocator;
    try std.testing.expectEqual(@as(usize, 4277556), try part1(input, allocator));
    try std.testing.expectEqual(@as(usize, 3263827), try part2(input, allocator));
}
