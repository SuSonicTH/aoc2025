const std = @import("std");
const aozig = @import("aozig");
const stdout = @import("stdout.zig");

pub var alloc: std.mem.Allocator = undefined;

pub fn parse(input: []const u8) ![]const u8 {
    return input;
}

pub fn solve1(input: []const u8) usize {
    var banks = std.mem.tokenizeScalar(u8, input, '\n');
    var res: usize = 0;
    while (banks.next()) |bank| {
        res += maxJoltage2(bank);
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

pub fn solve2(input: []const u8) !usize {
    var banks = std.mem.tokenizeScalar(u8, input, '\n');
    var res: usize = 0;
    while (banks.next()) |bank| {
        res += try maxJoltage12(bank);
    }
    return res;
}

fn maxJoltage12(bank: []const u8) !usize {
    var used: [12]u8 = undefined;
    var last: usize = 0;

    for (0..12) |batt| {
        used[batt] = bank[last];
        for (last + 1..bank.len - 11 + batt) |pos| {
            if (bank[pos] > used[batt]) {
                used[batt] = bank[pos];
                last = pos;
            }
        }
        last += 1;
    }
    return try std.fmt.parseInt(usize, &used, 10);
}

test "example" {
    const input =
        \\987654321111111
        \\811111111111119
        \\234234234234278
        \\818181911112111
    ;

    try std.testing.expectEqual(@as(usize, 98), maxJoltage2("987654321111111"));
    try std.testing.expectEqual(@as(usize, 89), maxJoltage2("811111111111119"));
    try std.testing.expectEqual(@as(usize, 78), maxJoltage2("234234234234278"));
    try std.testing.expectEqual(@as(usize, 92), maxJoltage2("818181911112111"));

    try std.testing.expectEqual(@as(usize, 357), solve1(input));

    try std.testing.expectEqual(@as(usize, 987654321111), try maxJoltage12("987654321111111"));
    try std.testing.expectEqual(@as(usize, 811111111119), try maxJoltage12("811111111111119"));
    try std.testing.expectEqual(@as(usize, 434234234278), try maxJoltage12("234234234234278"));
    try std.testing.expectEqual(@as(usize, 888911112111), try maxJoltage12("818181911112111"));

    try std.testing.expectEqual(@as(usize, 3121910778619), try solve2(input));
}
