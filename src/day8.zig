const std = @import("std");
pub const stdout = @import("stdout.zig");

const Box = struct {
    x: i32,
    y: i32,
    z: i32,
    circuit: usize = 0,
};

const Pair = struct {
    a: *Box,
    b: *Box,
    distance: u64,
};

const Data = struct {
    boxes: std.array_list.AlignedManaged(Box, null),
    pairs: std.array_list.AlignedManaged(Pair, null),

    fn init(input: []const u8, allocator: std.mem.Allocator) !Data {
        var lines = std.mem.tokenizeScalar(u8, input, '\n');
        var boxes = std.array_list.AlignedManaged(Box, null).init(allocator);

        while (lines.next()) |line| {
            var numbers = std.mem.tokenizeScalar(u8, line, ',');
            try boxes.append(.{
                .x = try std.fmt.parseInt(i32, numbers.next().?, 10),
                .y = try std.fmt.parseInt(i32, numbers.next().?, 10),
                .z = try std.fmt.parseInt(i32, numbers.next().?, 10),
            });
        }

        var pairs = std.array_list.AlignedManaged(Pair, null).init(allocator);

        for (0..boxes.items.len) |a| {
            for (a + 1..boxes.items.len) |b| {
                try pairs.append(.{
                    .a = &boxes.items[a],
                    .b = &boxes.items[b],
                    .distance = getDistance(boxes.items[a], boxes.items[b]),
                });
            }
        }
        std.mem.sortUnstable(Pair, pairs.items, {}, distanceSort);

        return .{
            .boxes = boxes,
            .pairs = pairs,
        };
    }

    fn deinit(self: *Data) void {
        self.boxes.deinit();
        self.pairs.deinit();
    }

    fn getDistance(a: Box, b: Box) u64 {
        const dx = @as(i64, a.x - b.x);
        const dy = @as(i64, a.y - b.y);
        const dz = @as(i64, a.z - b.z);
        return @abs(dx * dx + dy * dy + dz * dz);
    }

    fn distanceSort(_: void, a: Pair, b: Pair) bool {
        return a.distance < b.distance;
    }
};

const Circuit = struct {
    circuits: std.array_list.AlignedManaged(usize, null),
    boxes: usize,

    fn init(boxes: usize, allocator: std.mem.Allocator) !Circuit {
        var circuits = std.array_list.AlignedManaged(usize, null).init(allocator);
        try circuits.append(1);
        return .{
            .circuits = circuits,
            .boxes = boxes,
        };
    }

    fn deinit(self: *Circuit) void {
        self.circuits.deinit();
    }

    fn getNew(self: *Circuit) !usize {
        for (self.circuits.items, 0..) |c, i| {
            if (c == 0) {
                return i;
            }
        }
        try self.circuits.append(0);
        return self.circuits.items.len - 1;
    }

    fn add(self: *Circuit, circuit: usize, v: usize) void {
        self.circuits.items[circuit] += v;
    }

    fn remove(self: *Circuit, circuit: usize) void {
        self.circuits.items[circuit] = 0;
    }

    fn getSorted(self: *Circuit) []usize {
        std.mem.sortUnstable(usize, self.circuits.items, {}, std.sort.desc(usize));
        return self.circuits.items;
    }

    fn allConnected(self: *Circuit) bool {
        return self.circuits.items[1] == self.boxes;
    }
};

var testing = false;

pub fn part1(input: []const u8, allocator: std.mem.Allocator) !usize {
    var data = try Data.init(input, allocator);
    defer data.deinit();

    const boxes = data.boxes;
    const pairs = data.pairs;

    var circuits = try Circuit.init(boxes.items.len, allocator);
    defer circuits.deinit();

    const maximumConenctions: usize = if (testing) 10 else 1000;
    for (pairs.items[0..maximumConenctions]) |pair| {
        if (pair.a.circuit != pair.b.circuit or pair.a.circuit == 0) {
            if (pair.a.circuit == 0 and pair.b.circuit == 0) {
                const c = try circuits.getNew();
                circuits.add(c, 2);
                pair.a.circuit = c;
                pair.b.circuit = c;
            } else if (pair.a.circuit == 0) {
                pair.a.circuit = pair.b.circuit;
                circuits.add(pair.a.circuit, 1);
            } else if (pair.b.circuit == 0) {
                pair.b.circuit = pair.a.circuit;
                circuits.add(pair.b.circuit, 1);
            } else {
                const ca = pair.a.circuit;
                const cb = pair.b.circuit;
                for (boxes.items) |*item| {
                    if (item.circuit == cb) {
                        item.circuit = ca;
                        circuits.add(ca, 1);
                    }
                }
                circuits.remove(cb);
            }
        }
    }

    const sorted = circuits.getSorted();
    return sorted[0] * sorted[1] * sorted[2];
}

pub fn part2(input: []const u8, allocator: std.mem.Allocator) !usize {
    var data = try Data.init(input, allocator);
    defer data.deinit();

    const boxes = data.boxes;
    const pairs = data.pairs;

    var circuits = try Circuit.init(boxes.items.len, allocator);
    defer circuits.deinit();

    for (pairs.items) |pair| {
        if (pair.a.circuit != pair.b.circuit or pair.a.circuit == 0) {
            if (pair.a.circuit == 0 and pair.b.circuit == 0) {
                const c = try circuits.getNew();
                circuits.add(c, 2);
                pair.a.circuit = c;
                pair.b.circuit = c;
            } else if (pair.a.circuit == 0) {
                pair.a.circuit = pair.b.circuit;
                circuits.add(pair.a.circuit, 1);
            } else if (pair.b.circuit == 0) {
                pair.b.circuit = pair.a.circuit;
                circuits.add(pair.b.circuit, 1);
            } else {
                const ca = pair.a.circuit;
                const cb = pair.b.circuit;
                const replace = if (ca < cb) cb else ca;
                const with = if (ca < cb) ca else cb;
                for (boxes.items) |*item| {
                    if (item.circuit == replace) {
                        item.circuit = with;
                        circuits.add(with, 1);
                    }
                }
                circuits.remove(replace);
            }
            if (circuits.allConnected()) {
                return @as(usize, @intCast(pair.a.x)) * @as(usize, @intCast(pair.b.x));
            }
        }
    }

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
    try std.testing.expectEqual(@as(usize, 25272), try part2(input, std.testing.allocator));

    testing = false;
    try std.testing.expectEqual(@as(usize, 330786), try part1(@embedFile("day8.txt"), std.testing.allocator));
    try std.testing.expectEqual(@as(usize, 3276581616), try part2(@embedFile("day8.txt"), std.testing.allocator));
}
