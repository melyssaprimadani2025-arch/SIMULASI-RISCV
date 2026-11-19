# =====================================================
# TANTANGAN 2 Level Menengah (Bagian C) - FP16 (NIM ...41)
# Nilai konstanta: a = 4.1, b = -1.4
# Simulator: RARS (RV32IMF)
# =====================================================
.data
va:   .float 4.1
vb:   .float -1.4
vbig: .float 300.0
v2k:  .float 2048.0
v1:   .float 1.0
s_a:  .string "a (FP16)    = "
s_b:  .string "b (FP16)    = "
msg1: .string "a + b       = "
msg2: .string "a - b       = "
msg3: .string "a * b       = "
msg4: .string "a / b       = "
msg5: .string "300 * 300   = "
msg6: .string "2048 + 1    = "
s_hx: .string "  pola FP16 = "
NL:   .string "\n"

.text
main:
    # Konversi FP32 -> FP16
    la   t0, va
    lw   a0, 0(t0)
    jal  ra, f2h
    mv   s0, a0                     # s0 = a (FP16)

    la   t0, vb
    lw   a0, 0(t0)
    jal  ra, f2h
    mv   s1, a0                     # s1 = b (FP16)

    la   a0, s_a
    mv   a1, s0
    jal  ra, cetak_h

    la   a0, s_b
    mv   a1, s1
    jal  ra, cetak_h

    # Operasi: FP16 -> FP32, hitung, FP32 -> FP16
    mv   a0, s0
    jal  ra, h2f
    fmv.w.x fs0, a0

    mv   a0, s1
    jal  ra, h2f
    fmv.w.x fs1, a0

    fadd.s ft0, fs0, fs1
    la   a0, msg1
    jal  ra, hasil

    fsub.s ft0, fs0, fs1
    la   a0, msg2
    jal  ra, hasil

    fmul.s ft0, fs0, fs1
    la   a0, msg3
    jal  ra, hasil

    fdiv.s ft0, fs0, fs1
    la   a0, msg4
    jal  ra, hasil

    # Overflow FP16
    la   t0, vbig
    flw  ft1, 0(t0)
    fmul.s ft0, ft1, ft1
    la   a0, msg5
    jal  ra, hasil

    # Presisi mantissa FP16
    la   t0, v2k
    flw  ft1, 0(t0)
    la   t0, v1
    flw  ft2, 0(t0)
    fadd.s ft0, ft1, ft2
    la   a0, msg6
    jal  ra, hasil

    li   a7, 10
    ecall

hasil:
    addi sp, sp, -8
    sw   ra, 4(sp)
    sw   a0, 0(sp)
    fmv.x.w a0, ft0
    jal  ra, f2h
    mv   a1, a0
    lw   a0, 0(sp)
    jal  ra, cetak_h
    lw   ra, 4(sp)
    addi sp, sp, 8
    ret

cetak_h:
    addi sp, sp, -8
    sw   ra, 4(sp)
    sw   a1, 0(sp)
    li   a7, 4
    ecall
    mv   a0, a1
    jal  ra, h2f
    fmv.w.x fa0, a0
    li   a7, 2
    ecall
    la   a0, s_hx
    li   a7, 4
    ecall
    lw   a0, 0(sp)
    li   a7, 34
    ecall
    la   a0, NL
    li   a7, 4
    ecall
    lw   ra, 4(sp)
    addi sp, sp, 8
    ret

f2h:
    srli t0, a0, 16
    li   t6, 0x8000
    and  t0, t0, t6
    srli t1, a0, 23
    andi t1, t1, 0xFF
    li   t6, 0x7FFFFF
    and  t2, a0, t6
    li   t6, 0xFF
    beq  t1, t6, f2h_infnan
    addi t1, t1, -112
    blez t1, f2h_nol
    li   t6, 31
    bge  t1, t6, f2h_inf
    slli t1, t1, 10
    or   t0, t0, t1
    srli t3, t2, 13
    or   t0, t0, t3
    li   t6, 0x1000
    and  t3, t2, t6
    beqz t3, f2h_out
    li   t6, 0xFFF
    and  t4, t2, t6
    bnez t4, f2h_naik
    andi t4, t0, 1
    beqz t4, f2h_out
f2h_naik:
    addi t0, t0, 1
    j    f2h_out
f2h_infnan:
    beqz t2, f2h_inf
    li   t6, 0x7E00
    or   t0, t0, t6
    j    f2h_out
f2h_inf:
    li   t6, 0x7C00
    or   t0, t0, t6
    j    f2h_out
f2h_nol:
f2h_out:
    mv   a0, t0
    ret

h2f:
    li   t6, 0x8000
    and  t0, a0, t6
    slli t0, t0, 16
    srli t1, a0, 10
    andi t1, t1, 0x1F
    andi t2, a0, 0x3FF
    beqz t1, h2f_out
    li   t6, 31
    beq  t1, t6, h2f_infnan
    addi t1, t1, 112
    slli t1, t1, 23
    or   t0, t0, t1
    slli t2, t2, 13
    or   t0, t0, t2
    j    h2f_out
h2f_infnan:
    li   t6, 0x7F800000
    or   t0, t0, t6
    slli t2, t2, 13
    or   t0, t0, t2
h2f_out:
    mv   a0, t0
    ret