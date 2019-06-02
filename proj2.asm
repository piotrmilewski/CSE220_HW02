# Piotr Milewski
# pmilewski
# 112291666

#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################

.text
to_lowercase:
	li $v0, 0 # number of letters changed from upper to lowercase
	move $t0, $a0 # address to increment
	to_lowercase_loop:
		lb $t1, 0($t0) # load current character into $t1
		beqz $t1, to_lowercase_end # end if null terminator is reached
		move $t2, $t0 # hold replacement address
		addi $t0, $t0, 1 # increment address to next character
		blt $t1, 65, to_lowercase_loop
		bgt $t1, 90, to_lowercase_loop
		addi $t1, $t1, 32 # change to lowercase letter
		sb $t1, 0($t2) # change bit in stored string
		addi $v0, $v0, 1 # add to number of lowercase swaps
		j to_lowercase_loop
	to_lowercase_end:	
		jr $ra


strlen:
	li $v0, 0 # length of the string
	move $t0, $a0
	strlen_loop:
		lb $t1, 0($t0) # load current character into $t1
		beqz $t1, strlen_end # end if null terminator is reached
		addi $v0, $v0, 1 # increment num of characters
		addi $t0, $t0, 1 # increment address to next character
		j strlen_loop
    strlen_end:
    	jr $ra
	

count_letters:
	li $v0, 0 # number of letters in the string
	move $t0, $a0
	count_letters_loop:
		lb $t1, 0($t0) # load current character into $t1
		beqz $t1, strlen_end
		move $t2, $t0 # hold current address
		addi $t0, $t0, 1 # increment address to next character
		blt $t1, 65, count_letters_loop
		bgt $t1, 122, count_letters_loop
		ble $t1, 90, count_letters_loop_cont
		blt $t1, 97, count_letters_loop
	count_letters_loop_cont:
		addi $v0, $v0, 1 # increment num of letters
		j count_letters_loop
	count_letters_end:
		jr $ra

# t0: current character in plaintext
# t1: bacon_code to be used
# t2: 
# t3: 
# t4: 
# t5: 
# t6: another subtraction constant
# t7: holds bacon_codes value to be added to ab_text
# t8: subtraction and multiplication constant
# t9: length of plaintext
encode_plaintext:
	# check if you can fit a character in ab_text
	blt $a2, 5, encode_plaintext_ABTextShorterThan5
	
	# grab the length of plaintext
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal strlen
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	move $t9, $v0 # set t9 to length of plaintext
	
	# check to see if ab_text isn't empty
	beqz $t9, encode_plaintext_shortPlaintext
	
	li $v0, 0 # number of changed characters in ab_text
	li $t8, 5 # subtract ab_text_length constant | multiply alphabetic number
	li $t6, 97 # subtract address of alphabetic letter
	encode_plaintext_loop:
		blt $a2, 10, encode_plaintext_notAllEncoded
		lb $t0, 0($a0) # load current character into $t0
		beqz $t0, encode_plaintext_allEncoded
		sub $a2, $a2, $t8 # update ab_text_length
		addi $v0, $v0, 1 # update $v0
		addi $a0, $a0, 1 # update address of plaintext to next character
		encode_plaintext_loop_space:
			bne $t0, 32, encode_plaintext_loop_exlMark
			move $t1, $a3
			addi $t1, $t1, 130
			j encode_plaintext_ABTextModify
		encode_plaintext_loop_exlMark:
			bne $t0, 33, encode_plaintext_loop_quoMark
			move $t1, $a3
			addi $t1, $t1, 135
			j encode_plaintext_ABTextModify
		encode_plaintext_loop_quoMark:
			bne $t0, 39, encode_plaintext_loop_comma
			move $t1, $a3
			addi $t1, $t1, 140
			j encode_plaintext_ABTextModify
		encode_plaintext_loop_comma:
			bne $t0, 44, encode_plaintext_loop_period
			move $t1, $a3
			addi $t1, $t1, 145
			j encode_plaintext_ABTextModify
		encode_plaintext_loop_period:
			bne $t0, 46, encode_plaintext_loop_alphabet
			move $t1, $a3
			addi $t1, $t1, 150
			j encode_plaintext_ABTextModify
		encode_plaintext_loop_alphabet:
			sub $t0, $t0, $t6
			mul $t0, $t8, $t0
			move $t1, $a3
			add $t1, $t1, $t0
			j encode_plaintext_ABTextModify
		
	encode_plaintext_ABTextModify:
		lb $t7, 0($t1)
		sb $t7, 0($a1)
		lb $t7, 1($t1)
		sb $t7, 1($a1)
		lb $t7, 2($t1)
		sb $t7, 2($a1)
		lb $t7, 3($t1)
		sb $t7, 3($a1)
		lb $t7, 4($t1)
		sb $t7, 4($a1)
		addi $a1, $a1, 5
		j encode_plaintext_loop
	
	encode_plaintext_allEncoded:
		li $v1, 1
		j encode_plaintext_addEOM
	encode_plaintext_notAllEncoded:
		li $v1, 0
		lb $t0, 0($a0) # load current character into $t0
		beqz $t0, encode_plaintext_allEncoded # checks for fake news lol
		j encode_plaintext_addEOM
	encode_plaintext_addEOM:
		lb $t7, 155($a3)
		sb $t7, ($a1)
		lb $t7, 156($a3)
		sb $t7, 1($a1)
		lb $t7, 157($a3)
		sb $t7, 2($a1)
		lb $t7, 158($a3)
		sb $t7, 3($a1)
		lb $t7, 159($a3)
		sb $t7, 4($a1)
		j encode_plaintext_end
	
	# special cases
	encode_plaintext_shortPlaintext:
		li $v0, 0
		li $v1, 1
		j encode_plaintext_addEOM
	encode_plaintext_ABTextShorterThan5:
		li $v0, 0
		li $v1, 0
		j encode_plaintext_end
		
	# end function
	encode_plaintext_end:
    	jr $ra
	
