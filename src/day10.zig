const std = @import("std");
pub const stdout = @im
port("stdout.zig");

const Machine1 = struct {
    lights: u10,
    buttons: []u10,
};

pub fn part1(input: []const u8, allocator: std.mem.Allocator) !usize {
    var arena = std.heap.ArenaAllocator.init(allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    var machines = std.array_list.AlignedManaged(Machine1, null).init(alloc);
    defer machines.deinit();

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    while (lines.next()) |line| {
        const endOfLights = std.mem.indexOfScalar(u8, line, ']').?;
        var buttons = std.array_list.AlignedManaged(u10, null).init(alloc);
        var buttonIterator = std.mem.tokenizeScalar(u8, line[endOfLights + 1 ..], ')');
        while (buttonIterator.next()) |button| {
            if (button[1] == '(') {
                try buttons.append(getButton(button[2..]));
            }
        }
        try machines.append(.{
            .lights = getLights(line[1..endOfLights]),
            .buttons = try buttons.toOwnedSlice(),
        });
    }

    var count: usize = 0;
    for (machines.items) |*machine| {
        for (1..machine.buttons.len + 1) |numberOfButtons| {
            if (hasSolution(machine, numberOfButtons)) {
                count += numberOfButtons;
                break;
            }
        }
    }
    return count;
}

fn getLights(lights: []const u8) u10 {
    var value: u10 = 0;
    var pos: u4 = 0;
    for (lights) |light| {
        if (light == '#') {
            value |= (@as(u10, 1) << pos);
        }
        pos += 1;
    }
    return value;
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

fn hasSolution(machine: *Machine1, numberOfButtons: usize) bool {
    var state: [13]usize = undefined;
    for (0..numberOfButtons) |i| {
        state[i] = i;
    }

    while (true) {
        var result: u10 = 0;
        for (0..numberOfButtons) |i| {
            result ^= machine.buttons[state[i]];
        }

        if (machine.lights == result) return true;

        for (0..numberOfButtons) |i| {
            const s = numberOfButtons - i - 1;
            state[s] += 1;
            if (state[s] == machine.buttons.len - i) {
                state[s] = s;
                if (s == 0) return false;
            } else {
                break;
            }
        }
    }
    unreachable;
}

const Machine2 = struct {
    buttons: [][]u8,
    joltages: []u8,
};

pub fn part2(input: []const u8, allocator: std.mem.Allocator) !usize {
    var arena = std.heap.ArenaAllocator.init(allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    var machines = std.array_list.AlignedManaged(Machine2, null).init(alloc);
    defer machines.deinit();

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    while (lines.next()) |line| {
        const endOfLights = std.mem.indexOfScalar(u8, line, ']').?;
        var buttons = std.array_list.AlignedManaged([]u8, null).init(alloc);
        var buttonIterator = std.mem.tokenizeScalar(u8, line[endOfLights + 1 ..], ')');
        var joltages: []u8 = undefined;
        while (buttonIterator.next()) |button| {
            if (button[1] == '(') {
                try buttons.append(try getListOfValues(button[2..], alloc));
            } else {
                joltages = try getListOfValues(button[2 .. button.len - 1], alloc);
            }
        }
        stdout.printfl("{s}\n->{any}\n->{any}\n", .{ line, buttons.items, joltages });
        try machines.append(.{
            .buttons = try buttons.toOwnedSlice(),
            .joltages = joltages,
        });
    }

    return 0;
}

fn getListOfValues(button: []const u8, allocator: std.mem.Allocator) ![]u8 {
    var values = std.array_list.AlignedManaged(u8, null).init(allocator);
    var numbers = std.mem.tokenizeScalar(u8, button, ',');
    while (numbers.next()) |number| {
        try values.append(try std.fmt.parseInt(u8, number, 10));
    }
    return values.toOwnedSlice();
}

pub fn main() !void {
    try @import("main.zig").aocRun(@src(), @This());
}

test "example" {
    const input =
        \\[.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}
        \\[...#.] (0,2,3,4) (2,3) (0,4) (0,1,2) (1,2,3,4) {7,5,12,7,2}
        \\[.###.#] (0,1,2,3,4) (0,3,4) (0,1,2,4,5) (1,2) {10,11,11,5,10,5}
    ;
    try std.testing.expectEqual(@as(usize, 1), try part1("[.##.] (1,2) {3,5,4,7}", std.testing.allocator));
    try std.testing.expectEqual(@as(usize, 2), try part1("[.##.] (1) (2) {3,5,4,7}", std.testing.allocator));
    try std.testing.expectEqual(@as(usize, 2), try part1("[.##.] (0) (1) (2) {3,5,4,7}", std.testing.allocator));

    try std.testing.expectEqual(@as(usize, 2), try part1("[.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}", std.testing.allocator));
    try std.testing.expectEqual(@as(usize, 3), try part1("[...#.] (0,2,3,4) (2,3) (0,4) (0,1,2) (1,2,3,4) {7,5,12,7,2}", std.testing.allocator));
    try std.testing.expectEqual(@as(usize, 2), try part1("[.###.#] (0,1,2,3,4) (0,3,4) (0,1,2,4,5) (1,2) {10,11,11,5,10,5}", std.testing.allocator));

    try std.testing.expectEqual(@as(usize, 7), try part1(input, std.testing.allocator));

    try std.testing.expectEqual(@as(usize, 0), try part2(input, std.testing.allocator));
}

test "getLights" {
    try std.testing.expectEqual(0, getLights(".........."));
    try std.testing.expectEqual(1, getLights("#........."));
    try std.testing.expectEqual(2, getLights(".#........"));
    try std.testing.expectEqual(3, getLights("##......."));
    try std.testing.expectEqual(4, getLights("..#....."));
    try std.testing.expectEqual(5, getLights("#.#...."));
    try std.testing.expectEqual(6, getLights(".##..."));
    try std.testing.expectEqual(512, getLights(".........#"));
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
