.globl __start

.text
__start:
    li a0, 5
    ecall

    jal ra, recursion
    j output

recursion:
    addi sp, sp, -12
    sw ra, 4(sp)
    sw s0, 0(sp) # 上一層的s0
    sw s1, 8(sp)
    mv s0, a0 # s0 = n

    beqz s0, case_zero
    li t0, 1
    beq s0, t0, case_one


    addi a0, s0, -1
    jal ra, recursion
    slli s1, a0, 1  # t0 = T(n-1)
    addi a0, s0, -2
    jal ra, recursion
    add a0, s1, a0 # a0 = T(n-1) + T(n-2)
    j recursion_end


case_zero:
    li a0, 0
    j recursion_end

case_one:
    li a0, 1
    j recursion_end

recursion_end:
    lw ra, 4(sp)
    lw s0, 0(sp)
    lw s1, 8(sp)
    addi sp, sp, 12
    jr ra


output:
    mv t0, a0
    li a0, 1                # Print int
    mv a1, t0
    ecall
    j exit

exit:
    li a0, 10            
    ecall
