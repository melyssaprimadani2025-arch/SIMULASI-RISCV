# =====================================================
# TANTANGAN 3 - Level Menengah: Vigenere Cipher
# Kunci uji : EMBEDDED
# Simulator : RARS (RV32IM)
# =====================================================
.data
pesan:   .string "Melyssa Primadani"
kunci:   .string "EMBEDDED"
buf_enc: .space 64
buf_dec: .space 64
h_asli:  .string "Pesan asli      : "
h_v_enc: .string "Vigenere encode : "
h_v_dec: .string "Vigenere decode : "
NL:      .string "\n"

.text
main:
    la   a0, h_asli
    la   a1, pesan
    jal  ra, cetak_str

    # Enkripsi Vigenere
    la   a0, pesan
    la   a1, buf_enc
    la   a2, kunci
    jal  ra, vigenere_enc

    la   a0, h_v_enc
    la   a1, buf_enc
    jal  ra, cetak_str

    # Dekripsi Vigenere
    la   a0, buf_enc
    la   a1, buf_dec
    la   a2, kunci
    jal  ra, vigenere_dec

    la   a0, h_v_dec
    la   a1, buf_dec
    jal  ra, cetak_str

    li   a7, 10
    ecall

# vigenere_enc(a0 = sumber, a1 = tujuan, a2 = kunci)
vigenere_enc:
    mv   t4, a2                         # t4 = penunjuk huruf kunci
    li   t5, 26
ve_loop:
    lbu  t0, 0(a0)                      # ambil 1 karakter pesan
    beqz t0, ve_end

    # Cek huruf besar A..Z
    li   t1, 'A'
    li   t2, 'Z'
    blt  t0, t1, ve_cek_kecil
    bgt  t0, t2, ve_cek_kecil
    j    ve_ambil_kunci

ve_cek_kecil:
    # Cek huruf kecil a..z
    li   t1, 'a'
    li   t2, 'z'
    blt  t0, t1, ve_simpan              # bukan huruf -> salin apa adanya
    bgt  t0, t2, ve_simpan

ve_ambil_kunci:
    lbu  t3, 0(t4)                      # ambil huruf kunci saat ini
    bnez t3, ve_kunci_ok
    mv   t4, a2                         # kunci habis -> ulang dari awal
    lbu  t3, 0(t4)
ve_kunci_ok:
    addi t4, t4, 1                      # majukan penunjuk kunci hanya untuk huruf
    addi t3, t3, -65                    # nilai geser K = huruf_kunci - 'A' (0..25)

    sub  t0, t0, t1                     # posisi huruf 0..25
    add  t0, t0, t3                     # (p + K)
    remu t0, t0, t5                     # mod 26
    add  t0, t0, t1                     # kembali ke ASCII

ve_simpan:
    sb   t0, 0(a1)
    addi a0, a0, 1
    addi a1, a1, 1
    j    ve_loop
ve_end:
    sb   zero, 0(a1)
    ret

# vigenere_dec(a0 = cipher, a1 = tujuan, a2 = kunci)
vigenere_dec:
    mv   t4, a2
    li   t5, 26
vd_loop:
    lbu  t0, 0(a0)
    beqz t0, vd_end

    li   t1, 'A'
    li   t2, 'Z'
    blt  t0, t1, vd_cek_kecil
    bgt  t0, t2, vd_cek_kecil
    j    vd_ambil_kunci

vd_cek_kecil:
    li   t1, 'a'
    li   t2, 'z'
    blt  t0, t1, vd_simpan
    bgt  t0, t2, vd_simpan

vd_ambil_kunci:
    lbu  t3, 0(t4)
    bnez t3, vd_kunci_ok
    mv   t4, a2
    lbu  t3, 0(t4)
vd_kunci_ok:
    addi t4, t4, 1
    addi t3, t3, -65                    # K = huruf_kunci - 'A'
    sub  t3, t5, t3                     # geser balik = 26 - K

    sub  t0, t0, t1
    add  t0, t0, t3
    remu t0, t0, t5
    add  t0, t0, t1

vd_simpan:
    sb   t0, 0(a1)
    addi a0, a0, 1
    addi a1, a1, 1
    j    vd_loop
vd_end:
    sb   zero, 0(a1)
    ret

cetak_str:
    li   a7, 4
    ecall
    mv   a0, a1
    ecall
    la   a0, NL
    ecall
    ret