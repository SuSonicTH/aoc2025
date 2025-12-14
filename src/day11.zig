const std = @import("std");
pub const stdout = @import("stdout.zig");

const maxOutputs = 23;
const maxDevices = 26 * 26 * 26;

const out = nameToId("out");
const you = nameToId("you");
const svr = nameToId("svr");
const dac = nameToId("dac");
const fft = nameToId("fft");

fn parse(input: []const u8, devices: *[maxDevices + 1][maxOutputs]u16) !void {
    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    while (lines.next()) |line| {
        const d = nameToId(line);
        for (0..maxOutputs) |i| {
            const idx = 4 + i * 4 + 1;
            if (idx > line.len) {
                devices[d][i] = 0;
                break;
            }
            devices[d][i] = nameToId(line[idx..]);
        }
    }
}

fn nameToId(name: []const u8) u16 {
    return @as(u16, name[0] - 'a') * 26 * 26 + @as(u16, name[1] - 'a') * 26 + @as(u16, name[2] - 'a') + 1;
}

pub fn part1(input: []const u8, allocator: std.mem.Allocator) !usize {
    _ = allocator;
    var devices: [maxDevices + 1][maxOutputs]u16 = undefined;
    try parse(input, &devices);
    return countPaths1(&devices, you);
}

fn countPaths1(devices: *[maxDevices + 1][maxOutputs]u16, device: u16) usize {
    var count: usize = 0;
    for (devices[device]) |output| {
        switch (output) {
            0 => return count,
            out => return 1,
            else => count += countPaths1(devices, output),
        }
    }
    unreachable;
}

pub fn part2(input: []const u8, allocator: std.mem.Allocator) !usize {
    _ = allocator;
    var devices: [maxDevices + 1][maxOutputs]u16 = undefined;
    try parse(input, &devices);
    var memo: [maxDevices * 4 + 1]?usize = @splat(null);
    return countPaths2(&devices, svr, &memo, 0);
}

const passed_dac: u2 = 1;
const passed_fft: u2 = 2;
const passed_both: u2 = 3;

fn countPaths2(devices: *[maxDevices + 1][maxOutputs]u16, device: u16, memo: *[maxDevices * 4 + 1]?usize, passed: u2) usize {
    const memoKey = @as(usize, device) * 4 + passed;
    if (memo[memoKey]) |cached| {
        return cached;
    }

    var count: usize = 0;
    for (devices[device]) |output| {
        switch (output) {
            0 => break,
            dac => count += countPaths2(devices, output, memo, passed | passed_dac),
            fft => count += countPaths2(devices, output, memo, passed | passed_fft),
            out => return if (passed == passed_both) 1 else 0,
            else => count += countPaths2(devices, output, memo, passed),
        }
    }

    memo[memoKey] = count;
    return count;
}

pub fn main() !void {
    try @import("main.zig").aocRun(@src(), @This());
}

test "nameToId" {
    try std.testing.expectEqual(@as(u16, 1), nameToId("aaa"));
    try std.testing.expectEqual(@as(u16, 2), nameToId("aab"));
    try std.testing.expectEqual(@as(u16, 26), nameToId("aaz"));
    try std.testing.expectEqual(@as(u16, 26 * 26 * 26 - 26 * 26 + 1), nameToId("zaa"));
    try std.testing.expectEqual(@as(u16, 26 * 26 * 26), nameToId("zzz"));
}

test "example1" {
    const input =
        \\aaa: you hhh
        \\you: bbb ccc
        \\bbb: ddd eee
        \\ccc: ddd eee fff
        \\ddd: ggg
        \\eee: out
        \\fff: out
        \\ggg: out
        \\hhh: ccc fff iii
        \\iii: out
    ;
    try std.testing.expectEqual(@as(usize, 5), try part1(input, std.testing.allocator));
}

test "example2" {
    const input =
        \\svr: aaa bbb
        \\aaa: fft
        \\fft: ccc
        \\bbb: tty
        \\tty: ccc
        \\ccc: ddd eee
        \\ddd: hub
        \\hub: fff
        \\eee: dac
        \\dac: fff
        \\fff: ggg hhh
        \\ggg: out
        \\hhh: out
    ;
    try std.testing.expectEqual(@as(usize, 2), try part2(input, std.testing.allocator));
}
