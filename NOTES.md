## CSCI 221, Spring 2020
# Lecture 08-1: MIPS assembly

---

## Overview

In this lecture we continue looking at MIPS32 programming. We review
the "core" assembler instruction set and go over solutions to Homework 07.
We focus on loops and conditionals, structured with "branch" instructions.
Lastly, we look at placing initial array values in a global data space
and accessing arrays' contents using the "load" and "store" instructions.
We review a few classic array algrorithms, but instead writtem in MIPS
assembly.

---

## Outline

    0. Logistics for the on-line course
    I. Review of several individual instructions
     A. Example: homework 07 multiplication exercise
     B. Compiler conversion of code.
     C. LI, ADDU, ADDIU instructions 
     D. BEQZ, B, labels
     E. system calls
      1. get an integer 
      2. put an integer
      3. deferred: put a string
     G. returning from main
    II. Example: integer quotient exercise
     A. MIPS code
     B. C++ code
     C. BLT, SUBU, MOVE instructions
    III. review of program structure
     A. some assembler terminology
     B. .data vs .text segments
     C. data segment directives .asciiz, .word, .space
    IV. reading and writing memory
     A. reading an integer word from .data
     B. LA and LW instructions
     C. increment a word in memory
     D. SW instruction
     E. LB and SB instructions
     F. example: write "bye" into space of hello
    V. exercises for our next meeting
---
 
## Some logistics

• Courses will be on-line for the duration of the semester.

1. Lectures are MWF 3-4pm, PST and to be delivered over Zoom. I'll
post my slides, as well as a set of notes (like these), for each
lecture beforehand. I'll email a link to the Zoom meeting for that
lecture.

2. Rather than weekly lab exercises, I will instead give "optional
exercises" at the end of each lecture. These will hopefully foster
questions and help your learning of each lecture. Work on those before
the next lecture meeting.

3. I will hold a 10-minute question session before and after each
lecture, starting Wednesday.

4. I will assign a new homework every Wednesday. Each will be due the
following Wednesday. These will only cover material presented prior to
the day they were assigned.

5. I'm cancelling lab meetings. Instead, I and my TAs will host lab
office hours on Thursday afternoons, PST. Use that time to get started
on the next homework and to ask questions about its logistics, just
like you might during the lab meetings.

6. In addition to lab meetings, I'll be hosting regular office hours 
during the week. I'll post these each week along with the Monday
lecture materials.

7. The TAs will be holding drop-in tutoring hours in the evenings
using Zoom. These are being managed by the DoJo and they will be
posting those hours on their website.

=> You can always email me at any time with questions or issues you
are facing. Remember to send me code, give me a console transcript
of errors, etc. so I can figure out your code's issue.

• The dumplings are only available on campus and campus has closed. You
should be working to make sure you can compile and run C++ code on your
own computer. You'll want to do the same with MIPS/SPIM.

* For those of you who were able to compile SPIM, remember to run it
with the command

    ./spim -exception_file exceptions.s -f myMIPSprogram.s

* For those of you with WSL for Windows, you can obtain SPIM with the 
commands

    sudo apt update
    sudo apt-get install spim

Then you can run all the spim stuff with the command

    spim -f myMIPSprogram.s

---

## MIPS Review

