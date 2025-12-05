const std = @import("std");
const aozig = @import("aozig");

pub var alloc: std.mem.Allocator = undefined;

const Range = struct {
    from: usize,
    to: usize,
    deleted: bool = false,
};

const Data = struct {
    fresh: std.array_list.AlignedManaged(Range, null),
    products: std.array_list.AlignedManaged(usize, null),

    fn deinit(self: Data) void {
        self.fresh.deinit();
        self.products.deinit();
    }

    fn isFresh(self: Data, id: usize) bool {
        for (self.fresh.items) |range| {
            if (id >= range.from and id <= range.to) {
                return true;
            }
        }
        return false;
    }
};

pub fn parse(input: []const u8) !Data {
    var lines = std.mem.tokenizeScalar(u8, input, '\n');

    var data: Data = .{
        .fresh = std.array_list.AlignedManaged(Range, null).init(alloc),
        .products = std.array_list.AlignedManaged(usize, null).init(alloc),
    };

    while (lines.next()) |range| {
        if (std.mem.indexOfScalar(u8, range, '-')) |dashPos| {
            try data.fresh.append(.{
                .from = try std.fmt.parseInt(usize, range[0..dashPos], 10),
                .to = try std.fmt.parseInt(usize, range[dashPos + 1 ..], 10),
            });
        } else {
            try data.products.append(try std.fmt.parseInt(usize, range, 10));
            while (lines.next()) |id| {
                try data.products.append(try std.fmt.parseInt(usize, id, 10));
            }
        }
    }
    return data;
}

pub fn solve1(data: Data) usize {
    var count: usize = 0;
    for (data.products.items) |id| {
        if (data.isFresh(id)) {
            count += 1;
        }
    }
    return count;
}

pub fn solve2(data: Data) !usize {
    var fresh = data.fresh;
    std.mem.sort(Range, fresh.items, {}, rangeSort);

    for (0..fresh.items.len - 1) |i| {
        const current = fresh.items[i];
        const n = i + 1;
        const next = fresh.items[n];
        if (current.to >= next.from) {
            fresh.items[n].from = @min(current.from, next.from);
            fresh.items[n].to = @max(current.to, next.to);
            fresh.items[i].deleted = true;
        }
    }

    var count: usize = 0;
    for (data.fresh.items) |range| {
        if (!range.deleted) {
            count += range.to - range.from + 1;
        }
    }
    return count;
}

fn rangeSort(_: void, a: Range, b: Range) bool {
    return a.from < b.from;
}

test "example" {
    alloc = std.testing.allocator;
    const input =
        \\3-5
        \\10-14
        \\16-20
        \\12-18
        \\
        \\1
        \\5
        \\8
        \\11
        \\17
        \\32
    ;
    const data: Data = try parse(input);
    defer data.deinit();

    try std.testing.expectEqual(@as(usize, 3), solve1(data));
    try std.testing.expectEqual(@as(usize, 14), try solve2(data));
}
