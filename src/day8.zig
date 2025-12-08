const std = @import("std");
pub const stdout = @import("stdout.zig");

const Box = struct {
    x: i32,
    y: i32,
    z: i32,
    circuit: usize = 0,
};

const Distance = struct {
    a: *Box,
    b: *Box,
    distance: u64,
};

var testing = false;
pub fn part1(input: []const u8, allocator: std.mem.Allocator) !usize {
    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    var boxes = std.array_list.AlignedManaged(Box, null).init(allocator);
    defer boxes.deinit();

    while (lines.next()) |line| {
        var numbers = std.mem.tokenizeScalar(u8, line, ',');
        try boxes.append(.{
            .x = try std.fmt.parseInt(i32, numbers.next().?, 10),
            .y = try std.fmt.parseInt(i32, numbers.next().?, 10),
            .z = try std.fmt.parseInt(i32, numbers.next().?, 10),
        });
    }

    var pairs = std.array_list.AlignedManaged(Distance, null).init(allocator);
    defer pairs.deinit();

    for (0..boxes.items.len) |a| {
        for (a + 1..boxes.items.len) |b| {
            try pairs.append(.{
                .a = &boxes.items[a],
                .b = &boxes.items[b],
                .distance = getDistance(boxes.items[a], boxes.items[b]),
            });
        }
    }
    std.mem.sortUnstable(Distance, pairs.items, {}, distanceSort);

    var circuit: usize = 0;
    const maximumConenctions: usize = if (testing) 10 else 1000;
    for (pairs.items[0..maximumConenctions]) |pair| {
        if (pair.a.circuit != pair.b.circuit or pair.a.circuit == 0) {
            if (pair.a.circuit == 0 and pair.b.circuit == 0) {
                circuit += 1;
                pair.a.circuit = circuit;
                pair.b.circuit = circuit;
            } else if (pair.a.circuit == 0) {
                pair.a.circuit = pair.b.circuit;
            } else if (pair.b.circuit == 0) {
                pair.b.circuit = pair.a.circuit;
            } else {
                circuit += 1;
                const ca = pair.a.circuit;
                const cb = pair.b.circuit;
                for (boxes.items) |*item| {
                    if (item.circuit == ca or item.circuit == cb) {
                        item.circuit = circuit;
                    }
                }
            }
        }
    }

    var circuits = try allocator.alloc(usize, circuit + 1);
    defer allocator.free(circuits);
    @memset(circuits, 0);

    for (boxes.items) |box| {
        if (box.circuit != 0) {
            circuits[box.circuit] += 1;
        }
    }
    std.mem.sort(usize, circuits, {}, std.sort.desc(usize));

    return circuits[0] * circuits[1] * circuits[2];
}

fn getDistance(a: Box, b: Box) u64 {
    const dx = @as(i64, a.x - b.x);
    const dy = @as(i64, a.y - b.y);
    const dz = @as(i64, a.z - b.z);
    return @abs(dx * dx + dy * dy + dz * dz);
}
fn distanceSort(_: void, a: Distance, b: Distance) bool {
    return a.distance < b.distance;
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
    testing = true;
    const input =
        \\162,817,812
        \\57,618,57
        \\906,360,560
        \\592,479,940
        \\352,342,300
        \\466,668,158
        \\542,29,236
        \\431,825,988
        \\739,650,466
        \\52,470,668
        \\216,146,977
        \\819,987,18
        \\117,168,530
        \\805,96,715
        \\346,949,466
        \\970,615,88
        \\941,993,340
        \\862,61,35
        \\984,92,344
        \\425,690,689
    ;
    try std.testing.expectEqual(@as(usize, 40), try part1(input, std.testing.allocator));
    try std.testing.expectEqual(@as(usize, 0), try part2(input, std.testing.allocator));
}
