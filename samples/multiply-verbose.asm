	# Solution to Homework 07, Exercise 1
	#
	# CSCI 221 S20
	#
	# This code asks for two integers and then
	# outputs their product. This version is
	# terse, another is more verbose.
	#

        .data
promptx:	.asciiz "Enter an integer: "
prompty:	.asciiz "Enter another integer: "
feedback1:	.asciiz "Their product is "
feedback2:	.asciiz ".\n"

	.globl main
	.text

main:
	# Key:
	#      $t0 - the product
	#      $t1 - the value of x, the first number
	#      $t2 - the value of y, the second number

	# Method:
	#      I keep decrementing y until it reaches 0.
	#      With each decrement, I add x to the product.

begin_main:
	# Get x
	li	$v0, 4		# print(promptx)
	la	$a0, promptx	# 
	syscall			#
	li	$v0, 5		# x = input()
	syscall			#
	move	$t1, $v0	#

	# Get y
	li	$v0, 4		# print(prompty)
	la	$a0, prompty	# 
	syscall			#
	li	$v0, 5		# y = input()
	syscall			#
	move	$t2, $v0	#

multiply:	
	li	$t0, 0		# product = 0    
multiply_loop:	
	beqz	$t2, report     # if y == 0 goto report
	addu	$t0, $t0, $t1   # sum += x
	addiu	$t2, $t2, -1    # y -= 1
	b	multiply_loop

report:
	li	$v0, 4		# print(feedback1)
	la	$a0, feedback1	# 
	syscall			#

	li	$v0, 1		# print(product)
	move	$a0, $t0	# 
	syscall			#

	li	$v0, 4		# print(feedback2)
	la	$a0, feedback2	# 
	syscall			#
	
end_main:
	li	$v0, 0		# return 0
	jr	$ra		#
