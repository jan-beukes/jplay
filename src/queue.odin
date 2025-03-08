package main

import "core:sync"

import "ffmpeg/avcodec"
import "ffmpeg/avutil"

PACKET_QUEUE_CAP :: 64
FRAME_QUEUE_CAP :: 32

Queue :: struct($T: typeid) {
    items:  []T,
    windex: int,
    rindex: int,
    mutex:  sync.Mutex,
}

queue_init :: proc(q: ^Queue($T), alloc := context.allocator) {
    when T == ^Frame {
        q.items = make([]T, FRAME_QUEUE_CAP)
        for i := 0; i < len(q.items); i += 1 {
            q.items[i] = avutil.frame_alloc()
        }
    } else when T == ^Packet {
        q.items = make([]T, PACKET_QUEUE_CAP)
        for i := 0; i < len(q.items); i += 1 {
            q.items[i] = avcodec.packet_alloc()
        }
    } else {
        unreachable()
    }
}

queue_deinit :: proc(q: ^Queue($T), alloc := context.allocator) {
    for i := 0; i < len(q.items); i += 1 {
        when T == ^Frame {
            avutil.frame_free(&q.items[i])
        } else when T == ^Packet {
            avcodec.packet_free(&q.items[i])
        } else {
            unreachable()
        }
    }
    delete(q.items)
}

queue_size :: proc(q: ^Queue($T)) -> int {
    if q.windex >= q.rindex {
        return q.windex - q.rindex
    } else {
        return len(q.items) - q.rindex + q.windex + 1
    }
}

queue_empty :: proc(q: ^Queue($T)) -> bool {
    sync.mutex_lock(&q.mutex)
    ret := q.rindex == q.windex
    sync.mutex_unlock(&q.mutex)
    return ret
}

queue_full :: proc(q: ^Queue($T)) -> bool {
    sync.mutex_lock(&q.mutex)
    ret := (q.windex + 1) % len(q.items) == q.rindex
    sync.mutex_unlock(&q.mutex)
    return ret
}

queue_back :: proc(q: ^Queue($T)) -> T {
    sync.mutex_lock(&q.mutex)
    ret := q.items[q.windex]
    sync.mutex_unlock(&q.mutex)
    return ret
}

queue_inc :: proc(q: ^Queue($T)) {
    sync.mutex_lock(&q.mutex)
    q.windex = (q.windex + 1) % len(q.items)
    sync.mutex_unlock(&q.mutex)
}

dequeue :: proc(q: ^Queue($T)) -> T {
    sync.mutex_lock(&q.mutex)
    ret := q.items[q.rindex]
    q.rindex = (q.rindex + 1) % len(q.items)
    sync.mutex_unlock(&q.mutex)
    return ret
}

queue_peek :: proc(q: ^Queue($T)) -> T {
    sync.mutex_lock(&q.mutex)
    ret := q.items[q.rindex]
    sync.mutex_unlock(&q.mutex)
    return ret
}

dequeue_no_lock :: proc(q: ^Queue($T)) -> T {
    ret := q.items[q.rindex]
    q.rindex = (q.rindex + 1) % len(q.items)
    return ret
}

queue_peek_no_lock :: #force_inline proc(q: ^Queue($T)) -> T {
    return q.items[q.rindex]
}
