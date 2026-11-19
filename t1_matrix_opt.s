# =====================================================
# TANTANGAN 1 - Level Lanjut: Optimasi Perkalian Matriks 10x10
# Optimasi : Menghapus instruksi mul di loop terdalam mm_k
#            menggunakan pointer (+4 untuk A, +40 untuk X)
# Simulator: RARS (RV32IM)
# =====================================================
.data
A:       .space 400
X:       .space 400
Y:       .space 400
s_iter:  .string "Iterasi "
s_cek:   .string ": checksum = "
s_final: .string "\nMatriks X setelah 20 iterasi (Teroptimasi):\n"
NL:      .string "\n"

.text
main:
    la   s0, A
    la   s1, X
    la   s2, Y
    li   s7, 10
    li   s8, 1000

    # --- Inisialisasi matriks A dan X
    li   s4, 0
init_i:
    li   s5, 0
init_j:
    mul  t0, s4, s7
    add  t0, t0, s5
    slli t1, t0, 2
    add  t2, s0, t1
    add  t3, s4, s5
    li   t4, 3
    remu t3, t3, t4
    sw   t3, 0(t2)
    add  t2, s1, t1
    sw   t0, 0(t2)
    addi s5, s5, 1
    blt  s5, s7, init_j
    addi s4, s4, 1
    blt  s4, s7, init_i

    # --- Loop utama 20 iterasi (dengan pointer di mm_k)
    li   s3, 1
iter_loop:
    li   s4, 0                      # i = 0
mm_i:
    li   s5, 0                      # j = 0
mm_j:
    li   t5, 0                      # sum = 0
    li   s6, 0                      # k = 0

    # Siapkan pointer awal sebelum masuk loop mm_k:
    mul  t0, s4, s7                 # i * 10
    slli t0, t0, 2                  # offset baris i (byte)
    add  t0, s0, t0                 # t0 = pointer A[i][0]

    slli t2, s5, 2                  # offset kolom j (byte)
    add  t2, s1, t2                 # t2 = pointer X[0][j]

mm_k:
    lw   t1, 0(t0)                  # ambil A[i][k] langsung dari pointer
    lw   t3, 0(t2)                  # ambil X[k][j] langsung dari pointer
    mul  t4, t1, t3                 # A[i][k] * X[k][j]
    add  t5, t5, t4                 # sum += hasil kali

    addi t0, t0, 4                  # pointer A maju 1 elemen baris (+4 byte)
    addi t2, t2, 40                 # pointer X turun 1 baris (+40 byte)
    addi s6, s6, 1
    blt  s6, s7, mm_k

    remu t5, t5, s8                 # sum mod 1000
    mul  t0, s4, s7                 # alamat Y[i][j]
    add  t0, t0, s5
    slli t0, t0, 2
    add  t0, s2, t0
    sw   t5, 0(t0)

    addi s5, s5, 1
    blt  s5, s7, mm_j
    addi s4, s4, 1
    blt  s4, s7, mm_i

    # --- Salin Y -> X dan hitung checksum
    li   t0, 0
    li   t6, 0
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

    # --- Cetak checksum iterasi
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

    # --- Cetak matriks akhir
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
    li   a0, 9
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