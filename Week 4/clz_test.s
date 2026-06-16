# Custom functional unit: clz rd, rs1  ->  count leading zeros of rs1.
    li   x1, 1            # 0x00000001 -> clz 31
    clz  x2, x1
    lui  x3, 0x80000      # 0x80000000 -> clz 0
    clz  x4, x3
    lui  x5, 0x00010      # 0x00010000 -> clz 15
    clz  x6, x5
    li   x7, 255          # 0x000000ff -> clz 24
    clz  x8, x7
    li   x9, 0            # 0x00000000 -> clz 32
    clz  x12, x9
    addi x13, x0, 16      # 0x00000010 -> clz 27
    clz  x14, x13
    li   x10, 256
    sw   x4, 0(x10)       # publish clz(0x80000000) = 0
done:
    j    done
