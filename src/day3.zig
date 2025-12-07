const std = @import("std");
const stdout = @import("stdout.zig");

pub fn part1(input: []const u8, allocator: std.mem.Allocator) !usize {
    _ = allocator;

    var banks = std.mem.tokenizeScalar(u8, input, '\n');
    var res: usize = 0;
    while (banks.next()) |bank| {
        res += try maxJoltage(bank, 2);
    }
    return res;
}

fn maxJoltage2(bank: []const u8) usize {
    var max1: usize = 0;
    var max2: usize = bank.len - 1;

    for (1..bank.len - 1) |pos| {
        if (bank[pos] > bank[max1]) {
            max1 = pos;
        }
    }

    var pos = bank.len - 2;
    while (pos > max1) {
        if (bank[pos] > bank[max2]) {
            max2 = pos;
        }
        pos -= 1;
    }
    return (bank[max1] - '0') * 10 + (bank[max2] - '0');
}

pub fn part2(input: []const u8, allocator: std.mem.Allocator) !usize {
    _ = allocator;
    var banks = std.mem.tokenizeScalar(u8, input, '\n');
    var res: usize = 0;
    while (banks.next()) |bank| {
        res += try maxJoltage(bank, 12);
    }
    return res;
}

const pow10: [12]usize = .{
    1,
    10,
    100,
    1000,
    10000,
    100000,
    1000000,
    10000000,
    100000000,
    1000000000,
    10000000000,
    100000000000,
};

fn maxJoltage(bank: []const u8, batteries: u8) !usize {
    var last: usize = 0;
    var ret: usize = 0;
    var candidate: u8 = undefined;

    for (0..batteries) |battery| {
        candidate = bank[last];
        for (last + 1..bank.len - batteries + 1 + battery) |pos| {
            if (bank[pos] > candidate) {
                candidate = bank[pos];
                last = pos;
            }
        }
        ret += pow10[batteries - 1 - battery] * (candidate - '0');
        last += 1;
    }

    return ret;
}

pub fn main() !void {
    const day = comptime (@src().file[0..std.mem.indexOfScalar(u8, @src().file, '.').?]);
    try @import("main.zig").aocRun(day, stdout, part1, part2);
}

test "example" {
    const input =
        \\987654321111111
        \\811111111111119
        \\234234234234278
        \\818181911112111
    ;
    const allocator = std.testing.allocator;

    try std.testing.expectEqual(@as(usize, 357), try part1(input, allocator));
    try std.testing.expectEqual(@as(usize, 3121910778619), try part2(input, allocator));
}

test "maxJoltage" {
    try std.testing.expectEqual(@as(usize, 98), try maxJoltage("987654321111111", 2));
    try std.testing.expectEqual(@as(usize, 89), try maxJoltage("811111111111119", 2));
    try std.testing.expectEqual(@as(usize, 78), try maxJoltage("234234234234278", 2));
    try std.testing.expectEqual(@as(usize, 92), try maxJoltage("818181911112111", 2));

    try std.testing.expectEqual(@as(usize, 987654321111), try maxJoltage("987654321111111", 12));
    try std.testing.expectEqual(@as(usize, 811111111119), try maxJoltage("811111111111119", 12));
    try std.testing.expectEqual(@as(usize, 434234234278), try maxJoltage("234234234234278", 12));
    try std.testing.expectEqual(@as(usize, 888911112111), try maxJoltage("818181911112111", 12));
}
