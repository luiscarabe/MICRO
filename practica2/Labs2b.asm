;**************************************************************************
; 2bd DELIVERABLE - Labs2b.asm
; Juan Riera, Luis Carabe
; Group 2351 Team 02
;**************************************************************************
; DATA SEGMENT DEFINITION
DATOS SEGMENT
; Here we have an auxiliar endline in case we want to print any
endline db 13, 10, '$' ;Auxiliar endline string
; This string is the one printed so that the user knows that they 
; have to type a two digit number between 0 and 15  
askuser db "Please enter a two digit number between 0 and 15:", 13, 10, '$'
; This variable will be used to store whatever the user types
character db 2, 3 dup(0)
; In this variable will be stored the results of the computations
result db 4 dup(0), '$'
; This string stores the error message
errormessage db "Error: incorrect data", 13, 10, '$'
COUNTER DW 0 ; Reserve memory for the counter (index to store the result in prodVECTOR), one word (two bytes), set to 0
dataVECTOR DB 4 dup(?) ; Reserve memory for the input data vector (4 bytes)
prodVECTOR DB 7 dup(0) ; Reserve memory for the result of dataVECTOR * genMATRIX (7 bytes)
genMATRIX DB 1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1,1,1,0,1,1,0,1,1,0,1,1,1 ; Generation MATRIX (transposed), in form of array
; We will need this matrix to compute the parity bits
; We transpose the matrix in order to simplify the product operation (we prefer to multiply the dataVECTOR using 
; genMATRIX rows instead of the columns)
; The next variables are  the strings that will be printed to show the result in a matrix
input db "Input: ", '$'
output db "Output: ", '$'
computation db "Computation: ", 13, 10, "     | P1 | P2 | D1 | P4 | D2 | D3 | D4  ", 13, 10, "Word | ", '$'
separator db "  | ", '$'
p1 db "P1   | ", '$'
p2 db "P2   |    | ", '$'
p4 db "P4   |    |    |    | ", '$'
DATOS ENDS			  
;**************************************************************************
; STACK SEGMENT DEFINITION
PILA SEGMENT STACK "STACK"
DB 40H DUP (0) ; initialization of the stack, 64 bytes set to 0
PILA ENDS
;**************************************************************************
; EXTRA SEGMENT DEFINITION
EXTRA SEGMENT
EXTRA ENDS
;**************************************************************************
; CODE SEGMENT DEFINITION
CODE SEGMENT
ASSUME CS: CODE, DS: DATOS, ES: EXTRA, SS: PILA
; BEGINNING OF THE MAIN PROCEDURE
INICIO PROC
; INITIALIZE THE SEGMENT REGISTERS
MOV AX, DATOS
MOV DS, AX
MOV AX, PILA
MOV SS, AX
MOV AX, EXTRA
MOV ES, AX
MOV SP, 64 ; LOAD THE STACK POINTER WITH THE HIGHEST VALUE

; PROGRAM START
start: CALL GETASCIIFROMUSER ; Ask for a number
MOV AL, character[1] ; See how many characters the user typed
CMP AL, 0 ; If they typed 0 characters
JZ ERRORMSG1 ; We display the error and start again
CMP AL, 1  ; If they typed one character
JZ ONECHAR ; We transform it from ascii to binary
CALL TWOCHAR ; Else it should be two characters long, because
			 ; we stored in character[0] a 2 number, so that 
			 ; the user could not type more than two characters

division: CMP AL, 15 ; Before we make the division, we need to
JG ERRORMSG1 ; make sure that the number is lower than 15
MOV CL, 0 ; and that it is not lower than 0
CMP CL, AL
JG ERRORMSG1
MOV SI, 3 ; We will use the SI as a pointer in the result variable
		; to store the bytes in theis positions
             	MOV CL, 2 ; We are going to divide by 2
				
divisionloop:	MOV AH, 0 ; We prepare AH
				MOV DX, 0 ; and DX for the division
				DIV CL ; perform the division
				MOV DL, AH ; We move the remainder to DL
				MOV DH, 0h ; Store a 0 in DH
				ADD DX, 30h  ; Convert the number to ascii
				MOV result[SI], DL ; Store the remainder in ascii in
									; the correct position of the variable
									; result
				SUB SI, 1 ; Subtract 1 to SI because we are starting from the
						; HIGHEST position to the lowest
				CMP AL, 0 ; If the quotient is 0 we are done
				JNZ divisionloop ; If not we start the loop again