# t0: address of bacon_codes
# t1: character of ab_text
# t2: character of ciphertext
# t3: 
# t4: 
# t5: 
# t6: 
# t7: 
# t8: 
# t9: address hold for insert into ciphertext
encrypt:
	move $fp, $sp
	
	# check if you can fit a character in ab_text
	blt $a3, 5, encrypt_ABTextShorterThan5

	# change plaintext to lowercase (cause apparently the instructions lie :angry_face:) using to_lowercase()
	addi $sp, $sp, -8
	sw $a0, 4($sp)
	sw $ra, 0($sp)
	jal to_lowercase
	lw $ra, 0($sp)
	lw $a0, 4($sp)
	addi $sp, $sp, 8
	
	# update ab_text using encode_plaintext()
	lw $t0, 0($fp)
	addi $sp, $sp, -16
	sw $a1, 4($sp)
	sw $a2, 8($sp)
	sw $a3, 12($sp)
	move $a1, $a2
	move $a2, $a3
	move $a3, $t0
	sw $ra, 0($sp)
	jal encode_plaintext
	lw $ra, 0($sp)
	lw $a1, 4($sp)
	lw $a2, 8($sp)
	lw $a3, 12($sp)
	addi $sp, $sp, 16
	lw $t0, 0($fp)
	
	li $v0, 0
	encrypt_loop:
		lb $t1, ($a2) # load ab_text character into $t1
		lb $t2, ($a1) # load ciphertext character into $t2
		beqz $t1, encrypt_end
		beq $t1, 65, encrypt_loop_lowercase
		beq $t1, 66, encrypt_loop_uppercase
		j encrypt_end

		encrypt_loop_lowercase:
			bgt $t2, 96, encrypt_loop_lowercase_check # lowercase cipher
			j encrypt_loop_lowercase_cont # check if uppercase cipher
			encrypt_loop_lowercase_check:
				bgt $t2, 122, encrypt_loop_lowercase_notAlpha
				# already lowercase so hit the dip
				addi $v0, $v0, 1
				addi $a2, $a2, 1
				addi $a1, $a1, 1
				j encrypt_loop
			encrypt_loop_lowercase_cont: # uppercase cipher
				bgt $t2, 64, encrypt_loop_lowercase_check2
				j encrypt_loop_lowercase_notAlpha
			encrypt_loop_lowercase_check2:
				bgt $t2, 90, encrypt_loop_lowercase_notAlpha
				j encrypt_loop_lowercase_actualEncrypt
			encrypt_loop_lowercase_notAlpha:
				addi $a1, $a1, 1 # current value not alphabetical
				j encrypt_loop
			encrypt_loop_lowercase_actualEncrypt:
				addi $t2, $t2, 32
				sb $t2, ($a1)
				addi $v0, $v0, 1
				addi $a2, $a2, 1
				addi $a1, $a1, 1
				j encrypt_loop
				
		encrypt_loop_uppercase:
			bgt $t2, 96, encrypt_loop_uppercase_check # lowercase cipher
			j encrypt_loop_uppercase_cont # check if uppercase cipher
			encrypt_loop_uppercase_check:
				bgt $t2, 122, encrypt_loop_uppercase_notAlpha
				# we know it's lowercase so turn it to upper
				j encrypt_loop_uppercase_actualEncrypt
			encrypt_loop_uppercase_cont: # uppercase cipher
				bgt $t2, 64, encrypt_loop_uppercase_check2
				j encrypt_loop_uppercase_notAlpha
			encrypt_loop_uppercase_check2:
				bgt $t2, 90, encrypt_loop_uppercase_notAlpha
				# already uppercase so hit the dip
				addi $v0, $v0, 1
				addi $a2, $a2, 1
				addi $a1, $a1, 1
				j encrypt_loop
			encrypt_loop_uppercase_notAlpha:
				addi $a1, $a1, 1 # current value not alphabetical
				j encrypt_loop
			encrypt_loop_uppercase_actualEncrypt:
				addi $t2, $t2, -32
				sb $t2, ($a1)
				addi $v0, $v0, 1
				addi $a2, $a2, 1
				addi $a1, $a1, 1
				j encrypt_loop		

	# special cases
	encrypt_ABTextShorterThan5:
		li $v0, 0
		li $v1, 0
		j encrypt_end

	# end function
	encrypt_end:
		move $sp, $fp
		jr $ra
	
