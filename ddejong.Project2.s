#Dion's Multiplication and Division calculator:
#@author Dion de Jong
#@version 1
#Class: CSCE 212-002
#Date: 4/1/14

.data
Quotient: .asciiz "The quotient is: "
Remainder: .asciiz "The remainder is: "
Product: .asciiz "The product is: "
DividebyZero: .asciiz "You are dividing by 0! This also means the product is 0"
TooBig: .asciiz "The product is too large a number."
UserInputa: .asciiz "Please enter your first whole number between 0 and 65535. This is the dividend and multiplicand." 
UserInputb: .asciiz "Please enter your second whole number between 0 and 65535. This is the divisor and multiplier." 
newline: .asciiz "\n"

.text 
main:
addi $t0, $zero, 2 #Counter for the input comparison
addi $t2, $zero, 16 #Counter for multiplication loop
addi $t9, $zero, 0 #Counter for Division loop. 

EntryTest:
beq $t0,2,DataEntry1 #Are any numbers entered? If not jump to the first DataEntry
beq $t0,1,DataEntry2 #Is one number entered? If so jump to the second DataEntry
beq $t0,$zero,Multiply #Are both numbers entered? If so jump to Multiply

DataEntry1: 
la $a0,UserInputa #Load the string that tells the user to input values into $a0
li $v0,4  #Load 4 into $v0 so the syscall will print the string
syscall
li $v0,5 #Load 5 into $v0 to read what the user inputs: 
syscall
add $s0, $v0, $zero #Save the value to the $s0 register which is the dividend and multiplicand register
add $s4, $v0, $zero #Save the value to the $s4 register that holds the remainder for the division loop
add $t3, $v0, $zero #Save the value to the $t3 register (used for multiplication loop.)
add $t6, $v0, $zero #Save the value to the $t6 register (used for the division loop.)
addi $t0, $t0, -1 #remove one from the data entry loop counter
j EntryTest #Jump to the beginning of the loop so that the loop can compare the counter and move forward.

DataEntry2: 
la $a0,UserInputb #Load the string that tells the user to input values into $a0
li $v0,4  #Load 4 into $v0 so the syscall will print the string
syscall
li $v0,5 #Load 5 into $v0 to read what the user inputs: 
syscall
beq $v0, $zero, Zero  #if this value is 0, the user is dividing by 0 and that's not cool.
add $s1, $v0, $zero #Save the value to the $s1 register which is the divisor and multiplier register
add $t4, $v0, $zero #Save the value to the $t4 register (used for multiplication loop.)
add $t7, $v0, $zero #Save the value to the $t7 register (used for the division loop.)
sll $t7, $t7, 15 #in order for division to correctly work, the number must be shifted over 16 bits to account for the 16 iterations and the maximum 16 bit numbers
addi $t0, $t0, -1 #remove one from the data entry loop counter
j EntryTest #Jump to the beginning of the loop so that the loop can compare the counter and move forward.

#Print "method"
Print:
Overflow: #The catch in case the product goes into overflow. 
beq $t0, 0, PrintProduct #if the answer is not overflowed, jump to normal print. 
la $a0,TooBig #Load the string that tells the user about overflow into $a0
li $v0,4  #Load 4 into $v0 so the syscall will print the string
syscall
li $v0,4 
la $a0,newline #Print a new line for formatting. 
syscall
j PrintQuotient #if this line executes, the product overflowed and we need to print the Quotient now

PrintProduct:
li $v0,4 
la $a0,Product
syscall #show the message that will display when the product displays
li $v0,1 #Load display int command value into #V0 
addi $a0,$s2,0 #Load the register value holding the product into #A0 to display
syscall
li $v0,4 
la $a0,newline #Print a new line for formatting.
syscall

PrintQuotient: 
li $v0,4 
la $a0,Quotient 
syscall #show the message that will display when the quotient displays
li $v0,1 #Load display int command value into #V0 
addi $a0,$s3,0 #Load the register value holding the quotient into #A0 to display
syscall
li $v0,4 
la $a0,newline #Print a new line for formatting.
syscall

li $v0,4 
la $a0,Remainder
syscall #show the message that will display when the remainder displays
li $v0,1 #Load display int command value into #V0 
addi $a0,$s4, 0 #Load the register value holding the remainder into #A0 to display
syscall
li $v0,4 
la $a0,newline #Print a new line for formatting.
syscall
j Exit #Jump to exit to exit cleanly


Multiply: #Multiply method
andi $t1, $t4, 1 #test the least significant bit, the value of this bit is placed in t1
beq $t1, $zero, Shift #if the bit is zero, nothing is added to the product and we jump to the shift
addu $s2, $t3, $s2 #check if the latest addition caused overflow by using addu (no overflow)
slti $t0, $s2, 0 #check if the signs switched
beq $t0, 1, Divide # if they did jump to Divide and print out this result in the print method
subu $s2,$s2, $t3 #if the signs don't change subtract the unsigned addition and add it normally. 
add $s2, $t3, $s2 #if the bit is one, add neccessary value to the product register

#bge $s2, 4294967296, Divide #check if the latest addition caused overflow, if it does, jump to divide and display overflow message in print

Shift:
sll $t3, $t3, 1 #following the algorithm the multiplicand is shifted left 1 after each iteration
srl $t4, $t4, 1 #following the algorithm the multipier is shifted right 1 after each iteration, so that the new sigificant bit can be tested. 
addi $t2, $t2, -1 #subtract one from the multiply counter to ensure there are only 16 iterations
beq $t2, $zero, Divide #once the counter is 0, multiplying is done and we go to divide. 
j Multiply #if the counter is not 0, there is another iteration of multiply we must do. 

Divide: #Divide method. 
sub $s4, $s4, $t7 #following the algorithm start off by subtracting the 16 shifted divisor from the remainder (dividend) 
bge $s4 $zero, IfPositive #test if the new remainder is postive or negative if positive jump

IfNegative: #if the new remainder is negative these commands occur
add $s4, $s4, $t7 #the divisor that was subtracted is added back to retain the original remainder value. 
sll $s3, $s3, 1 #quotient register is shifted by one bit
j DivideShift

IfPositive: #if the new remainder is positive these commands occur
sll $s3, $s3, 1 #quotient register is shifted by one bit
addi $s3, $s3, 1 #and the least significant bit is made 1

DivideShift: #Regardless these commands occur every iteration
srl $t7, $t7, 1 #The divisor must be shifted to the right
addi $t9, $t9, 1 #this adds one to the division counter
blt $t9, 16, Divide #if there have not been 16 iterations, another iteration occurs, once we hit 16, the math part of the program is done.
j Print

Zero: #Divide by 0 catch
la $a0,DividebyZero #Load the string that tells the user he divided by 0. 
li $v0,4  #Load 4 into $v0 so the syscall will print the string
syscall
j Exit 

Exit:
li $v0,10 #Close cleanly 
syscall

