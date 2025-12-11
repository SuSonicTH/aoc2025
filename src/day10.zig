const std = @import("std");
pub const stdout = @import("stdout.zig");

const Lights = struct {
    bulbs: u10,
    mask: u10,
};

const Machine = struct {
    lights: Lights,
    buttons: []u10,
};

pub fn part1(input: []const u8, allocator: std.mem.Allocator) !usize {
    var arena = std.heap.ArenaAllocator.init(allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    var machines = std.array_list.AlignedManaged(Machine, null).init(alloc);
    defer machines.deinit();

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    while (lines.next()) |line| {
        const endOfLights = std.mem.indexOfScalar(u8, line, ']').?;
        var buttons = std.array_list.AlignedManaged(u10, null).init(alloc);

        var start = std.mem.indexOfScalar(u8, line[endOfLights..], '(');
        while (start != null) {
            const end = std.mem.indexOfScalar(u8, line[start.?..], ')').?;
            try buttons.append(getButton(line[start.? + 1 .. end]));
            start = std.mem.indexOfScalar(u8, line[end..], '(');
        }
        try machines.append(.{
            .lights = getLights(line[1..endOfLights]),
            .buttons = try buttons.toOwnedSlice(),
        });
    }
    return 0;
}

fn getLights(lights: []const u8) Lights {
    var value: u10 = 0;
    var mask: u10 = 0;
    var pos: u4 = 0;
    for (lights) |light| {
        if (light == '#') {
            value |= (@as(u10, 1) << pos);
        }
        mask |= (@as(u10, 1) << pos);
        pos += 1;
    }
    return .{
        .bulbs = value,
        .mask = mask,
    };
}

fn getButton(button: []const u8) u10 {
    var value: u10 = 0;
    var digits = std.mem.tokenizeScalar(u8, button, ',');
    while (digits.next()) |digit| {
        const v: u4 = @intCast(digit[0] - '0');
        value |= (@as(u10, 1) << v);
    }
    return value;
}

pub fn part2(input: []const u8, allocator: std.mem.Allocator) !usize {
    _ = input;
    _ = allocator;
    return 0;
}

pub fn main() !void {
    try @import("main.zig").aocRun(@src(), @This());
}

test "example" {
    const input =
        \\
    ;
    try std.testing.expectEqual(@as(usize, 0), try part1(input, std.testing.allocator));
    try std.testing.expectEqual(@as(usize, 0), try part2(input, std.testing.allocator));
}

test "getLights" {
    try std.testing.expectEqual(Lights{ .lights = 0, .mask = 1023 }, getLights(".........."));
    try std.testing.expectEqual(Lights{ .lights = 1, .mask = 1023 }, getLights("#........."));
    try std.testing.expectEqual(Lights{ .lights = 2, .mask = 1023 }, getLights(".#........"));
    try std.testing.expectEqual(Lights{ .lights = 3, .mask = 511 }, getLights("##......."));
    try std.testing.expectEqual(Lights{ .lights = 4, .mask = 255 }, getLights("..#....."));
    try std.testing.expectEqual(Lights{ .lights = 5, .mask = 127 }, getLights("#.#...."));
    try std.testing.expectEqual(Lights{ .lights = 6, .mask = 63 }, getLights(".##..."));
    try std.testing.expectEqual(Lights{ .lights = 512, .mask = 1023 }, getLights(".........#"));
}

test "getButton" {
    try std.testing.expectEqual(@as(u10, 1), getButton("0"));
    try std.testing.expectEqual(@as(u10, 2), getButton("1"));
    try std.testing.expectEqual(@as(u10, 3), getButton("0,1"));
    try std.testing.expectEqual(@as(u10, 5), getButton("0,2"));
    try std.testing.expectEqual(@as(u10, 6), getButton("1,2"));
    try std.testing.expectEqual(@as(u10, 7), getButton("0,1,2"));
    try std.testing.expectEqual(@as(u10, 8), getButton("3"));
    try std.testing.expectEqual(@as(u10, 512), getButton("9"));
    try std.testing.expectEqual(@as(u10, 513), getButton("0,9"));
}
