const std = @import("std");

pub fn main(init: std.process.Init) !void {
    const alloc = init.arena.allocator();

    if (init.minimal.args.vector.len < 2) {
        try std.Io.File.stdout().writeStreamingAll(init.io, "mullvad-include: no program specified\n");
        std.process.exit(1);
    }

    const uid = try std.fmt.allocPrintSentinel(alloc, "{}", .{std.os.linux.getuid()}, 0);
    const gid = try std.fmt.allocPrintSentinel(alloc, "{}", .{std.os.linux.getgid()}, 0);
    var argv = try alloc.allocSentinel(
        ?[*:0]const u8,
        11 + init.minimal.args.vector.len - 1,
        null,
    );
    argv[0] = "/usr/bin/ip";
    argv[1] = "netns";
    argv[2] = "exec";
    argv[3] = "mv-incl";
    argv[4] = "/usr/bin/setpriv";
    argv[5] = "--reuid";
    argv[6] = uid;
    argv[7] = "--regid";
    argv[8] = gid;
    argv[9] = "--keep-groups";
    argv[10] = "--";
    for (11.., 1..init.minimal.args.vector.len) |i, j| {
        argv[i] = std.mem.span(init.minimal.args.vector[j]);
    }
    const res = std.os.linux.execve("/usr/bin/ip", argv, init.minimal.environ.block.slice);
    std.log.err("failed to execve /usr/bin/ip: {}\n", .{res});
}
