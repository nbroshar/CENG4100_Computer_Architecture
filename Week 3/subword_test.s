# Sub-word memory coverage: every load/store form, all byte offsets + both halves.
    li   x10, 64          # word-aligned scratch base (0x40)
    li   x11, 256         # output address (0x100)
    lui  x1, 0x8090a      # build 0x8090a0b0 (bytes 80 90 a0 b0, all MSBs set)
    addi x1, x1, 0xb0
    sw   x1, 0(x10)       # mem[0x40] = 0x8090a0b0  (full-word init)
    lb   x2, 0(x10)       # 0xb0 -> 0xffffffb0   (signed)
    lb   x3, 1(x10)       # 0xa0 -> 0xffffffa0
    lb   x4, 2(x10)       # 0x90 -> 0xffffff90
    lb   x5, 3(x10)       # 0x80 -> 0xffffff80
    lbu  x6, 0(x10)       # 0xb0 -> 0x000000b0   (unsigned)
    lbu  x7, 3(x10)       # 0x80 -> 0x00000080
    lh   x8, 0(x10)       # 0xa0b0 -> 0xffffa0b0 (signed half, low)
    lh   x9, 2(x10)       # 0x8090 -> 0xffff8090 (signed half, high)
    lhu  x12, 0(x10)      # 0xa0b0 -> 0x0000a0b0 (unsigned half)
    lhu  x13, 2(x10)      # 0x8090 -> 0x00008090
    sb   x6, 1(x10)       # splice byte 0xb0 into lane 1 -> 0x8090b0b0
    sh   x12, 2(x10)      # splice half 0xa0b0 into high half -> 0xa0b0b0b0
    lw   x14, 0(x10)      # read merged word (0xa0b0b0b0)
    sw   x14, 0(x11)      # publish result to output
done:
    j    done
