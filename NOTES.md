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

    0. Logistics for the course
    I. Review of several individual instructions
     A. Example: homework 07 multiplication exercise
     B. LI
     C. ADDU, ADDIU
     D. BEQZ, B, labels
     E. code structure
     F. system calls
      1. get integer 
      2. put integer
      3. deferred: put string
     G. returning from main
    II. Example: integer quotient exercise
     A. MIPS code
     B. C++ code
     C. BLT and SUBU instructions
    III. review of program structure
     A. header, .data vs .text
     B. labels, code
     C. comments
    IV. reading and writing memory
     A. reading an integer word from .data
     B. LA and LW instructions
     C. increment a word in memory
     D. SW instruction
     E. LB and SB instructions
     F. example: write "bye" into space of hello
    V. exercises for next meeting
---
 
## Lecture

---

### Some logistics

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

### MIPS Review

Let me review the code you should now be used to writing, having 
completed Homework 07. Before I begin, let me offer this link
to [a course on MIPS](https://chortle.ccsu.edu/AssemblyTutorial/index.html#part4)
from Central Connecticut State. It may teach more than I do, and
emphasize different aspects of MIPS, but you still might find
it helpful.

Here is an excerpt from my solution to Exercise 1, a MIPS
program that multiplies two integers that are imput within
the console, then reports that product to the console:

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

Here is similar code, written in C:

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

As you are now seeing, there are a family of these branch 
instructions. There are these comparisons with zero:

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

MORE NOTES TO COME

    






