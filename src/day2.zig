const std = @import("std");
const stdout = @import("stdout.zig");

pub var alloc: std.mem.Allocator = undefined;

const Range = struct {
    from: usize,
    to: usize,
};

pub fn parse(input: []const u8, allocator: std.mem.Allocator) ![]Range {
    var res = std.array_list.AlignedManaged(Range, null).init(allocator);
    var ranges = std.mem.tokenizeScalar(u8, input[0 .. input.len - 1], ',');
    while (ranges.next()) |range| {
        const dashPos = std.mem.indexOfScalar(u8, range, '-').?;
        try res.append(.{
            .from = try std.fmt.parseInt(usize, range[0..dashPos], 10),
            .to = try std.fmt.parseInt(usize, range[dashPos + 1 ..], 10),
        });
    }
    return try res.toOwnedSlice();
}

pub fn part1(input: []const u8, allocator: std.mem.Allocator) !usize {
    const ranges = try parse(input, allocator);
    defer allocator.free(ranges);

    var sum: usize = 0;
    for (ranges) |range| {
        for (range.from..range.to + 1) |item| {
            if (try isInvalid1(item)) {
                sum += item;
            }
        }
    }
    return sum;
}

fn isInvalid1(number: usize) !bool {
    var buf: [20]u8 = undefined;
    const str = try std.fmt.bufPrint(&buf, "{d}", .{number});
    if (@mod(str.len, 2) != 0) {
        return false;
    }
    const mid = str.len / 2;
    if (std.mem.eql(u8, str[0..mid], str[mid..])) {
        return true;
    }
    return false;
}

pub fn part2(input: []const u8, allocator: std.mem.Allocator) !usize {
    const ranges = try parse(input, allocator);
    defer allocator.free(ranges);

    var sum: usize = 0;
    for (ranges) |range| {
        for (range.from..range.to + 1) |item| {
            if (try isInvalid2(item)) {
                sum += item;
            }
        }
    }
    return sum;
}

fn isInvalid2(number: usize) !bool {
    var buf: [20]u8 = undefined;
    const str = try std.fmt.bufPrint(&buf, "{d}", .{number});
    for (1..(str.len / 2) + 1) |len| {
        if (@mod(str.len, len) == 0) {
            if (try isSubSeqInvalid(str, len)) {
                return true;
            }
        }
    }
    return false;
}

fn isSubSeqInvalid(str: []const u8, seqLen: usize) !bool {
    const subSeq = str.len / seqLen;
    for (1..subSeq) |seq| {
        const first = (seq - 1) * seqLen;
        const second = seq * seqLen;
        if (!std.mem.eql(u8, str[first .. first + seqLen], str[second .. second + seqLen])) {
            return false;
        }
    }
    return true;
}

pub fn main() !void {
    const day = comptime (@src().file[0..std.mem.indexOfScalar(u8, @src().file, '.').?]);
    const input = @embedFile(day ++ ".txt");
    const allocator = std.heap.smp_allocator;

    stdout.printfl("{s} part1: {any} ", .{ day, part1(input, allocator) });
    stdout.printfl("part2: {any} \n", .{part2(input, allocator)});
}

test "example" {
    const input =
        \\11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124
        \\
    ;
    try std.testing.expectEqual(@as(usize, 1227775554), try part1(input, std.testing.allocator));
    try std.testing.expectEqual(@as(usize, 4174379265), try part2(input, std.testing.allocator));
}

test "isInvalid2" {
    try std.testing.expectEqual(true, try isInvalid2(99));
    try std.testing.expectEqual(true, try isInvalid2(111));
    try std.testing.expectEqual(false, try isInvalid2(110));
    try std.testing.expectEqual(true, try isInvalid2(565656));
    try std.testing.expectEqual(false, try isInvalid2(5656565));
    try std.testing.expectEqual(false, try isInvalid2(56565650));
}
