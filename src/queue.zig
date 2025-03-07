const std = @import("std");
const c = @import("c.zig");

const frame_queue_cap = 32;
const packet_queue_cap = 64;

// Thread *safe?* queue
pub fn Queue(comptime T: type) type {
    const cap = if (T == *c.AVFrame) frame_queue_cap else packet_queue_cap;
    return struct {
        const Self = @This();

        items: [cap]T,
        windex: usize = 0,
        rindex: usize = 0,
        mutex: std.Thread.Mutex = std.Thread.Mutex{},

        pub fn init() Self {
            var items: [cap]T = undefined;
            if (T == *c.AVFrame) {
                for (0..items.len) |i| {
                    items[i] = c.av_frame_alloc();
                }
            } else if (T == *c.AVPacket) {
                for (0..items.len) |i| {
                    items[i] = c.av_packet_alloc();
                }
            } else {
                @compileError("Invalid type for Queue");
            }
            return .{ .items = items };
        }

        pub fn size(self: Self) usize {
            if (self.windex >= self.rindex) {
                return self.windex - self.rindex;
            } else {
                return self.items.len - self.rindex + self.windex + 1;
            }
        }

        pub fn empty(self: Self) bool {
            self.mutex.lock();
            const ret = self.rindex == self.windex;
            self.mutex.unlock();
            return ret;
        }

        pub fn full(self: Self) bool {
            self.mutex.lock();
            const ret = (self.windex + 1) % self.items.len == self.rindex;
            self.mutex.unlock();
            return ret;
        }

        pub fn back(self: *Self) T {
            self.mutex.lock();
            const ret = self.items[self.windex];
            self.mutex.unlock();
            return ret;
        }

        pub fn inc(self: *Self) void {
            self.mutex.lock();
            self.windex = (self.windex + 1) % self.items.len;
            self.mutex.unlock();
        }

        pub fn dequeue(self: *Self) T {
            self.mutex.lock();
            const ret = self.items[self.rindex];
            self.rindex = (self.rindex + 1) % self.items.len;
            self.mutex.unlock();
            return ret;
        }

        pub fn peek(self: Self) T {
            self.mutex.lock();
            const ret = self.items[self.rindex];
            self.mutex.unlock();
            return ret;
        }
    };
}