# t0: holds current character of cipherText
# t1: holds value to load into ab_text
# t2: counts number of consecutive 'B's
# t3: set to 0 every 5 characters
# t4: 
# t5: 
# t6: 
# t7: 
# t8: 
# t9: 	
decode_ciphertext:
	
	# base case #1
	blt $a2, 5, decode_ciphertext_error
	
	# count numOfLetters in cipherText
	addi $sp, $sp, -8
	sw $a0, 4($sp)
	sw $ra, 0($sp)
	jal count_letters
	lw $ra, 0($sp)
	lw $a0, 4($sp)
	addi $sp, $sp, 8
	
	# base case #2
	bgt $v0, $a2, decode_ciphertext_error
	
	# base case #3
	beqz $v0, decode_ciphertext_error
	
	li $v0, 0
	li $t2, 0
	li $t3, 0
	# main loop
	decode_ciphertext_loop:
		lb $t0, 0($a0)
		blt $t0, 65, decode_ciphertext_loop_notAlpha
		bgt $t0, 122, decode_ciphertext_loop_notAlpha
		blt $t0, 91, decode_ciphertext_loop_upper
		blt $t0, 97, decode_ciphertext_loop_notAlpha
		j decode_ciphertext_loop_lower
		decode_ciphertext_loop_notAlpha:
			addi $a0, $a0, 1
			j decode_ciphertext_loop
		decode_ciphertext_loop_upper:
			li $t1, 66
			sb $t1, ($a1)
			addi $v0, $v0, 1
			addi $a0, $a0, 1
			addi $a1, $a1, 1
			addi $t2, $t2, 1
			addi $t3, $t3, 1
			beq $t3, 5, decode_ciphertext_loop_upper_checkForEOM
			j decode_ciphertext_loop
			decode_ciphertext_loop_upper_checkForEOM:
				beq $t2, 5, decode_ciphertext_end
				li $t3, 0
				li $t2, 0
				j decode_ciphertext_loop
		decode_ciphertext_loop_lower:
			li $t1, 65
			sb $t1, ($a1)
			addi $v0, $v0, 1
			addi $a0, $a0, 1
			addi $a1, $a1, 1
			li $t2, 0
			addi $t3, $t3, 1
			beq $t3, 5, decode_ciphertext_loop_lower_resetT3
			j decode_ciphertext_loop
			decode_ciphertext_loop_lower_resetT3:
				li $t3, 0
				j decode_ciphertext_loop
	
	# base cases
	decode_ciphertext_error:
		li $v0, -1
		j decode_ciphertext_end
	
	# end function
	decode_ciphertext_end:
		jr $ra
	
