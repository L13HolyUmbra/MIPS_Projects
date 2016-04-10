#Dion's Bubble Sort:
#@author Dion de Jong
#@version 1
#Class: CSCE 212-002
#Date: 3/1/14

.data
vals: .space 4000
UserInput: .asciiz "Please enter any whole number or enter 9999 if you are done entering values." 
SortedTable: .asciiz "The sorted Array is: " 
Space: .asciiz " " 

.text 

main:
addi $s0, $zero, 9999 #value to compare to to see if user is finished entering numbers
addi $s1, $zero, 0 #value for n 
addi $s2, $zero, 0 #value n-1

DataEntry: 
la $a0,UserInput #Load the string that tells the user to input values into $a0
li $v0,4  #Load 4 into $v0 so the syscall will print the string
syscall

li $v0,5 #Load 5 into $v0 to read what the user inputs: 
syscall

beq $v0,$s0,Sort #Does what the user typed in equal 9999? if it does jump to the Sort
sw $v0, vals($s1) #Save the value to the incremented address of the array
addi $s1, $s1, 4 #increment the counter for the array pointer (the next value to be filled or n) 
addi $s2, $s1,-4 #increment n-1
j DataEntry #Jump to the beginning of the loop so that the user can type another value


Print:
li $v0,4 
la $a0,SortedTable
syscall #show the message that will display when the user prints the array

li $t0, 0 #t1 gets 0


Printval:
slt $t2,$s2,$t0 #Set t2 to 1 if s2(the pointer for the last filled value) has been matched by the print loop's incremementer
beq $t2,1, Exit #done printing if the t2 value was set 1 

lw $a0,vals($t0) #load the value of each incremented value to a0
li $v0,1
syscall #display each of these loaded values

la $a0,Space
li $v0,4
syscall #add a space to the loaded values

addi $t0, $t0, 4 #increment the print loop

j Printval #Repeat the loop

Sort:
addi $t0,$zero,0 #counter for outside loop i = 0

loop1:
bgt $t0,$s1,Print #if first loop's increment is greater than the counter of the array
addi $t0,$t0, 4 #increment 

addi $t1,$zero,0 #create second counter  j = 0
loop2:
bge $t1,$s2,loop1 #if the second loops increment is greater than or equal to the last filled space, jump out and go to first loop

addi $t2,$t1,4 #saved value for j+1
addi $t5,$t1,0 #saved value for j

lw $t3, vals($t1) #save [j] into t3
lw $t4, vals($t2) #save [j+1] into t4

addi $t1, $t1, 4 #increment j

bgt $t4, $t3, loop2 #is t4 > t3? if yes then leave it. if t3 is greater switch

sw $t3,vals($t2) #the bigger value goes later
sw $t4,vals($t5) #the smaller value is earlier


j loop2 #repeat the loop

Exit:
li $v0,10 #Close cleanly 
syscall