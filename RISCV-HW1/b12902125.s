.globl __start

.rodata
    division_by_zero: .string "division by zero"

.text
__start:
    # Read first operand
    li a0, 5
    ecall
    mv s0, a0
    # Read operation
    li a0, 5
    ecall
    mv s1, a0
    # Read second operand
    li a0, 5
    ecall
    mv s2, a0

###################################
#  TODO: Develop your calculator  #
#                                 #
###################################
operation:
    li t0, 0
    beq t0, s1, op_add
    li t0, 1
    beq t0, s1, op_sub
    li t0, 2
    beq t0, s1, op_mul
    li t0, 3
    beq t0, s1, op_div
    li t0, 4
    beq t0, s1, op_min
    li t0, 5
    beq t0, s1, op_power
    li t0, 6
    beq t0, s1, op_fac
    j exit

op_add:
    add s3, s0, s2
    j output

op_sub:
    sub s3, s0, s2
    j output

op_mul:
    mul s3, s0, s2
    j output

op_div:
    beqz s2, division_by_zero_except 
    div s3, s0, s2
    j output

op_min:
    blt s0, s2, op_min_else
    mv s3, s2
    j output

op_min_else:
    mv s3, s0
    j output

op_power:
    li s3, 1
    j power_loop

power_loop:
    beqz s2, output
    mul s3, s3, s0
    addi s2, s2, -1
    j power_loop

op_fac:
    li s3, 1
    j fac_loop

fac_loop:
    beqz s0, output
    mul s3, s3, s0
    addi s0, s0, -1
    j fac_loop

output:
    # Output the result
    li a0, 1                # Print int
    mv a1, s3
    ecall

exit:
    # Exit program(necessary)
    li a0, 10               # Exit
    ecall

division_by_zero_except:
    li a0, 4                # Print string
    la a1, division_by_zero
    ecall
    jal zero, exit