# t0: holds bacon_codes
# t1: ab_text letter
# t2: 
# t3: index of current letter in bacon_codes
# t4: bacon_codes letter
# t5: 
# t6: 
# t7: 
# t8: TEMP
# t9: length of plaintext
decrypt:

	move $fp, $sp
	
	# run strlen for plaintext
	addi $sp, $sp, -8
	sw $a0, 4($sp)
	move $a0, $a1
	sw $ra, 0($sp)
	jal strlen 
	lw $ra, 0($sp)
	lw $a0, 4($sp)
	addi $sp, $sp, 8
	lw $t0, 0($fp)
	move $t9, $v0
	
	# run decode_ciphertext
	addi $sp, $sp, -20
	sw $a0, 4($sp)
	sw $a1, 8($sp)
	sw $a2, 12($sp)
	sw $a3, 16($sp)
	move $a1, $a2
	move $a2, $a3
	lw $t0, 0($fp)
	move $a3, $t0
	sw $ra, 0($sp)
	jal decode_ciphertext
	lw $ra, 0($sp)
	lw $a0, 4($sp)
	lw $a1, 8($sp)
	lw $a2, 12($sp)
	lw $a3, 12($sp)
	addi $sp, $sp, 20
	lw $t0, 0($fp)
	
	# base case #1
	beq $v0, -1, decrypt_error
		
	# base case #2
	li $t8, 5
	mul $t9, $t9, $t8
	bgt $v0, $t9, decrypt_error
	li $t8, 0 # reset $t8
	
	li $v0, 0
	addi $a2, $a2, -5
	decrypt_main:
		addi $a2, $a2, 5
		lw $t0, ($fp)
		li $t3, 0
		decrypt_main_loop:
			decrypt_main_loop_1st:
				lb $t1, 0($a2)
				lb $t4, 0($t0)
				beq $t1, $t4, decrypt_main_loop_2nd
				j decrypt_main_loop_nextBaconCode
			decrypt_main_loop_2nd:
				lb $t1, 1($a2)
				lb $t4, 1($t0)
				beq $t1, $t4, decrypt_main_loop_3rd
				j decrypt_main_loop_nextBaconCode
			decrypt_main_loop_3rd:
				lb $t1, 2($a2)
				lb $t4, 2($t0)
				beq $t1, $t4, decrypt_main_loop_4th
				j decrypt_main_loop_nextBaconCode
			decrypt_main_loop_4th:
				lb $t1, 3($a2)
				lb $t4, 3($t0)
				beq $t1, $t4, decrypt_main_loop_5th
				j decrypt_main_loop_nextBaconCode
			decrypt_main_loop_5th:
				lb $t1, 4($a2)
				lb $t4, 4($t0)
				beq $t1, $t4, decrypt_main_loop_alphaCheck
				j decrypt_main_loop_nextBaconCode
			decrypt_main_loop_alphaCheck:
				bgt $t3, 25, decrypt_main_loop_spaceCheck
				addi $t3, $t3, 65
				j decrypt_main_loop_addItem
			decrypt_main_loop_spaceCheck:
				bne $t3, 26, decrypt_main_loop_exlCheck
				li $t3, 32
				j decrypt_main_loop_addItem
			decrypt_main_loop_exlCheck:
				bne $t3, 27, decrypt_main_loop_quoCheck
				li $t3, 33
				j decrypt_main_loop_addItem
			decrypt_main_loop_quoCheck:
				bne $t3, 28, decrypt_main_loop_commaCheck
				li $t3, 39
				j decrypt_main_loop_addItem
			decrypt_main_loop_commaCheck:
				bne $t3, 29, decrypt_main_loop_periodCheck
				li $t3, 44
				j decrypt_main_loop_addItem
			decrypt_main_loop_periodCheck:
				bne $t3, 30, decrypt_main_loop_eomCheck
				li $t3, 46
				j decrypt_main_loop_addItem
			decrypt_main_loop_eomCheck:
				li $t3, 0
				sb $t3, ($a1)
				j decrypt_end
			decrypt_main_loop_addItem:
				sb $t3, ($a1)
				addi $v0, $v0, 1
				addi $a1, $a1, 1
				j decrypt_main
			decrypt_main_loop_nextBaconCode:
				addi $t0, $t0, 5
				addi $t3, $t3, 1
				j decrypt_main_loop
	
	
	# base cases
	decrypt_error:
		li $v0, -1
		j decrypt_end
	
	# end function
	decrypt_end:
		move $sp, $fp
		jr $ra

#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
