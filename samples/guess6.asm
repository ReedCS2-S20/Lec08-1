	# Solution to Homework 07, Exercise 3, BONUS version.
	#
	# CSCI 221 S20
	#

        .data
prompt:	.asciiz "Enter a guess: "
high:	.asciiz "Too high!\n"
low:	.asciiz "Too low!\n"
yay:	.asciiz "You got it.\n"
boo:	.asciiz "Out of guesses. Too bad.\n"
random:	.word 37
howmany:.word 6
	
	.globl main
	.text

main:
	la	$a0, howmany
	lw	$t2, ($a0)

	la	$a0, random
	lw	$t0, ($a0)

	li	$t3, 0

guess:
	bge	$t3, $t2, say_boo  # check if they're out of guesses
	
	li	$v0, 4		   # get the next guess
	la	$a0, prompt
	syscall			
	li	$v0, 5		
	syscall			
	move	$t1, $v0
	addiu	$t3, $t3, 1	   # count it
	
	blt	$t1, $t0, say_low  # report high/low
	bgt	$t1, $t0, say_high
say_yay:
	li	$v0, 4		   # report that they got it!
	la	$a0, yay
	syscall			
	b       done

say_low:
	li	$v0, 4		   # report too low, get next guess
	la	$a0, low
	syscall			
	b       guess

say_high:         
	li	$v0, 4             # report too high, get next guess
	la	$a0, high
	syscall			
	b       guess

say_boo:
	li	$v0, 4		   # report that they're out of guesses
	la	$a0, boo
	syscall			
done:	
	li	$v0, 0	
	jr	$ra	
