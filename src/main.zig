const std = @import("std");

pub fn aocRun(comptime src: anytype, run: anytype) !void {
    const day = comptime (src.file[0..std.mem.indexOfScalar(u8, src.file, '.').?]);
    const input = @embedFile(day ++ ".txt");
    const allocator = std.heap.smp_allocator;

    run.stdout.printfl("{s}\n", .{day});

    const start1 = std.time.nanoTimestamp();
    const result1 = run.part1(input, allocator);
    const run1 = @as(f128, @floatFromInt(std.time.nanoTimestamp() - start1));

    run.stdout.print("      part1: {any} ", .{result1});
    printTime(run.stdout, run1);

    const start2 = std.time.nanoTimestamp();
    const result2 = run.part2(input, allocator);
    const run2 = @as(f128, @floatFromInt(std.time.nanoTimestamp() - start2));

    run.stdout.printfl("      part2: {any} ", .{result2});
    printTime(run.stdout, run2);
}

fn printTime(stdout: anytype, time: f128) void {
    if (time > 10_000_000) {
        stdout.printfl("in {d:.0}ms\n", .{time / 1_000_000});
    } else if (time > 1_000_000) {
        stdout.printfl("in {d:.2}ms\n", .{time / 1_000_000});
    } else if (time > 10_000) {
        stdout.printfl("in {d:.0}μs\n", .{time / 1000});
    } else if (time > 1000) {
        stdout.printfl("in {d:.2}μs\n", .{time / 1000});
    } else {
        stdout.printfl("in {d:}ns\n", .{time});
    }
}
