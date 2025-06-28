const std = @import("std");
const testing = std.testing;

pub fn eval(allocator: std.mem.Allocator, formula: []const u8) !f64 {
    var stack = std.ArrayList(f64).init(allocator);
    defer stack.deinit();

    var tokens = std.mem.splitScalar(u8, formula, ' ');
    while (tokens.next()) |token| {
        if (std.fmt.parseFloat(f64, token)) |number| {
            try stack.append(number);
        } else |_| {
            const b = stack.pop() orelse return error.InvalidFormula;
            const a = stack.pop() orelse return error.InvalidFormula;
            if (std.mem.eql(u8, token, "+")) {
                try stack.append(a + b);
            } else if (std.mem.eql(u8, token, "-")) {
                try stack.append(a - b);
            } else if (std.mem.eql(u8, token, "*")) {
                try stack.append(a * b);
            } else if (std.mem.eql(u8, token, "/")) {
                try stack.append(a / b);
            } else {
                return error.InvalidFormula;
            }
        }
    }

    if (stack.items.len != 1) {
        return error.InvalidFormula;
    }

    return stack.items[0];
}

test "eval single number" {
    const allocator = testing.allocator;
    const result = try eval(allocator, "5");
    try testing.expectEqual(result, 5.0);

    const result2 = try eval(allocator, "123.45");
    try testing.expectEqual(result2, 123.45);
}

test "simple subtraction" {
    const allocator = testing.allocator;
    const result = try eval(allocator, "10 3 -");
    try testing.expectEqual(result, 7.0);
}

test "simple multiplication" {
    const allocator = testing.allocator;
    const result = try eval(allocator, "5 6 *");
    try testing.expectEqual(result, 30.0);
}

test "simple division" {
    const allocator = testing.allocator;
    const result = try eval(allocator, "20 4 /");
    try testing.expectEqual(result, 5.0);
}

test "complex formula" {
    const allocator = testing.allocator;
    const result = try eval(allocator, "5 3 4 + * 2 /");
    try testing.expectEqual(result, 17.5);
}

test "empty formula" {
    const allocator = testing.allocator;
    const result = eval(allocator, "");
    try testing.expectError(error.InvalidFormula, result);
}

test "invalid token" {
    const allocator = testing.allocator;
    const result = eval(allocator, "1 2 foo");
    try testing.expectError(error.InvalidFormula, result);
}

test "not enough numbers on stack" {
    const allocator = testing.allocator;
    const result = eval(allocator, "1 +");
    try testing.expectError(error.InvalidFormula, result);
}

test "too many numbers on stack" {
    const allocator = testing.allocator;
    const result = eval(allocator, "1 2 3 +");
    try testing.expectError(error.InvalidFormula, result);
}

test "division by zero" {
    const allocator = testing.allocator;
    const result = try eval(allocator, "1 0 /");
    try testing.expect(result == std.math.inf(f64));
}
