	# Solution to Homework 07, Exercise 1
	#
	# CSCI 221 S20
	#
	# This code asks for two integers and then
	# outputs the quotient and remainder due to
	# their division.
	#

        .data
prompt_num:	.asciiz "Enter an integer: "
prompt_div:	.asciiz "Enter an integer divisor: "
fdbk1:	        .asciiz "Dividing "
fdbk2:     	.asciiz " by "
fdbk3:  	.asciiz " yields a quotient of "
fdbk4:   	.asciiz " with a remainder of "
fdbk5:  	.asciiz ".\n"

	.globl main
	.text

main:
	# Key:
	#      $t0 - the number to be divided
	#      $t1 - the divisor
	#      $t2 - the remainder
	#      $t3 - the quotient, a count

	# Method:
	#      Keeps subtracting the divisor from the dividend
	#      until the result is smaller than the divisor.
	#      If we count the subtractions made, then that
	#      gives us the quotient. The left over amount
	#      is the remainder.

begin_main:
	# Get dividend/numerator
	li	$v0, 4		# print(prompt_num)
	la	$a0, prompt_num	# 
	syscall			#
	li	$v0, 5		# number = input()
	syscall			#
	move	$t0, $v0	#

	# Get divisor
	li	$v0, 4		# print(prompt_div)
	la	$a0, prompt_div	# 
	syscall			#
	li	$v0, 5		# divisor = input()
	syscall			#
	move	$t1, $v0	#

divide:
	move    $t2, $t0	# remainder = number      
	li	$t3, 0		# quotient = 0    
divide_loop:	
	blt	$t2, $t1, done  # if remainder < divisor goto done
	subu	$t2, $t2, $t1   # remainder -= divisor
	addiu	$t3, $t3, 1     # quotient += 1
	b	divide_loop

done:
	li	$v0, 4		# print(fdbk1)
	la	$a0, fdbk1	# 
	syscall			#

	li	$v0, 1		# print(number)
	move	$a0, $t0	# 
	syscall			#

	li	$v0, 4		# print(fdbk2)
	la	$a0, fdbk2	# 
	syscall			#

	li	$v0, 1		# print(divisor)
	move	$a0, $t1	# 
	syscall			#

	li	$v0, 4		# print(fdbk3)
	la	$a0, fdbk3	# 
	syscall			#

	li	$v0, 1		# print(quotient)
	move	$a0, $t3	# 
	syscall			#

	li	$v0, 4		# print(fdbk4)
	la	$a0, fdbk4	# 
	syscall			#
	
	li	$v0, 1		# print(remainder)
	move	$a0, $t2	# 
	syscall			#

	li	$v0, 4		# print(fdbk5)
	la	$a0, fdbk5	# 
	syscall			#
	
end_main:
	li	$v0, 0		# return 0
	jr	$ra		#