; Now we print an end of line
MOV AH, 09h
MOV DL, OFFSET endline
INT 21h
; We could print the result of the previous computation by
; uncommenting the next two lines
;MOV DL, OFFSET result	
;INT 21h

; Here we load the result of the previous computation in the
; registers where the function of the previous exercise
; needed it 
MOV DH, result[0]
MOV DL, result[1]
MOV BH, result[2]
MOV BL, result[3]
CALL MULTMATRIX ; Call to the function that multiplies the recently stored vector with the genMATRIX
CALL PRINTRES ; Call the function that prints the result of the previous function

; PROGRAM END
MOV AX, 4C00H
INT 21H
errormsg1: JMP errormsg ; Auxiliar jump for far jumps
INICIO ENDP

; Auxiliar function called when the user introduces a
; one character number and converts it to binary in AL
ONECHAR PROC
ONECHAR: MOV AL, character[2] ; Load the ascii character
	SUB AL, 30h ; Change from ascii to number
	JMP division ; Continue the program
ONECHAR ENDP

; Auxiliar function called when the user introduces a
; two character number and converts it to binary in AL
TWOCHAR PROC
	MOV AL, character[2] ; Load the tens in AL
	SUB AL, 30h ; Get the numeric value (not ascii)
	MOV AH, 0 ; Expand the number to the whole AX
	MOV CL, 10 ; Load a 10 in CL for the multiplication
	MUL CL ; We get the tens positional numeric value
	MOV DL, character[3] ; We get now the units ascii
	SUB DL, 30h ; Get the numeric value
	ADD AL, DL ; Sum both numbers
	JMP division ; Continue the program
TWOCHAR ENDP

; Auxiliar function called when the user types an incorrect
; number. The function displays a message and restarts the program
ERRORMSG PROC
ERRORMSG:	MOV DX, OFFSET errormessage ; Point at the variable
	MOV AH, 09h ; Load the function
	INT 21h ; Interrupt
	JMP start ; jump to the start of the program
ERRORMSG ENDP
	
; Auxiliar function that asks the user for a number and
; stores it into the chracter variable
GETASCIIFROMUSER PROC
	; Print the message asking the user for a number
	MOV DX, OFFSET askuser ; Point at the variable
	MOV AH, 09h ; Load the function
	INT 21h ; Interrupt
	
	; Store what the user typed in the variable character
	MOV AH, 0AH ; Point at the variable
	MOV DX, OFFSET character ; Load the function
	MOV character[0], 3 ; The number can be 2 bytes long maximum 
	INT 21h ; Interrupt
ret
GETASCIIFROMUSER ENDP

MULTMATRIX PROC 

; We receive the 4-bits input number in registers DX:BX
; We must store the number in memory
MOV dataVECTOR[0], DH
MOV dataVECTOR[1], DL
MOV dataVECTOR[2], BH
MOV dataVECTOR[3], BL

MOV DI, 0 ; We are going to use DI as an index to the matrix rows, so we initialize it with a 0 (first row)

SETMULT:	MOV BX, 0 ; We are going to use BX as an index to the matrix columns, we store a 0 in it (first column)
			MOV DX, 0 ; We are going to use DX as the partial sum of each row product

MULT:		MOV AL, dataVECTOR[BX] ; First operand of the product (appropriate number of dataVECTOR) (we need to store it at AL because we are using 8-bit operands)
			MOV CL, genMATRIX[BX][DI] ; Second operand of the product stored in CL (appropriate number of genMATRIX)
			MUL CL ; Multiply AL with CL, result in AX
			ADD DX, AX ; Add the result to the partial sum of the row product
			INC BX ; Increment the column of the product
			CMP BX, 4  ; Substract 4 from BX to see if we have multiply every 4 numbers of the row 
			JNZ MULT ; If not, we continue multiplying, without setting BX or DX
			MOV BX, COUNTER ; We move the content of COUNTER to BX, so we can properly write the result of the product 
			MOV prodVECTOR[BX], DL ; Store of the final row sum result in memory (prodVECTOR)
			INC COUNTER ; Increment the COUNTER 
			ADD DI, 4 ; Change to the next row by adding 4 to the row index (because we have 4 elements for each row and we are using an array as MATRIX)
			CMP COUNTER, 7 ; Substract 7 from COUNTER to see if we have multiply every row (the matrix has 7 rows)
			JNZ SETMULT ; If not, we continue multiplying other rows, so we need to set first the column index (BX) and partial sum (DX)
			
			; Now we may compute modulo 2 of the generated result vector 

			MOV BX, 0 ; BX is going to be the index of the vector
			MOV CL, 2 ; We assign the value 2 to CL, this register will be used as the divisor (MOD 2)
