const std = @import("std");

pub fn toNumber(field: []const u8) !i64 {
    return std.fmt.parseInt(i64, field, 10);
}

pub fn charTou4(char: u8) u4 {
    return @intCast(char - '0');
}

var splitBuffer: [1024]i64 = undefined;

pub fn split(line: []const u8, delimiter: u8) ![]i64 {
    var columit = std.mem.splitScalar(u8, line, delimiter);
    var i: usize = 0;
    while (columit.next()) |column| {
        splitBuffer[i] = try toNumber(column);
        i += 1;
    }
    return splitBuffer[0..i];
}

pub fn Grid(comptime T: type) type {
    return struct {
        const Self = @This();
        allocator: std.mem.Allocator,
        width: usize,
        height: usize,
        data: []T,

        pub fn init(width: usize, height: usize, allocator: std.mem.Allocator) !Self {
            return .{
                .allocator = allocator,
                .width = width,
                .height = height,
                .data = try allocator.alloc(T, width * height),
            };
        }

        pub fn deinit(self: *Self) void {
            self.allocator.free(self.data);
        }

        pub fn boundsCheck(self: *Self, x: usize, y: usize) void {
            if (x < 0) @panic("x less than 0");
            if (y < 0) @panic("y less than 0");
            if (x > self.width) @panic("x more than width");
            if (y > self.height) @panic("y more than height");
        }

        pub fn inBoundsi(self: *Self, x: i64, y: i64) bool {
            if (x < 0 or y < 0 or x >= self.width or y >= self.height) return false;
            return true;
        }

        pub fn inBoundsu(self: *Self, x: usize, y: usize) bool {
            if (x >= self.width or y >= self.height) return false;
            return true;
        }

        pub fn get(self: *Self, x: usize, y: usize) T {
            self.boundsCheck(x, y);
            return self.data[y * self.width + x];
        }

        pub fn set(self: *Self, x: usize, y: usize, value: T) void {
            self.boundsCheck(x, y);
            self.data[y * self.width + x] = value;
        }

        pub fn reset(self: *Self, value: T) void {
            @memset(self.data, value);
        }

        pub fn countAdjacent(self: *Self, x: usize, y: usize, value: T) usize {
            var count: usize = 0;
            inline for ([_]i2{ -1, 0, 1 }) |yv| {
                inline for ([_]i2{ -1, 0, 1 }) |xv| {
                    if (xv == 0 and yv == 0) continue;

                    const yc: i64 = @as(i64, @intCast(y)) + yv;
                    const xc: i64 = @as(i64, @intCast(x)) + xv;

                    if (self.inBoundsi(xc, yc)) {
                        if (self.get(@as(usize, @intCast(xc)), @as(usize, @intCast(yc))) == value) {
                            count += 1;
                        }
                    }
                }
            }
            return count;
        }
    };
}

pub const Dimention = struct {
    width: usize,
    height: usize,
};

fn getInputDimentions(input: []const u8) Dimention {
    const width = std.mem.indexOfScalar(u8, input, '\n').?;
    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    var height: usize = 0;
    while (lines.next() != null) {
        height += 1;
    }
    return .{
        .width = width,
        .height = height,
    };
}

pub fn readGrid(input: []const u8, allocator: std.mem.Allocator) !Grid(u8) {
    const dim = getInputDimentions(input);
    var grid = try Grid(u8).init(dim.width, dim.height, allocator);

    var dest: usize = 0;
    var src: usize = 0;
    for (0..dim.height) |_| {
        @memcpy(grid.data[dest .. dest + dim.width], input[src .. src + dim.width]);
        dest += dim.width;
        src += dim.width + 1;
    }

    return grid;
}

pub fn readAndMapGrid(comptime T: type, comptime convert: fn (char: u8) T, input: []const u8, allocator: std.mem.Allocator) !Grid(T) {
    const dim = getInputDimentions(input);
    var grid = try Grid(T).init(dim.width, dim.height, allocator);

    for (0..dim.height) |y| {
        for (0..dim.width) |x| {
            grid.set(x, y, convert(input[y * (dim.width + 1) + x]));
        }
    }

    return grid;
}

test "readGrid" {
    const input =
        \\0123456789
        \\ABCDEFGHIJ
        \\abcdefghij
        \\
    ;
    const allocator = std.testing.allocator;

    var grid = try readGrid(input, allocator);
    defer grid.deinit();

    try std.testing.expectEqual(10, grid.width);
    try std.testing.expectEqual(3, grid.height);

    try std.testing.expectEqual('0', grid.get(0, 0));
    try std.testing.expectEqual('9', grid.get(9, 0));
    try std.testing.expectEqual('A', grid.get(0, 1));
    try std.testing.expectEqual('a', grid.get(0, 2));
    try std.testing.expectEqual('j', grid.get(9, 2));
}

test "readGrid w/o las EOL" {
    const input =
        \\0123456789
        \\ABCDEFGHIJ
        \\abcdefghij
    ;
    const allocator = std.testing.allocator;

    var grid = try readGrid(input, allocator);
    defer grid.deinit();

    try std.testing.expectEqual(10, grid.width);
    try std.testing.expectEqual(3, grid.height);

    try std.testing.expectEqual('0', grid.get(0, 0));
    try std.testing.expectEqual('9', grid.get(9, 0));
    try std.testing.expectEqual('A', grid.get(0, 1));
    try std.testing.expectEqual('a', grid.get(0, 2));
    try std.testing.expectEqual('j', grid.get(9, 2));
}

test "readAndMapGrid" {
    const input =
        \\0123456789
        \\9876543210
        \\4242424242
        \\
    ;
    const allocator = std.testing.allocator;

    var grid = try readAndMapGrid(u4, charTou4, input, allocator);
    defer grid.deinit();

    try std.testing.expectEqual(10, grid.width);
    try std.testing.expectEqual(3, grid.height);

    try std.testing.expectEqual(0, grid.get(0, 0));
    try std.testing.expectEqual(9, grid.get(9, 0));
    try std.testing.expectEqual(9, grid.get(0, 1));
    try std.testing.expectEqual(4, grid.get(0, 2));
    try std.testing.expectEqual(2, grid.get(9, 2));
}

test "grid functions" {
    const allocator = std.testing.allocator;
    var grid = try Grid(u8).init(10, 10, allocator);
    defer grid.deinit();

    try std.testing.expectEqual(true, grid.inBoundsi(0, 0));
    try std.testing.expectEqual(true, grid.inBoundsi(9, 9));

    try std.testing.expectEqual(true, grid.inBoundsu(0, 0));
    try std.testing.expectEqual(true, grid.inBoundsu(9, 9));

    try std.testing.expectEqual(false, grid.inBoundsi(10, 0));
    try std.testing.expectEqual(false, grid.inBoundsi(0, 10));
    try std.testing.expectEqual(false, grid.inBoundsi(-1, 0));
    try std.testing.expectEqual(false, grid.inBoundsi(0, -1));

    try std.testing.expectEqual(false, grid.inBoundsu(10, 0));
    try std.testing.expectEqual(false, grid.inBoundsu(0, 10));
}
