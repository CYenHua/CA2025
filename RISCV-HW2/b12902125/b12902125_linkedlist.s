.globl	__start

.rodata
        msg: .asciiz "Empty!"
        newline: .asciiz "\n"
.text

push_front_list:             
        ### save ra、s0 ###
        addi    sp, sp, -16
        sw      ra, 12(sp)                      
        sw      s0, 8(sp)                       
        sw      s1, 4(sp)                       
        mv      s1, a1
        mv      s0, a0
        ### if(list == NULL)return; ###
        beqz    a0, LBB0_2
        ### node_t *new_node = (node_t*)sbrk(sizeof(*new_node)); ###
        li      a0, 8
        call    sbrk
        ### new_node->value = value; ###
        sw      s1, 0(a0)
        ### new_node->next = list->head; ###
        lw      a1, 0(s0)
        sw      a1, 4(a0)
        ### list->head = new_node; ###
        sw      a0, 0(s0)
LBB0_2:
        ### exit handling ###
        lw      ra, 12(sp)                      
        lw      s0, 8(sp)                       
        lw      s1, 4(sp)                       
        addi    sp, sp, 16
        ret
        
print_list:
############################################
#  TODO: Print out the linked list         #
#                                          #
############################################  
        addi sp, sp, -16
        sw ra, 4(sp)
        sw s0, 0(sp)
        beqz a0, print_ret
        lw s0, 0(a0) # s0 = node->value
        lw t0, 4(a0) # t0 = node->next
        mv a0, t0
        call print_list 
        mv a0, s0
        call print_int                
        j print_ret
print_ret:
        lw ra, 4(sp)
        lw s0, 0(sp)
        addi sp, sp, 16
        ret



sort_list:
############################################
#  TODO: Sort the linked list              #
#                                          #
############################################ 
        addi sp, sp, -16
        sw ra, 12(sp)
        sw s0, 8(sp) 
        sw s1, 4(sp)
        sw s2, 0(sp)

        beqz a0, sort_ret # head == NULL
        lw t1, 4(a0)
        beqz t1, sort_ret # head->next == NULL

        mv s0, a0 # s0 = head
        call find_middle
        mv t0, a0 # t0 = mid
        lw s1, 4(t0) # s1 = mid->next = right head
        sw zero, 4(t0) # mid->next = NULL

        mv a0, s0
        call sort_list # sort left
        mv s0, a0 # s0 = left-> head

        mv a0, s1
        call sort_list # sort right
        mv s1, a0 # s1 = right-> head

        ### node_t *new_node = (node_t*)sbrk(sizeof(*new_node)); ###
        li      a0, 8
        call    sbrk
        mv s2, a0 # s2 = new head
        mv t2, a0 # tmp

merge:
        beqz s0, attach_right
        beqz s1, attach_left
        lw t0, 0(s0) # t0 = left->value 
        lw t1, 0(s1) # t1 = right->value
        ble t0, t1, left_smaller # if t0 <= t1
        j right_smaller

left_smaller:
        sw s0, 4(t2) # tmp->next = head;
        lw t2, 4(t2) # tmp = tmp->next;
        lw s0, 4(s0) # left = left ->next;
        j merge

right_smaller:
        sw s1, 4(t2) # tmp->next = second;
        lw t2, 4(t2) # tmp = tmp->next;
        lw s1, 4(s1) # right = right->next;
        j merge

attach_left:
        sw s0, 4(t2) # tmp->next = head;
        lw a0, 4(s2)
        j sort_ret

attach_right:
        sw s1, 4(t2)
        lw a0, 4(s2)
        j sort_ret



sort_ret:
        lw ra, 12(sp)
        lw s0, 8(sp) 
        lw s1, 4(sp)
        lw s2, 0(sp)
        addi sp, sp, 16
        ret 


find_middle:
        addi sp, sp, -16
        sw ra, 4(sp)
        sw s0, 0(sp) # head
        
        beqz a0, find_ret

        mv s0, a0 # slow
        lw t0, 4(a0) # fast

find_loop:
        beqz t0, find_ret
        lw t0, 4(t0)
        beqz t0, find_ret
        lw s0, 4(s0)
        lw t0, 4(t0)
        j find_loop


find_ret:
        mv a0, s0
        lw ra, 4(sp)
        lw s0, 0(sp)
        addi sp, sp, 16
        ret


__start:
        ### save ra、s0 ###                                   
        addi    sp, sp, -16
        sw      ra, 12(sp)                      
        sw      s0, 8(sp)                                            
        ### read the numbers of the linked list ###
        call    read_int
        ### if(nums == 0) output "Empty!" ###
        beqz    a0, LBB2_2
        ### if(nums <= 0) exit
        mv      s0, a0
        blez    a0, exit
LBB2_1:                                
        call    read_int
        ### set push_front_list argument ###
        mv      a1, a0
        mv      a0, sp
        call    push_front_list
        addi    s0, s0, -1
        bnez    s0, LBB2_1
        lw      a0, 0(sp)
        j       LBB2_3
LBB2_2:
        call    print_str
        j       exit
LBB2_3:
        mv      s0, a0
        call    print_list
        call    print_newline
        mv      a0, s0
        call    sort_list
        # mv      a0, s0
        call    print_list
exit:   
        ### exit handling ###
        li      a0, 0
        lw      ra, 12(sp)                      
        lw      s0, 8(sp)                       
        addi    sp, sp, 16
	li a0,	10
	ecall

read_int:
	li	a0, 5
	ecall
	jr	ra

sbrk:
	mv	a1, a0
	li	a0, 9
	ecall
	jr	ra
 
print_int:
	mv 	a1, a0
	li	a0, 1
	ecall
	li	a0, 11
	li	a1, ' '
	ecall
	jr	ra

print_str:
        li      a0, 4
        la      a1, msg
        ecall
        jr      ra

print_newline:
        li      a0, 4
        la      a1, newline
        ecall
        jr      ra