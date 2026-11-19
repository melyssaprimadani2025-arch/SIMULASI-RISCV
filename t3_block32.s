# =====================================================
# TANTANGAN 3 - Level Lanjut: Sandi Blok 32-bit (4 karakter/word)
# Rumus putaran (8x): c = ROTL32((p XOR K) + 0x9E3779B9, 7)
# Simulator         : RARS (RV32IM)
# =====================================================
.data
.align 2
pesan:   .string "Melyssa Primadani"
.align 2
buf_enc: .space 64
.align 2
buf_dec: .space 64
h_asli:  .string "Pesan asli        : "
h_b_enc: .string "Block32 encode    : "
h_b_dec: .string "Block32 decode    : "
NL:      .string "\n"

.text
main:
    la   a0, h_asli
    la   a1, pesan
    jal  ra, cetak_str

    # Hitung panjang string L dan jumlah blok 32-bit = (L + 4) >> 2
    la   t0, pesan
    li   s0, 0
len_loop:
    lbu  t1, 0(t0)
    beqz t1, len_done
    addi s0, s0, 1
    addi t0, t0, 1
    j    len_loop
len_done:
    addi t0, s0, 4                      # termasuk byte null terminator
    srli s1, t0, 2                      # s1 = jumlah word 32-bit

    # Tentukan kunci 32-bit K = 0x12345678
    li   s2, 0x12345678

    # Enkripsi blok 32-bit
    la   a0, pesan
    la   a1, buf_enc
    mv   a2, s2
    mv   a3, s1
    jal  ra, block32_enc

    # Cetak ciphertext per blok word (hex 32-bit)
    la   a0, h_b_enc
    li   a7, 4
    ecall
    la   t0, buf_enc
    mv   t1, s1
print_w_loop:
    beqz t1, print_w_end
    lw   a0, 0(t0)
    li   a7, 34                         # PrintIntHex
    ecall
    li   a0, 32
    li   a7, 11
    ecall
    addi t0, t0, 4
    addi t1, t1, -1
    j    print_w_loop
print_w_end:
    la   a0, NL
    li   a7, 4
    ecall

    # Dekripsi blok 32-bit
    la   a0, buf_enc
    la   a1, buf_dec
    mv   a2, s2
    mv   a3, s1
    jal  ra, block32_dec

    la   a0, h_b_dec
    la   a1, buf_dec
    jal  ra, cetak_str

    li   a7, 10
    ecall

# block32_enc(a0 = sumber, a1 = tujuan, a2 = K, a3 = jumlah_word)
block32_enc:
    li   t4, 0x9E3779B9                 # konstanta golden ratio
b32_enc_loop:
    beqz a3, b32_enc_end
    lw   t0, 0(a0)                      # baca 4 karakter sekaligus (1 word)
    li   t1, 8                          # 8 putaran
b32_enc_round:
    xor  t0, t0, a2                     # p XOR K
    add  t0, t0, t4                     # + 0x9E3779B9
    slli t2, t0, 7                      # rotasi kiri 7 bit (slli + srli + or)
    srli t3, t0, 25
    or   t0, t2, t3
    addi t1, t1, -1
    bnez t1, b32_enc_round
    sw   t0, 0(a1)                      # simpan 4 byte ciphertext sekaligus
    addi a0, a0, 4
    addi a1, a1, 4
    addi a3, a3, -1
    j    b32_enc_loop
b32_enc_end:
    ret

# block32_dec(a0 = cipher, a1 = tujuan, a2 = K, a3 = jumlah_word)
block32_dec:
    li   t4, 0x9E3779B9
b32_dec_loop:
    beqz a3, b32_dec_end
    lw   t0, 0(a0)
    li   t1, 8                          # 8 putaran terbalik
b32_dec_round:
    srli t2, t0, 7                      # rotasi kanan 7 bit
    slli t3, t0, 25
    or   t0, t2, t3
    sub  t0, t0, t4                     # kurangi 0x9E3779B9
    xor  t0, t0, a2                     # XOR K
    addi t1, t1, -1
    bnez t1, b32_dec_round
    sw   t0, 0(a1)
    addi a0, a0, 4
    addi a1, a1, 4
    addi a3, a3, -1
    j    b32_dec_loop
b32_dec_end:
    ret

cetak_str:
    li   a7, 4
    ecall
    mv   a0, a1
    ecall
    la   a0, NL
    ecall
    ret