Let me review the code you should now be used to writing, having 
completed Homework 07. Before I begin, let me offer this link
to [a course on MIPS](https://chortle.ccsu.edu/AssemblyTutorial/index.html#part4)
from Central Connecticut State. It may teach more than I do, and
emphasize different aspects of MIPS, but you still might find
it helpful.

### Solution to Homework 07 Exercise 1

Here is an excerpt from my solution to Homework 07 Exercise 1, a MIPS
program that multiplies two integers that are imput within the
console, then reports that product to the console:

    01  multiply:	
    02   	li	$t0, 0		# product = 0    
    03  multiply_loop:	
    04  	beqz	$t2, report     # if y == 0 goto report
    05  	addu	$t0, $t0, $t1   # product += x
    06  	addiu	$t2, $t2, -1    # y -= 1
    07  	b	multiply_loop
    08  report:

This code appears within a procedure "block" named `main`.  There is
some code above this segment that gets two integer inputs (that I call
*x* and *y*) and puts them in registers `$t1` and `$t2`. This code then
loops *y* times, adding *x* to a product register with each iteration
of the loop. I use register `$t0` to store the product as I compute it.

Here is similar code, written in C (and missing variable declarations):

    01   std::cin >> x;
    02   std::cin >> y;
    03   product = 0;
    04   while (y != 0) {
    05     product += x;
    06     y--;
    07   }
    08   std::cout << product << std::endl;

I recommend writing solutions to MIPS exercises in Python or C++ first,
then converting them into the MIPS assembler code. When you write it
in the more expressive language, just be mindful of the limitations 
that you'll face within MIPS assembly. I also recommend labelling
instructions and commenting throughout. This will make it easier
for us, and probably also you, to understand and figure out your
code. The more labels and comments you have, probably the merrier.

### Code conversion

In the slides I take you visually through steps that convert the C++
code above into the MIPS code. Conceptually, those steps are similar
to what a compiler needs to do to convert C++ code into machine code.
There are three particular steps worthy of note:

• Construction of a *control flow graph* showing the structure of the
code. 

This is a diagram of the possible routes that the processor
might take (how the program "flows") when the code gets executed. Two
kinds of statements that make the control flow graph intricate are 
loops and conditionals ("if-thens").  Conditionals lead to "branches"
in the control flow. When a condition is `true` the processor follows
one path through the code. When `false` it follows another. This split
in the possible paths is called a *branch*.

Branching happens, also, at the top of a loop, where the loop
continuation condition is checked.  Then, at the bottom of the loop,
there is a "jump back" up to the top of the loop. This jump is
sometimes also referred to as a branch, too, because (looking at the
code) we don't flow to the next instruction below. Rather, we leap off
and up to the top of the loop.

Incidentally, before the loop appears in the code and in the flow
graph, there is usually some loop set-up code. (Initializing a count
variable, for example.) This is often called the *loop header*, and
just below it is the branch formed by checking the loop condition.

• Code generation. 

This is the conversion of individual C++ statements into MIPS statements.
For example, an assignment like

    x = ((y + 2) - z) * 2

is going to lead to code like this

    ADDIU t,y,2    # add 2 to y
    SUBU  u,t,z    # subtract z from that
    SHL   x,u,1    # multiply by 2 (shift bits left)

excepting we are using variables and "temporaries" and we will instead
use registers (and maybe memory) to store values.  Languages like C++
allow you to express a complicated series of steps in one line, but
machine code often takes several instructions to compute the same
thing.

In my multiplication example, nothing is too complex, and most conversion
of statements to generate MIPS instructions is one-to-one (e.g. an increment
statement becomes one MIPS instruction).

• Register allocation.

In this phase of compiling MIPS assembly code from the C++ code, we
find physical locations on either the MIPS processor, or in the memory
the MIPS processor accesses, for each of the program variables. In the
code we present here, there are so few program variables that we are
able to use just the registers `t0`, `t1`, etc. In this simpler
programs, we can just put say `x` in `t0`, `y` in `t1`, and so
forth. Furthermore, we can reuse registers. If the value of `y` is no
longer needed at some point within a procedure's calculations, but
then the program introduces a new variable `w`, then probably both `y`
and `w` can be held in `t1`. To make these kinds of determinations the
compiler uses "liveness analysis" to see where in a code segment
program variables' values are still "live", i.e. needed for subsequent
calculations.

For more complex programs we'll run out of the registers we can
use. We'll see soon that some program variables will instead get held
in an area of computer memory that's organized as a stack. In learning
about the stack, we'll also see that some registers are reserved for
specific uses and cannot be used as the storage for program variables.
So, even though a MIPS processor has 32 registers, not all of them are
actually available for general use when a compiler is figuring out
register allocation.

### Instruction review I

Here are some notes on some of the instructions used:

• LOAD IMMEDIATE 

&nbsp;&nbsp;&nbsp;&nbsp;`LI` *target*`,` *value*

This instruction is used to set a register to some particular value.
The *target* should be some register, for now that will mostly be
`t0` through `t9`. We'll start using other registers later. The
*value* should be some integer constant in decimal notation
(though we will use character constants and maybe other bases
later).

I use this in line 02 of the example MIPS code above. Here I'm
setting the value of register `t0` to the value 0.

    02   li $t0, 0		

You should think of it as the same as the C++ assignment statement:

&nbsp;&nbsp;&nbsp;&nbsp;*target* `=` *value* `;`

Incidentally, it's called "immediate" because the value is actually
embedded within the bits of the instruction.

• REGISTER-REGISTER ADD (UNTRAPPED)

&nbsp;&nbsp;&nbsp;&nbsp;`ADDU` *target*`,` *source1*`,` *source2*

This takes the values held in the two specified "source" registers,
adds them, and then stores that sum into the target register.  I use
this in the sample program above like so:

    05 	addu	$t0, $t0, $t1   

In general, `ADDU` is like the C++ statement:

&nbsp;&nbsp;&nbsp;&nbsp;*target* `=` *source1* `+` *source2* `;`

and so my program is, in essence, doing this

    product = product + x;

or, alternatively

    product += x;

Note that both the sources and the target must be registers, as opposed to...

• REGISTER-IMMEDIATE ADD (UNTRAPPED)

&nbsp;&nbsp;&nbsp;&nbsp;`ADDIU` *target*`,` *source*`,` *value*

This takes the value stored in the specified source register,
computes the sum of it with the specified value, and then
updates the target register to hold that computed sum.

    05 	addiu	$t2, $t2, -1   

and so my program is, in essence, performing this
C++ statement:

    y--;

• BRANCH-IF-ZERO

The program uses a yet-to-be introduced `BEQZ` instruction

    04 	beqz $t2, report     

This instruction checks the value stored in register `t2`
to see if it equals 0. If so, the MIPS processor will
skip lines 05-07 and execute the lines following line 08,
the one labelled with `report`.  If instead `t2` is *not equal*
to zero, then line 05 will be executed next, followed by
line 06, etc. 

If the register equals 0, then the branch is taken. If the
register does not equal 0, the branch is not taken and
execution continues with the instruction just below.

More generally, the instruction
  
&nbsp;&nbsp;&nbsp;&nbsp;`BEQZ` *source*`,` *label*

leads the processor to jump to the instruction just
below *label* if the register *source* is holding the
value 0.

There is a family of these branch instructions. There are these
comparisons with zero:

    BEQZ: branch if the source register equals zero
    BNEZ: branch if the source register isn't equal to zero
    BGTZ: branch if the source register is greater than zero
    BLTZ: branch if the source register is less than zero
    BGEZ: branch if the source register is at least zero
    BLEZ: branch if the source register is at most zero

In the first sample programs we looked at, there were also
two register compare-and-branch operations. For example,
the instruction

    beq $t2, $t3, done

jumps to the instruction labelled `done` if registers `t2` and
`t3` are each holding the same value. We have, then, this family
of branch instructions that take two register values as the 
sources of the comparison to determine whether to branch:

    BEQ: branch if the source registers are equal
    BNE: branch if the source registers aren't equal
    BGT: branch if the first source is greater than the second
    BLT: branch if the first source is less than the second
    BGE: branch if the first source is at least the second
    BLE: branch if the first source is at most the second

Finally, there is the *unconditional* branch instruction, for
example

    b multiply_loop

This takes a branch regardless, and so always jumps to the instruction
labelled `multiply_loop`. This is often used as the last instruction
in the body of a loop.

### System calls

We are fortunate to be using the SPIM simulator to learn how machine
coding works. This is a forgiving system. Just as LogiSim prevents us
from worrying about how to solder and needing to pay attention to
details like voltage characteristics, resistors, LEDs, and so forth,
SPIM gives us a taste of low-level programming without some of the
headaches. But, just as the drawer full of LED displays, input
"keyboards", ROM plug-ins, and so forth are only to make a circuit
simulation easier to understand and almost like built hardware, 
SPIM provides a few features to make machine programs run as if they
are running in a real computer with a MIPS processor.

In particular, SPIM provides a family of "system calls" that you
can invoke within your assembly program.  For example, the three
lines below can be used to output the integer value stored in
register `t0` out to the console (as decimal):

    move $a0,$t0
    li $v0,1
    syscall

The first two lines set up the processor for making the call.
The third line, we should imagine, invokes a special sequence
of instructions that knows what to do when it looks at the
data stored in registers `v0` and `a0`.  That is to say,
that one instruction line "makes the call." The call does
the work, then the processor executes the lines following
`syscall`.

The SPIM system has a family of calls, each identified by a number.
System call #1 is used for printing an integer value. The SPIM
systems, by convention, assumes that register `a0` is holding
the value your want printed and prints it. There are other
printing system calls. System call #4, which we'll talk about more
below this section, expects an address for the start of a character
string that lives in memory. It looks in `a0` for that address
and prints the characters stored at, and beyond, that address.

Regardless, SPIM expects register `v0` to hold the identifying 
number of the call your making. We load it with 1 when we want to
print an integer.

System call #5, it turns out, can be used to get an integer as
input from the console. Here's an example of its use:

    li      $v0,5		
    syscall		
    move    $t0,$v0

Since getting an input requires no arguments, we just set register
`v0` to 5 to tell MIPS that we want system call #5. We don't have
to set the argument register `a0`. The second line makes the call.
By convention, the system reads an integer from the console (in
decimal) and puts that integer into register `v0`. The third line,
it turns out, copies that register's value into register `t0`
for use in the later parts of the program.

There are several other calls, but #1, #4, and #5 are the ones
you need to complete this part of the course. (I also use system
call #8 in the sample `string.asm` code for a BONUS exercise
that reads a string from the console.)

### Returning from main

One last bit of our sample programs that we'd like to demystify here
is the two-instruction sequence that appeasr at every program's end:

    li $v0,0
    jr $ra	

It turns out that these are the same as the C++ statement

    return 0;

that we put at the end of `main` in every C++ program we write.

These hint at a longer lesson that we'll defer for another lecture.
It turns out that there is a collection of conventions that we are
asked to follow, when programming a MIPS processor, for writing
code that is decomposed into a series of functions and procedures.
These are called *calling conventions* and they are quite elaborate.
They include rules for using the various MIPS32 registers, for 
laying out stack frames, and for jumping out-and-back to/from a
function that your code calls.

To do all that, however, requires us to think about how a program
accesses memory. We'll spend time at the end of this lecture on
that, then devote the next lecture to playing around in memory,
and then we'll look at writing functions.

For now, since our programs just have a single function `main`
that always returns 0, you can just include these two lines at
the end of every program you write.

---

## Instruction review II

Let's look at a few more instructions by examining my solution to
Homework 07 Exercise 2.

### Solution to Homework 07 Exercise 2

Here is an excerpt from my solution to Homework 07 Exercise 1, a MIPS
program that divides two integers and reports the quotient and the
remainder due to that division.


    divide:
        move    $t2, $t0	# remainder = number      
        li      $t3, 0		# quotient = 0    
    divide_loop:	
        blt     $t2, $t1, done  # if remainder < divisor goto done
        subu    $t2, $t2, $t1   # remainder -= divisor
        addiu   $t3, $t3, 1     # quotient += 1
        b       divide_loop
    done:
        # code that outputs $t3 and $t2.

This, again, is just the "kernel" of the algorithm, a loop that
repeatedly subtracts the divisor from the given number until that
number has been whittled down to something smaller then the
divisor. Each time it repeats the subtraction part of the loop, it
increments a counter. That count is just the quotient, i.e.  the
number of times that divisior "fits" within the number it's dividing.
Having done that, it exits the loop when an amount smaller than the
divisor remains, and then reports the quotient and the remainder.

### Some more instructions

There are a few new instructions here worth discussing here.

• REGISTER-REGISTER SUBTRACT (UNTRAPPED)

&nbsp;&nbsp;&nbsp;&nbsp;`SUBU` *target*`,` *source1*`,` *source2*

This takes the value stored in the first specified source register,
subtracts the second source register from that value, and puts that
difference computed into the target register. It does not change
the values of the source registers (unless, of course, one of them
also happens to be the target). 

It's possible that subtraction can lead to strange results, since the
register values are limited to only 32 bits. These kinds of things
(an "underflow") are errors that the processor can catch and handle
(this kind of handling is called a "trap") with some system routine.
In this case, however, we are using the "untrapped" version of
the instruction, hence the `U` at the end of its name, and so with
this instruction no exceptional errors are raised.

• BRANCH-IF-LESS-THAN

&nbsp;&nbsp;&nbsp;&nbsp;`BLT` *source1*`,` *source2*

We described this instruction earlier, above when we talked about the
use of the `BEQZ` and `B` instructions in the multiplication program.
Here we want to continue the subtracting loop when the remainder being
computed (in `t2`) is at least as large as the divisor (held in `t1`).
That means that we want to exit the loop when `t2` is less than `t1`,
i.e. is a proper remainder due to the division. And so we use the
branch

    blt $t2,$t1,done

• REGISTER-REGISTER MOVE

&nbsp;&nbsp;&nbsp;&nbsp;`MOVE` *target`,` *source*

This is probably a poorly-named instruction. I get why its called
"move", however it confuses beginning assembly programmers. It
takes the value stored in the source register and puts it in the
target register. This, among several students, has consistently
led to the question "And so what's the value of *source* after
the `MOVE`?" The answer is "That register doesn't change."
So that means that, after `MOVE`, both registers will hold
the bits of the same value. For example if, before the 
following instruction `t5` holds the value 82 and `a0` holds
the value 77, then after executing

    move $a0,$t5

both `t5` and `a0` will both store a value of 82. Had the designers
of MIPS imagined teaching new programmers, they probably would have 
instead named the instruction `COPY`. 

It's not like a register can then become *empty*, or lacking a value.
No matter what, a register holds 32 binary values, and each is either
0 or 1.  So a `MOVE` does not "empty" nor "clear" the storage of the
source register. The move instruction is akin to the C++ variable
assignment:

    target = source;

---

## Assembly program structure

In the two example MIPS assembly programs I've given above, I've
purposely given the "kernel" of the code. These have been a series of
machine instructions and with some of them labelled. And, in some
sense, these are meant to be the main "take-away" of this portion of
the course: programs written in "high-level" languages like C++ are
not executed directly by the computer. Rather, they are compiled into
machine code, and *that machine code* is what actually gets
executed. And then here, with our study of MIPS32, we are learning
what those low-level machine instructions look like, and then relating
them to the original higher-level code of the program that was first
written.

### Assembler program versus machine code

We keep using the words "assembly language" or "assembler language",
etc. As we saw during the LogiSim circuit unit, the characters in the
assembler instruction

    ADD $t0, $t1, $t2

are not the text of the actual machine instruction. Instead, MIPS32
processors execute a series of 32-bit instructions. So the instruction
above is a human-readable rendering of the actual code. The code for
that instruction happens to be

    012A4020

in hexadecimal which is the 32 bit code

    0000 0001 0010 1010 0100 0000 0010 0000
    
in binary. This is because those three registers happen to be coded as
01000, 01001, and 01010 within the instruction and because bits 6 through
10 of the instruction code *source1*, 11 through 15 code *source2*, and
16 through 20 code *target*. So we should read that instruction's bits 
instead as

    000000-01001-01010-01000-00000100000

and the other parts (the prefix and the suffix) specify that an `ADD`
of two registers into a third is being particularly requested by the
program.

So, machine code instructions look like thus

    00000001001010100100000000100000

but assembler instructions look like thus

    ADD $t0, $t1, $t2

So, there is of course some work to be done when you've written
a MIPS32 assembly program. That program's code still needs to be
*assembled* into a the bits of the machine code. And that assembling
of the program's bits is the job of an *assembler*. So, in actuality,
when we are writing assembly code, we are communicated to an assembler,
not directly to the processor.

### The program's binary image

In actual practice, an assembler produces a *binary file* as its
output. Contained in that file is the sequence of bits that make up
the program. When a program is run, the contents of that file get
loaded into the computer memory, and then the system tells the
processor to jump to the first instruction of the `main` procedure
within that binary code.

This forces us to introduce even more terminology. The operating system
of the processor-memory hardware of a computer loads a *binary image*
of the program from the program's *executable file*.  It then tells the
processor to jump to the first instruction (for `main`) within that
loaded image. The assembler, then, *assembles this binary image* into
an executable file.

### Segments of a binary image

Since the program gets loaded into the computer memory, it turns out that
other things can be included in the binary image. For example, a prompt
string like

    "Please enter a positive number: "

is also stored within the binary image. After all, its part of the
program.  It turns out that this kinds of data: string literals
referenced within the code, and global variables (with some initial
value) accessible by all parts of the code, fixed initial arrays
of data, these are also part of the binary image of the program.
Storage of this kind of data is not held within the machine instructions,
rather it is put in a different *segment* of the program's memory.

There are two kinds of segments in the program's memory image:
there is a *data segment* for storage of strings and global data
structures, and there is a *text segment* for storage of the binary
coded instructions of the program. When a program runs, the binary 
codes for instructons are "fetched" from the text segment section
of the memory. The program itself, then, will instruct the processor
to fetch and update the information stored in the data segment 
section of the memory.

This finally explains the `.data` and `.text` directives within the
assembler program code we've written. Erasing the instructions
themselves, here is the code for our full solution to Exercise 1 of
Homework 07, in the `samples` file `multiply-verbose.asm`:

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
        ...
    multiply:	
    	...
    report:
        ...    	
    end_main:
    	li	$v0, 0		# return 0
    	jr	$ra		#
    
    
The lines of code that starts with the number sign `#`, and also any
stuff that follows the number sign within a line of code, these are my
comments. The number sign in MIPS assembly is like the `//` comment
start in C++. But then all the code below the line

    .text

are machin instructions. These will be assembled into the text segment 
of the binary image. And then all the code below the line 

    .data

but before the `.globl main` line will be laid out as data structures
within the program's memory image. For example, the line

    feedback: .asciiz "Enter an integer: "

tells the assembler to lay out 19 bytes of characters forming that
string in ASCII binary code, one byte for each character, in that part
of the program's data segment in memory.  That string is 18 characters
long, but then the `z` in the directive tells the assembler to include
a null character, the special character with code 0, as the 19th 
character in that laid out data.

### Data segment directives

Let's give a shorter example:

    hello_ptr: .asciiz "Hi!\n"

This makes room in the data segment for 5 characters, the values

    72, 105, 33, 10, 0
    
The first three are the ASCII codes (written in decimal notation) for
the string `"Hi!"`, the 10 is the code for the end-of-line character,
and then the 0 is the code that indicates that we're at the string's 
end.

Note that the `.asciiz` lines also include a label. That label can be
used within the instructions to refer to the place in memory where that
string is laid out. The instruction

    la $a0,hello_ptr

for example, tells the processor to put the address where the string 
"Hi!\n" starts in memory into register $a0. This allows us, for example,
to output that null-terminated string with system call #4, as follows

    la $a0,hello_ptr
    li $v0,4
    syscall

System call #4 knows to look in the argument register `a0` for the address
of the string it needs to output to the console. It scans through that region
of memory, outputting each of those characters one-by-one, until it hits that
special null character indicateing the string's end.

The assembler, when assembling the code into the binary image, will know the
address that corresponds to the label `hello_ptr` as well 

There are several other directives that can be used to lay out data in memory.
If we include the line

    value: .word 100

then that reserves space within the data image for four bytes of data, namely,
the bytes of the constant 100. (This happens to be the value

    00 00 00 5a

in hexadecimal, so the last byte is the bits 01101010.) We can then, for example,
fetch this value from memory, increment it within a register, then store it back to
that area of memory with the instructions

    la $a0,value
    lw $t0,($a0)
    addiu $t0,$t0,10
    sw $t0,($a0)

and that will replace the value 100 living at the address `value` with the value
110 within the computer memory. We talk more about this instruction sequence below.

It's also possible to store an array of integers with the directive

    some_squares: .word 1,4,9,16,25

This lays out an array of five integers consecutively in the program's data segment
of memory. And code like 

    la $a0,some_squares
    lw $t0,0($a0)
    lw $t1,1($a0)
    addu $t0,$t0,$t1
    lw $t1,2($a0)
    addu $t0,$t0,$t1
    lw $t1,3($a0)
    addu $t0,$t0,$t1
    lw $t1,4($a0)
    addu $t0,$t0,$t1

will sum those five values into the register `t0`. We'll
explain this sequence in the next lecture.

Finally, this directive reserves space for 12 bytes in the data segment

    some_data: .space 12

and so the code below, for example, treats that as an array of three
integers and fills it with the first three prime numbers:

    la $a0,some_data
    li $t0,2
    sw $t0,($a0)
    addiu $a0,$a0,4
    li $t0,3
    sw $t0,($a0)
    addiu $a0,$a0,4
    li $t0,5
    sw $t0,($a0)

Again, we'll talk about this kind of example code more in the next lecture.
Suffice it to say, here, that we are able to use a combination of the
`.data` directive, and data layout directives `.asciiz`, `.word`, and `.space`
to flesh out the contents of a program's memory image with items other
than instruction codes. The assembler is directed by these to do that.

---

## Reading and writing memory, a preview

