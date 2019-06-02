.data
str: .asciiz "programming"

.text
.globl main
main:
la $a0, str
jal to_lowercase
move $t0, $v0

la $a0, str
li $v0, 4
syscall

li $a0, '\n'
li $v0, 11
syscall

move $a0, $t0
li $v0, 1
syscall

li $v0, 10
syscall

.include "proj2.asm"
