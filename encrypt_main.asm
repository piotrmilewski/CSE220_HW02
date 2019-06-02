.data
plaintext: .asciiz ""
ciphertext: .asciiz "The Scholars program is a vibrant community of high-achieving students at Stony Brook."
ab_text: .ascii "!!!!"
null: .byte 0
.align 2
ab_text_length: .word 4

.text
.globl main
main:
la $a0, plaintext
la $a1, ciphertext
la $a2, ab_text
lw $a3, ab_text_length
addi $sp, $sp, -4
la $t0, bacon_codes
sw $t0, 0($sp)
jal encrypt
addi $sp, $sp, 4

move $t0, $v0
move $t1, $v1

la $a0, ciphertext
li $v0, 4
syscall

li $a0, '\n'
li $v0, 11
syscall

la $a0, ab_text
li $v0, 4
syscall

li $a0, '\n'
li $v0, 11
syscall

move $a0, $t0
li $v0, 1
syscall

li $a0, '\n'
li $v0, 11
syscall

move $a0, $t1
li $v0, 1
syscall

li $a0, '\n'
li $v0, 11
syscall

li $v0, 10
syscall

.include "proj2.asm"
.include "bacon_codes.asm"
