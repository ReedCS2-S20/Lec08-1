	# Solution to Homework 07, Exercise 1
	#
	# CSCI 221 S20
	#
	# This code asks for two integers and then
	# outputs their product. This version is
	# verbose, another is more terse.
	#

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
	li	$v0, 5		# x = input()
	syscall			#
	move	$t1, $v0	#

	# Get y
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
	li	$v0, 1		# print(product)
	move	$a0, $t0	# 
	syscall			# NOTE: missing end-of-line
	
end_main:
	li	$v0, 0		# return 0
	jr	$ra		#
