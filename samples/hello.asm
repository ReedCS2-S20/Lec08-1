	# Sample Program Lecture 08-1
	#
	# CSCI 221 S20
	#
	# This program outputs a greeting using a string
	# stored in its memory.
	#
	# You can use this code to solve the two exercises.

        .data
hello_ptr:	.asciiz "hello"
eoln_ptr:	.asciiz "\n"

	.globl main
	.text

main:

print_hello:
	li	$v0, 4		# print("hello")
	la	$a0, hello_ptr	# 
	syscall			#
	li	$v0, 4		# print("\n")
	la	$a0, eoln_ptr	# 
	syscall			#

your_code_for_the_exercises:
	
end_main:
	li	$v0, 0		# return 0
	jr	$ra		#
