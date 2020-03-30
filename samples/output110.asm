        # output110.asm
        #
	# This code outputs character strings that sit in memory
	# as well as an integer value that lives in memory. It
        # does this twice, the second time after incrementing
	# that memory by ten.
	#
	
        .data
feedback:       .asciiz "The value held in memory is "
dot_eoln:       .asciiz ".\n"
value:          .word 100

        .globl main
        .text

main:
        la      $a0, feedback	# put_str(feedback) -- syscall #4
        li      $v0, 4		# 
        syscall			#

	la      $t0, value      # put_int(value)    -- syscall #1
        lw      $a0, ($t0)      # 
        li	$v0, 1		# 
        syscall			#

        la	$a0, dot_eoln   # put_str(dot_eoln) -- syscall #4
        li	$v0, 4		#
        syscall			#

        la      $a0, value      #
	lw      $t0, ($a0)      #
	addiu   $t0, $t0, 10    # value = value + 10
	sw      $t0, ($a0)      #
	
        la      $a0, feedback	# put_str(feedback) -- syscall #4
        li      $v0, 4		# 
        syscall			#

	la      $t0, value      # put_int(value)    -- syscall #1
        lw      $a0, ($t0)      # 
        li	$v0, 1		# 
        syscall			#

        la	$a0, dot_eoln   # put_str(dot_eoln) -- syscall #4
        li	$v0, 4		#
        syscall			#

        li	$v0, 0		# return 0
        jr	$ra		#
