#Dion's Floating Point Addition calculator:
#@author Dion de Jong
#@version 1
#Class: CSCE 212-002
#Date: 4/28/14

.data
#messages to display at different points in program. 
InputA: .asciiz "Enter a decimal number." 
InputB: .asciiz "Enter another decimal number." 
Answer: .asciiz "The answer is: "

.text 

main:
addi $t9, $zero, 1
sll $t9, $t9, 24 #Register with one in 24th bit
addi $t8, $zero, 1
sll $t8, $t8, 23 #Register with one in 23rd bit

DataEntry: 
#Store First Float
la $a0,InputA #Load the string that tells the user to input values into $a0
li $v0,4  #Load 4 into $v0 so the syscall will print the string
syscall
li $v0,6 #Load 6 into $v0 to read what the user inputs: 
syscall
mfc1 $s6, $f0 #move the first float from the coprocessor to a usable register by MIPS 

#Store second float
la $a0,InputB #Load the string that tells the user to input values into $a0
li $v0,4  #Load 4 into $v0 so the syscall will print the string
syscall
li $v0,6 #Load 6 into $v0 to read what the user inputs: 
syscall
mfc1 $s7, $f0 #move the second float from the coprocessor to a usable register by MIPS 

ManipulateFloat:
move $t0,$s6
srl $t0, $t0, 31 #The least significant bit of this register is the first floating point sign bit

move $t3,$s7
srl $t3, $t3, 31 #The least significant bit of this register is the second floating point sign bit

move $t1, $s6 
sll $t1, $t1, 1
srl $t1, $t1, 24 #The least significant bits of this register are the first floating point's exponent bits

move $t4, $s7 
sll $t4, $t4, 1
srl $t4, $t4, 24 #The least significant bits of this register are the second floating point's exponent bits

move $t2, $s6
sll $t2, $t2, 9
srl $t2, $t2, 9 #The least significant bits of this register are the first floating point's fraction bits
or $t2, $t2, $t8

move $t5, $s7
sll $t5, $t5, 9
srl $t5, $t5, 9 #The least significant bits of this register are the second floating point's fraction bits
or $t5, $t5, $t8

MathPart: 

Exponent:
add $s1, $t1, $0 # make the final exponent
beq $t1, $t4, AddFrac # if exponents are the same, we can immediately add the fractions to get our answer
bgt $t1, $t4, FirstGreater #Case 1, the first exponent is bigger. 

FirstLesser: 
sub $t6, $t4, $t1 #$t4 gets the value of the bigger exponent minus the smaller one. This is the counter for the shift loop. 
add $s1, $t4, $0 # makes the value of the exponent the value of the larger exponent

LesserLoop: #The shift loop that will shift the smaller exponent over until the exponents are the same. 
beq $t6, $0, AddFrac #test to see if the counter is greater than 0, if not, the exponents are the same. 
srl $t2, $t2, 1 #Shift the smaller exponent's fraction right 1
addi $t6, $t6, -1 #decrement the counter
j LesserLoop #Go through loop again.

FirstGreater:
sub $t6, $t1, $t4 #$t6 gets the value of the bigger exponent minus the smaller one. This is the counter for the shift loop. 
add $s1, $t1, $0 # makes the final exponent value the value of the larger exponent

GreaterLoop: #The shift loop that will shift the smaller exponent over until the exponents are the same. 
beq $t6, $0, AddFrac #test to see if the counter is greater than 0, if not, the exponents are the same. 
srl $t5, $t5, 1 #Shift the smaller exponent's fraction right 1
addi $t6, $t6, -1 #decrement the counter
j GreaterLoop #Go through loop again. 

AddFrac: #The Fractions must now be added
beq $t0, $t3, equalSigns #If the sign bits are equal jump
bgt $t2, $t5, Greater # branch if frac1 > frac2

sub $s2, $t5, $t2 #if t5 is greater, then subtract t2 from it and save it
add $s0, $t3, $zero #keep the larger fractions sign
sll $s0, $s0, 31 #shift sign appropriately 
j normalize

Greater: 
sub $s2, $t2, $t5 #if t2 is greater, then subtract t2 from it and save it
add $s0, $t0, $zero #keep the larger fractions sign
sll $s0, $s0, 31 #shift sign appropriately
j normalize

equalSigns:
add $s2, $t2, $t5 #Just add the two fractions together 
add $s0, $t0, $zero #keep the sign 
sll $s0, $s0, 31 #Shift it appropriately in the final register

normalize:
and $t0, $t9, $s2 # get 24th bit of frac add result
beq $t0, $zero, NoOverFlow # if zero, there is no overflow
andi $t0, $s2, 1 # get lsb of frac add result
srl $s2, $s2, 1 # shift frac right 1
add $s2, $s2, $t0 # round up by adding lsb from before shift
addi $s1, $s1, 1 # increment final exponent
j FloatFinal

NoOverFlow:
and $t0, $t8, $s2 # get 23rd bit of resultant fraction
bne $t0, $zero, FloatFinal #if there is a one in the 23rd bit, we're done
sll $s2, $s2, 1 # if there isnt a 1 in 23rd bit, shift frac left 1
addi $s1, $s1, -1 # decrement exponent
j NoOverFlow


FloatFinal:
li $s4, 0 # this will hold final fp value
or $s4, $s4, $s0 #put sign into final packaged floating point value
sll $s1, $s1, 23 # shift exponent into its proper place
or $s4, $s4, $s1 #put shifted exponent value to final fp register
sll $s2, $s2, 9 # shift fraction left to get rid of leading 1, which we no longer need
srl $s2, $s2, 9 # shift fraction right back to the right position
or $s4, $s4, $s2 #add fraction to the final packaged floating point value

print: 
la $a0, Answer #Load the string that tells the user to input values into $a0
li $v0, 4  #Load 4 into $v0 so the syscall will print the string
syscall
mtc1 $s4, $f12 #Move the final float to the coprocessor to be appropriately printed 
li $v0, 2 #Syscall command to print a float
syscall

Exit:
li $v0, 10 #Close cleanly 
syscall
