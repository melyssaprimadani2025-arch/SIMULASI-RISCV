# =====================================================
# TANTANGAN 1 - Level Menengah: Simulasi Difusi Panas 10x10
# Kondisi batas : Baris 0 (tepi atas) = 100, tepi lain = 0
# Rumus sel dalam: X_baru[i][j] = (atas + bawah + kiri + kanan) >> 2
# Simulator      : RARS (RV32IM)
# =====================================================
.data
X:       .space 400                  # buffer suhu saat ini (10x10 word)
Y:       .space 400                  # buffer suhu baru (10x10 word)
s_iter:  .string "Iterasi "
s_cek:   .string ": checksum = "
s_final: .string "\nDistribusi suhu pelat X setelah 20 iterasi:\n"
NL:      .string "\n"

.text
main:
    la   s1, X                      # s1 = alamat buffer X
    la   s2, Y                      # s2 = alamat buffer Y
    li   s7, 10                     # s7 = N = 10
    li   s9, 9                      # s9 = batas atas indeks sel dalam (1..8)

    # --- Inisialisasi: baris 0 = 100, sel lainnya = 0 pada kedua buffer
    li   s4, 0                      # i = 0
init_i:
    li   s5, 0                      # j = 0
init_j:
    mul  t0, s4, s7                 # indeks linear = i*10 + j
    add  t0, t0, s5
    slli t1, t0, 2                  # offset byte = indeks * 4
    li   t3, 0                      # nilai default = 0
    bnez s4, init_simpan            # jika bukan baris 0, tetap 0
    li   t3, 100                    # tepi atas (baris 0) bersuhu tetap 100
init_simpan:
    add  t2, s1, t1
    sw   t3, 0(t2)                  # simpan ke X[i][j]
    add  t2, s2, t1
    sw   t3, 0(t2)                  # salin kondisi batas yang sama ke Y[i][j]
    addi s5, s5, 1
    blt  s5, s7, init_j
    addi s4, s4, 1
    blt  s4, s7, init_i

    # --- Loop utama 20 iterasi difusi panas
    li   s3, 1                      # iterasi = 1
iter_loop:
    li   s4, 1                      # i mulai dari 1 (sel dalam)
panas_i:
    li   s5, 1                      # j mulai dari 1 (sel dalam)
panas_j:
    mul  t0, s4, s7                 # indeks linear sel (i, j)
    add  t0, t0, s5
    slli t0, t0, 2                  # offset byte sel (i, j)
    add  t1, s1, t0                 # t1 = alamat X[i][j]

    lw   t2, -40(t1)                # atas  = X[i-1][j] (mundur 10 word = -40 byte)
    lw   t3, 40(t1)                 # bawah = X[i+1][j] (maju 10 word   = +40 byte)
    add  t5, t2, t3                 # t5 = atas + bawah
    lw   t2, -4(t1)                 # kiri  = X[i][j-1] (mundur 1 word  = -4 byte)
    add  t5, t5, t2
    lw   t2, 4(t1)                  # kanan = X[i][j+1] (maju 1 word    = +4 byte)
    add  t5, t5, t2
    srli t5, t5, 2                  # bagi 4 menggunakan geser kanan logika 2 bit

    add  t1, s2, t0                 # alamat Y[i][j]
    sw   t5, 0(t1)                  # simpan suhu baru ke buffer Y

    addi s5, s5, 1
    blt  s5, s9, panas_j            # ulangi untuk j = 1..8
    addi s4, s4, 1
    blt  s4, s9, panas_i            # ulangi untuk i = 1..8

    # --- Salin Y -> X sekaligus hitung checksum seluruh pelat (100 sel)
    li   t0, 0
    li   t6, 0                      # checksum
    li   t1, 100
copy_loop:
    slli t2, t0, 2
    add  t3, s2, t2
    lw   t4, 0(t3)
    add  t3, s1, t2
    sw   t4, 0(t3)
    add  t6, t6, t4
    addi t0, t0, 1
    blt  t0, t1, copy_loop

    # --- Cetak "Iterasi k: checksum = c"
    la   a0, s_iter
    li   a7, 4
    ecall
    mv   a0, s3
    li   a7, 1
    ecall
    la   a0, s_cek
    li   a7, 4
    ecall
    mv   a0, t6
    li   a7, 1
    ecall
    la   a0, NL
    li   a7, 4
    ecall

    addi s3, s3, 1
    li   t0, 20
    ble  s3, t0, iter_loop

    # --- Cetak matriks suhu akhir setelah 20 iterasi
    la   a0, s_final
    li   a7, 4
    ecall
    li   s4, 0
pr_i:
    li   s5, 0
pr_j:
    mul  t0, s4, s7
    add  t0, t0, s5
    slli t0, t0, 2
    add  t0, s1, t0
    lw   a0, 0(t0)
    li   a7, 1
    ecall
    li   a0, 9                      # karakter TAB
    li   a7, 11
    ecall
    addi s5, s5, 1
    blt  s5, s7, pr_j
    la   a0, NL
    li   a7, 4
    ecall
    addi s4, s4, 1
    blt  s4, s7, pr_i

    li   a7, 10
    ecall