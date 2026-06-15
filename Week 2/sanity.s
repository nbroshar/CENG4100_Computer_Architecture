# Coverage program: exercises every datapath path the core implements.
# Values are not meaningful -- the lockstep harness checks EVERY instruction
# against the golden model, so any divergence is caught regardless of values.
    li    x1, 100
    li    x2, 7
    add   x3, x1, x2
    sub   x4, x1, x2
    and   x5, x1, x2
    or    x6, x1, x2
    xor   x7, x1, x2
    sll   x8, x1, x2
    srl   x9, x1, x2
    sra   x10, x4, x2
    slt   x11, x2, x1
    sltu  x12, x1, x2
    slti  x13, x2, 50
    sltiu x14, x1, 50
    xori  x15, x1, 15
    ori   x16, x2, 32
    andi  x17, x1, 12
    slli  x18, x2, 3
    srli  x19, x1, 2
    srai  x20, x4, 1
    lui   x21, 0x12345
    auipc x22, 1
    sw    x3, 0(x0)
    lw    x23, 0(x0)
    beq   x23, x3, l1
    li    x24, 1
l1:
    bne   x1, x2, l2
    li    x24, 2
l2:
    blt   x2, x1, l3
    li    x24, 3
l3:
    bge   x1, x2, l4
    li    x24, 4
l4:
    bltu  x2, x1, l5
    li    x24, 5
l5:
    bgeu  x1, x2, l6
    li    x24, 6
l6:
    jal   x25, l7
    li    x24, 7
l7:
    auipc x26, 0
    jalr  x0, 12(x26)
    li    x24, 8
    addi  x27, x0, 1
    li    x28, 0x100
    sw    x3, 0(x28)
done:
    j     done
