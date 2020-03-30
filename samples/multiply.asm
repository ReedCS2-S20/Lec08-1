	# Solution to Homework 07, Exercise 1
	#
	# CSCI 221 S20
	#
	# This code asks for two integers and the
	# outputs their product. This version is
	# terse, another is more verbose.
	#

        .data
prompt:		.asciiz "Enter an integer: "
feedback1:	.asciiz "The sum from 1 to "
feedback2:	.asciiz " is "
feedback3:	.asciiz ".\n"

	.globl main
	.text

main:
	li	$t0, 0		# sum = 0    
	li	$t1, 1		# inc = 1    
	li	$t2, 0          # count = 0

	li	$v0, 4		# print(prompt) -- syscall #4
	la	$a0, prompt	# 
	syscall			#
	li	$v0, 5		# last = input() -- syscall #5, result in $v0
	syscall			#
	move	$t3, $v0	#
	
loop:	
	beq	$t3, $t2, done  # if last == count goto done

	addu	$t2, $t2, $t1   # count += inc
	addu	$t0, $t0, $t2   # sum += count
	b	loop

done:
	li	$v0, 4		# print(feedback1)
	la	$a0, feedback1	# 
	syscall			#

	li	$v0, 1		# print(last)
	move	$a0, $t3	# 
	syscall			#

	li	$v0, 4		# print(feedback2)
	la	$a0, feedback2	# 
	syscall			#
	
	li	$v0, 1		# print(sum)
	move	$a0, $t0	# 
	syscall			#

	li	$v0, 4		# print(feedback3)
	la	$a0, feedback3	# 
	syscall			#
	
	li	$v0, 0		# return 0
	jr	$ra		#
	