resMOD:		MOV AL, prodVECTOR[BX] ; We move the number to AL, this register will be used by div as the dividend (we are using an 8-bit operand)
			MOV AH, 0 ; Store a zero in AH, to ensure that we dont have unintended data
			MOV DX, 0 ; We must store a 0 in DX in order to use div properly	
			DIV CL ; We divide AL by CL (2), The result of the MOD operation is stored at AH (remainder)
			MOV prodVECTOR[BX], AH ; Change of the previous value, in consequence, now we have the number mod 2
			INC BX ; Increment index
			CMP BX, 7 ; Substract 7 from BX to see if we have done the operation to all the vector numbers (7)
			JNZ resMOD ; If not, we continue applying mod to the next vector number
			
MOV DX, SEG prodVECTOR ; Store of the result segment at DX
MOV AX, OFFSET prodVECTOR ; Store of the result offset at AX
ret ; Return to the procedure that called MULTMATRIX 

MULTMATRIX ENDP

PRINTINRESULT PROC


            MOV AH, 2h ; We prepare the function to print the ascii
			MOV DL, '"' ; We open quote marks
			INT 21h ; We call the interruption to print it
			MOV BX, 0 ; We are storing 0 in BX because we will use it
					  ; as a counter in the loop
printloop1: MOV DL, prodVECTOR[BX] ; We load the first byte to print it
            ADD DL, 30h ; Add 30h so that it is in ascii
            INT 21h ; Interruption to print the character (AH already has 2h
            		; so we don't have to store it again.
            MOV DL, ' ' ; Store in DL the ascii of a space so that we can print it
            INT 21h		; Interruption to print the ascii
            INC BX		; We increment the loop counter
            CMP BX, 3	; We check if it has the value 3
            JNZ printloop1 ; If it is still not three we jump back
            			   ; to the start of the loop
			
			; Now we do the same with the last character. 
			; It is outside the loop because it is not followed
			; by a space.
            MOV DL, prodVECTOR[3] ; We load the fourth digit (D4)
            ADD DL, 30h ; Convert it to ascii code
            INT 21h ; Interruption to print it on the screen
            
			; We close the quote marks
			MOV DL, '"' 
			INT 21h ; Interruption to print it on the screen
			
			
            MOV DX, OFFSET endline ; We print an end of line
            MOV AH, 9h ; We load the function to print a string
            INT 21h ; Interruption to print it on the screen
ret
PRINTINRESULT ENDP

PRINTOUTRESULT PROC
        
            MOV AH, 2h ; Load the function to print an ascii char 
			MOV DL, '"' ; Open quote marks
			INT 21h ; Interruption to print it on the screen
			
            MOV DL, prodVECTOR[4]  ; We load the P1 digit
            ADD DL, 30h ; Convert it to ascii code
            INT 21h ; Interruption to print it on the screen
			
            MOV DL, ' ' ; We print a space
            INT 21h ; Interruption to print it on the screen
			
            MOV DL, prodVECTOR[5] ; We load the P2 digit
            ADD DL, 30h ; Convert it to ascii code
            INT 21h ; Interruption to print it on the screen
			
            MOV DL, ' ' ; We print a space
            INT 21h ; Interruption to print it on the screen
			
            MOV DL, prodVECTOR[0] ; We load the D1 digit
            ADD DL, 30h ; Convert it to ascii code
            INT 21h ; Interruption to print it on the screen
			
            MOV DL, ' ' ; We print a space
            INT 21h ; Interruption to print it on the screen
			
            MOV DL, prodVECTOR[6] ; We load the P4 digit
            ADD DL, 30h ; Convert it to ascii code
            INT 21h ; Interruption to print it on the screen
            MOV DL, ' ' ; We print a space
            INT 21h ; Interruption to print it on the screen
			
            MOV DL, prodVECTOR[1] ; We load the D2 digit
            ADD DL, 30h ; Convert it to ascii code
            INT 21h ; Interruption to print it on the screen
            MOV DL, ' ' ; We print a space
            INT 21h ; Interruption to print it on the screen
			
            MOV DL, prodVECTOR[2] ; We load the D3 digit
            ADD DL, 30h ; Convert it to ascii code
            INT 21h ; Interruption to print it on the screen
            MOV DL, ' ' ; We print a space
            INT 21h ; Interruption to print it on the screen
			
            MOV DL, prodVECTOR[3] ; We load the fourth digit (D4)
            ADD DL, 30h ; Convert it to ascii code
            INT 21h ; Interruption to print it on the screen
			MOV DL, '"'
			INT 21h ; Interruption to print it on the screen
			
            MOV DX, OFFSET endline ; We print an end of line
            MOV AH, 9h ; We load the function to print a string
            INT 21h ; Interruption to print it on the screen
ret
PRINTOUTRESULT ENDP

; Auxiliar function to print a separator, which is the
; string "  | "
PRINTSEPARATOR PROC

            MOV AH, 9h ; We load the function to print a string
            MOV DX, OFFSET separator
            INT 21h ; Interruption to print it on the screen
ret
PRINTSEPARATOR ENDP

; Auxiliar function to print the P1 line in the matrix

PRINTP1 PROC
            MOV AH, 9h ; We load the function to print a string
            MOV DX, OFFSET p1
            INT 21h ; Interruption to print it on the screen

            MOV AH, 2h ; Load the function to print an ascii char
            MOV DL, prodVECTOR[4] ; We load the P1 digit
            ADD DL, 30h ; Convert it to ascii code
            INT 21h ; Interruption to print it on the screen

            CALL PRINTSEPARATOR

            MOV AH, 2h ; Load the function to print an ascii char
            MOV DL, ' ' ; We print a space
            INT 21h ; Interruption to print it on the screen

            CALL PRINTSEPARATOR

            MOV AH, 2h ; Load the function to print an ascii char
            MOV DL, prodVECTOR[0] ; We load the D1 digit
            ADD DL, 30h ; Convert it to ascii code
            INT 21h ; Interruption to print it on the screen

            CALL PRINTSEPARATOR

            MOV AH, 2h ; Load the function to print an ascii char
            MOV DL, ' ' ; We print a space
            INT 21h ; Interruption to print it on the screen

            CALL PRINTSEPARATOR

            MOV AH, 2h ; Load the function to print an ascii char
            MOV DL, prodVECTOR[1] ; We load the D2 digit
            ADD DL, 30h ; Convert it to ascii code
            INT 21h ; Interruption to print it on the screen 
            
            CALL PRINTSEPARATOR

            MOV AH, 2h ; Load the function to print an ascii char
            MOV DL, ' ' ; We print a space
            INT 21h ; Interruption to print it on the screen

            CALL PRINTSEPARATOR

            MOV AH, 2h ; Load the function to print an ascii char
            MOV DL, prodVECTOR[3] ; We load the fourth digit (D4)
			ADD DL, 30h ; Convert it to ascii code
            INT 21h ; Interruption to print it on the screen


            MOV DX, OFFSET endline ; We print an end of line
            MOV AH, 9h ; We load the function to print a string
            INT 21h ; Interruption to print it on the screen
ret
PRINTP1 ENDP

; Auxiliar function to print the P2 line in the matrix

PRINTP2 PROC

            MOV AH, 9h ; We load the function to print a string
            MOV DX, OFFSET p2
            INT 21h ; Interruption to print it on the screen

            MOV AH, 2h ; Load the function to print an ascii char
            MOV DL, prodVECTOR[5] ; We load the P2 digit
            ADD DL, 30h ; Convert it to ascii code
            INT 21h ; Interruption to print it on the screen

            CALL PRINTSEPARATOR

            MOV AH, 2h ; Load the function to print an ascii char
            MOV DL, prodVECTOR[0] ; We load the D1 digit
            ADD DL, 30h ; Convert it to ascii code
            INT 21h ; Interruption to print it on the screen

            CALL PRINTSEPARATOR

            MOV AH, 2h ; Load the function to print an ascii char
            MOV DL, ' ' ; We print a space
            INT 21h ; Interruption to print it on the screen

            CALL PRINTSEPARATOR

            MOV AH, 2h ; Load the function to print an ascii char
            MOV DL, ' ' ; We print a space
            INT 21h ; Interruption to print it on the screen 
            
            CALL PRINTSEPARATOR

            MOV AH, 2h ; Load the function to print an ascii char
            MOV DL, prodVECTOR[2] ; We load the D3 digit
            ADD DL, 30h ; Convert it to ascii code
            INT 21h ; Interruption to print it on the screen

            CALL PRINTSEPARATOR

            MOV AH, 2h ; Load the function to print an ascii char
            MOV DL, prodVECTOR[3] ; We load the fourth digit (D4)
			ADD DL, 30h ; Convert it to ascii code
            INT 21h ; Interruption to print it on the screen


            MOV DX, OFFSET endline ; We print an end of line
            MOV AH, 9h ; We load the function to print a string
            INT 21h ; Interruption to print it on the screen
ret
PRINTP2 ENDP

; Auxiliar function to print the P4 line in the matrix

PRINTP4 PROC

            MOV AH, 9h ; We load the function to print a string
            MOV DX, OFFSET p4
            INT 21h ; Interruption to print it on the screen
            
            MOV AH, 2h ; Load the function to print an ascii char
            MOV DL, prodVECTOR[6] ; We load the P4 digit
            ADD DL, 30h ; Convert it to ascii code
            INT 21h ; Interruption to print it on the screen

            CALL PRINTSEPARATOR

            MOV AH, 2h ; Load the function to print an ascii char
            MOV DL, prodVECTOR[1] ; We load the D2 digit
            ADD DL, 30h ; Convert it to ascii code
            INT 21h ; Interruption to print it on the screen 
            
            CALL PRINTSEPARATOR

            MOV AH, 2h ; Load the function to print an ascii char
            MOV DL, prodVECTOR[2] ; We load the D3 digit
            ADD DL, 30h ; Convert it to ascii code
            INT 21h ; Interruption to print it on the screen

            CALL PRINTSEPARATOR

            MOV AH, 2h ; Load the function to print an ascii char
            MOV DL, prodVECTOR[3] ; We load the fourth digit (D4)
			ADD DL, 30h ; Convert it to ascii code
            INT 21h ; Interruption to print it on the screen


            MOV DX, OFFSET endline ; We print an end of line
            MOV AH, 9h ; We load the function to print a string
            INT 21h ; Interruption to print it on the screen
ret
PRINTP4 ENDP

; Auxiliar function to print the result of the computation

PRINTRES PROC
            MOV AH, 9h ; We load the function to print a string 
            MOV DX, OFFSET input
            INT 21h ; Interruption to print it on the screen

            CALL PRINTINRESULT

            MOV AH, 9h ; We load the function to print a string 
            MOV DX, OFFSET output
            INT 21h ; Interruption to print it on the screen

            CALL PRINTOUTRESULT

            MOV AH, 9h ; We load the function to print a string
            MOV DX, OFFSET computation
            INT 21h ; Interruption to print it on the screen


            MOV AH, 2h ; Load the function to print an ascii char
            MOV DL, '?'
            INT 21h ; Interruption to print it on the screen

            CALL PRINTSEPARATOR

            MOV AH, 2h ; Load the function to print an ascii char
            MOV DL, '?'
            INT 21h ; Interruption to print it on the screen

            CALL PRINTSEPARATOR
			
            MOV AH, 2h ; Load the function to print an ascii char
            MOV DL, prodVECTOR[0] ; We load the D1 digit
            ADD DL, 30h ; Convert it to ascii code
            INT 21h ; Interruption to print it on the screen

            CALL PRINTSEPARATOR

            MOV AH, 2h ; Load the function to print an ascii char
            MOV DL, '?'
            INT 21h ; Interruption to print it on the screen

            CALL PRINTSEPARATOR
            
            MOV AH, 2h ; Load the function to print an ascii char
            MOV DL, prodVECTOR[1] ; We load the D2 digit
            ADD DL, 30h ; Convert it to ascii code
            INT 21h ; Interruption to print it on the screen

            CALL PRINTSEPARATOR

            MOV AH, 2h ; Load the function to print an ascii char
            MOV DL, prodVECTOR[2] ; We load the D3 digit
            ADD DL, 30h ; Convert it to ascii code
            INT 21h ; Interruption to print it on the screen

            CALL PRINTSEPARATOR

            MOV AH, 2h ; Load the function to print an ascii char
            MOV DL, prodVECTOR[3] ; We load the fourth digit (D4)
            ADD DL, 30h ; Convert it to ascii code
            INT 21h ; Interruption to print it on the screen

            MOV AH, 9h ; We load the function to print a string
            MOV DX, OFFSET endline ; We print an end of line
            INT 21h ; Interruption to print it on the screen

            CALL PRINTP1

            CALL PRINTP2

            CALL PRINTP4
ret
PRINTRES ENDP


CODE ENDS

END INICIO
