	# Sample Program Lecture 08-1
	#
	# CSCI 221 S20
	#
	# This program outputs a greeting using a string
	# stored in its memory, but then changes the contents
	# of that string in memory, character by character,
	# so that it says goodbye instead.
	#
	# • Illustrates use of LI with a character constant.
	# • Illustrates use of "store byte" instruction SB.
	# • Shows that strings are "null terminated". They end
	#   with character 0.

        .data
hello_ptr:	.asciiz "hello.\n"

	.globl main
	.text

main:

print_hello:
	li	$v0, 4		# print("hello.\n")
	la	$a0, hello_ptr	# 
	syscall			#

change_string:
	la	$t0, hello_ptr      # Change each character, one by one.
	li	$t1, 'b'
	sb	$t1, ($t0)

	addiu	$t0, $t0, 1
	li	$t1, 'y'
	sb	$t1, ($t0)

	addiu	$t0, $t0, 1
	li	$t1, 'e'
	sb	$t1, ($t0)

	addiu	$t0, $t0, 1
	li	$t1, '!'
	sb	$t1, ($t0)

	addiu	$t0, $t0, 1    # Include the end-of-line character.
	li	$t1, '\n'
	sb	$t1, ($t0)

	addiu	$t0, $t0, 1    # Terminate the string with character 0.
	li	$t1, 0
	sb	$t1, ($t0)
	
print_bye:
	li	$v0, 4		# print("bye!\n")
	la	$a0, hello_ptr	#  
	syscall			# NOTE: string is at the same address,
	                        #       just has different contents now.
	
end_main:
	li	$v0, 0		# return 0
	jr	$ra		#
