const std = @import("std");
const calculator = @import("calculator.zig");

const version = "0.1.0";

fn printResult(result: f64, writer: anytype) !void {
    if (result == @trunc(result)) {
        try writer.print("{d}\n", .{@as(i64, @intFromFloat(result))});
    } else {
        try writer.print("{d}\n", .{result});
    }
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len > 1) {
        if (std.mem.eql(u8, args[1], "--version")) {
            try std.io.getStdOut().writer().print("{s}\n", .{version});
            return;
        } else if (std.mem.eql(u8, args[1], "--help")) {
            const help_msg = @embedFile("help.txt");
            try std.io.getStdOut().writer().print("{s}", .{help_msg});
            return;
        } else if (std.mem.eql(u8, args[1], "--formula")) {
            if (args.len < 3) {
                try std.io.getStdErr().writer().print("Error: --formula requires an argument\n", .{});
                return;
            }
            const formula = args[2];
            const result = try calculator.eval(allocator, formula);
            try printResult(result, std.io.getStdOut().writer());
            return;
        } else if (std.mem.eql(u8, args[1], "--file")) {
            if (args.len < 3) {
                try std.io.getStdErr().writer().print("Error: --file requires an argument\n", .{});
                return;
            }
            const file_path = args[2];
            var file = try std.fs.cwd().openFile(file_path, .{});
            defer file.close();

            var buf_reader = std.io.bufferedReader(file.reader());
            var in_stream = buf_reader.reader();

            var line_buf: [1024]u8 = undefined;
            while (try in_stream.readUntilDelimiterOrEof(&line_buf, '\n')) |line| {
                const result = try calculator.eval(allocator, line);
                try printResult(result, std.io.getStdOut().writer());
            }
            return;
        }
    } else {
        // REPL mode
        var stdin_reader = std.io.bufferedReader(std.io.getStdIn().reader());
        const stdin = stdin_reader.reader();
        var line_buf: [1024]u8 = undefined;

        while (true) {
            try std.io.getStdOut().writer().print("> ", .{});
            const line = stdin.readUntilDelimiterOrEof(&line_buf, '\n') catch |err| {
                if (err == error.EndOfStream) {
                    break;
                }
                return err;
            };

            if (line) |l| {
                if (std.mem.eql(u8, l, "quit")) {
                    break;
                }
                const result = calculator.eval(allocator, l) catch |e| {
                    try std.io.getStdErr().writer().print("Error: {s}\n", .{@errorName(e)});
                    continue;
                };
                try printResult(result, std.io.getStdOut().writer());
            } else {
                break;
            }
        }
    }
}

test {
    _ = calculator;
}
