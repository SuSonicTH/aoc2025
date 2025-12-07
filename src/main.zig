const std = @import("std");

pub fn aocRun(comptime day: []const u8, comptime stdout: anytype, part1: anytype, part2: anytype) !void {
    const input = @embedFile(day ++ ".txt");
    const allocator = std.heap.smp_allocator;

    stdout.printfl("{s}\n", .{day});

    const start1 = std.time.nanoTimestamp();
    const result1 = part1(input, allocator);
    const run1 = @as(f128, @floatFromInt(std.time.nanoTimestamp() - start1));

    stdout.print("      part1: {any} ", .{result1});
    printTime(stdout, run1);

    const start2 = std.time.nanoTimestamp();
    const result2 = part2(input, allocator);
    const run2 = @as(f128, @floatFromInt(std.time.nanoTimestamp() - start2));

    stdout.printfl("      part2: {any} ", .{result2});
    printTime(stdout, run2);
}

fn printTime(stdout: anytype, time: f128) void {
    if (time > 100000000) {
        stdout.printfl("in {d:.0}ms\n", .{time / 1000000});
    } else if (time > 1000000) {
        stdout.printfl("in {d:.2}ms\n", .{time / 1000000});
    } else if (time > 1000) {
        stdout.printfl("in {d:.0}μs\n", .{time / 1000});
    } else {
        stdout.printfl("in {d:}ns\n", .{time});
    }
}
