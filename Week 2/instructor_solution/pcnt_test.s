# Reference test for the custom-0 popcount instruction.
# pcnt rd, rs1  ->  rd = number of set bits in rs1.
    li   x1, 255      # 0xFF, popcount = 8
    pcnt x2, x1       # x2 = 8
    add  x4, x2, x2   # exercise a normal op too (x4 = 16)
    li   x3, 256
    sw   x2, 0(x3)    # write result (8) to the output address
done:
    j    done
