;**************************************************************************
; 2nd DELIVERABLE - Labs2a.asm
; Juan Riera, Luis Carabe
;**************************************************************************
; DATA SEGMENT DEFINITION
DATOS SEGMENT
COUNTER DW 0 ; Reserve memory for the counter (index to store the result in prodVECTOR), one word (two bytes), set to 0
dataVECTOR DB 4 dup(?) ; Reserve memory for the input data vector (4 bytes)
prodVECTOR DB 7 dup(0) ; Reserve memory for the result of dataVECTOR * genMATRIX (7 bytes)
genMATRIX DB 1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1,1,1,0,1,1,0,1,1,0,1,1,1 ; Generation MATRIX (transposed), in form of array
; We will need this matrix to compute the parity bits
; We transpose the matrix in order to simplify the product operation (we prefer to multiply the dataVECTOR using 
; genMATRIX rows instead of the columns)
input db "Input: ", '$'
output db "Output: ", '$'
computation db "Computation: ", 13, 10, "     | P1 | P2 | D1 | P4 | D2 | D3 | D4  ", 13, 10, "Word | ", '$'
separator db "  | ", '$'
p1 db "P1   | ", '$'
p2 db "P2   |    | ", '$'
p4 db "P4   |    |    |    | ", '$'
result db 2 dup(0)
endline db 13, 10, '$'
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
; Store of the data vector in DX:BX
MOV DH, 1
MOV DL, 0
MOV BH, 1
MOV BL, 1
CALL MULTMATRIX ; Call to the function that multiplies the recently stored vector with the genMATRIX
CALL PRINTRES
; PROGRAM END
MOV AX, 4C00H
INT 21H
INICIO ENDP

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
			JNZ MULT ; If not, we continue multiplying, without setting BX and DX
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

            MOV BX, 0
            MOV AH, 2h
			MOV DL, '"'
			INT 21h
printloop1: MOV DL, prodVECTOR[BX]
            ADD DL, 30h
            INT 21h
            MOV DL, ' '
            INT 21h
            INC BX
            CMP BX, 3
            JNZ printloop1
			
            MOV DL, prodVECTOR[3]
            ADD DL, 30h
            INT 21h 
            
			MOV DL, '"'
			INT 21h
			
            MOV DX, OFFSET endline
            MOV AH, 9h
            INT 21h
ret
PRINTINRESULT ENDP

PRINTOUTRESULT PROC
        
            MOV AH, 2h
			MOV DL, '"'
			INT 21h
			
            MOV DL, prodVECTOR[4]
            ADD DL, 30h
            INT 21h
			
            MOV DL, ' '
            INT 21h
			
            MOV DL, prodVECTOR[5]
            ADD DL, 30h
            INT 21h
			
            MOV DL, ' '
            INT 21h
			
            MOV DL, prodVECTOR[0]
            ADD DL, 30h
            INT 21h
			
            MOV DL, ' '
            INT 21h
			
            MOV DL, prodVECTOR[6]
            ADD DL, 30h
            INT 21h
            MOV DL, ' '
            INT 21h
			
            MOV DL, prodVECTOR[1]
            ADD DL, 30h
            INT 21h
            MOV DL, ' '
            INT 21h
			
            MOV DL, prodVECTOR[2]
            ADD DL, 30h
            INT 21h
            MOV DL, ' '
            INT 21h
			
            MOV DL, prodVECTOR[3]
            ADD DL, 30h
            INT 21h
			MOV DL, '"'
			INT 21h
			
            MOV DX, OFFSET endline
            MOV AH, 9h
            INT 21h
ret
PRINTOUTRESULT ENDP

PRINTSEPARATOR PROC

            MOV AH, 9h
            MOV DX, OFFSET separator
            INT 21h
ret
PRINTSEPARATOR ENDP

PRINTP1 PROC
            MOV AH, 9h
            MOV DX, OFFSET p1
            INT 21h

            MOV AH, 2h
            MOV DL, prodVECTOR[4]
            ADD DL, 30h
            INT 21h

            CALL PRINTSEPARATOR

            MOV AH, 2h
            MOV DL, ' '
            INT 21h

            CALL PRINTSEPARATOR

            MOV AH, 2h
            MOV DL, prodVECTOR[0]
            ADD DL, 30h
            INT 21h

            CALL PRINTSEPARATOR

            MOV AH, 2h
            MOV DL, ' '
            INT 21h

            CALL PRINTSEPARATOR

            MOV AH, 2h
            MOV DL, prodVECTOR[1]
            ADD DL, 30h
            INT 21h 
            
            CALL PRINTSEPARATOR

            MOV AH, 2h
            MOV DL, ' '
            INT 21h

            CALL PRINTSEPARATOR

            MOV AH, 2h
            MOV DL, prodVECTOR[3]
			ADD DL, 30h
            INT 21h


            MOV DX, OFFSET endline
            MOV AH, 9h
            INT 21h
ret
PRINTP1 ENDP


PRINTP2 PROC

            MOV AH, 9h
            MOV DX, OFFSET p2
            INT 21h

            MOV AH, 2h
            MOV DL, prodVECTOR[5]
            ADD DL, 30h
            INT 21h

            CALL PRINTSEPARATOR

            MOV AH, 2h
            MOV DL, prodVECTOR[0]
            ADD DL, 30h
            INT 21h

            CALL PRINTSEPARATOR

            MOV AH, 2h
            MOV DL, ' '
            INT 21h

            CALL PRINTSEPARATOR

            MOV AH, 2h
            MOV DL, ' '
            INT 21h 
            
            CALL PRINTSEPARATOR

            MOV AH, 2h
            MOV DL, prodVECTOR[2]
            ADD DL, 30h
            INT 21h

            CALL PRINTSEPARATOR

            MOV AH, 2h
            MOV DL, prodVECTOR[3]
			ADD DL, 30h
            INT 21h


            MOV DX, OFFSET endline
            MOV AH, 9h
            INT 21h
ret
PRINTP2 ENDP

PRINTP4 PROC

            MOV AH, 9h
            MOV DX, OFFSET p4
            INT 21h
            
            MOV AH, 2h
            MOV DL, prodVECTOR[6]
            ADD DL, 30h
            INT 21h

            CALL PRINTSEPARATOR

            MOV AH, 2h
            MOV DL, prodVECTOR[1]
            ADD DL, 30h
            INT 21h 
            
            CALL PRINTSEPARATOR

            MOV AH, 2h
            MOV DL, prodVECTOR[2]
            ADD DL, 30h
            INT 21h

            CALL PRINTSEPARATOR

            MOV AH, 2h
            MOV DL, prodVECTOR[3]
			ADD DL, 30h
            INT 21h


            MOV DX, OFFSET endline
            MOV AH, 9h
            INT 21h
ret
PRINTP4 ENDP


PRINTRES PROC
			;MOV ES, DX
	        ;MOV result, [ES:AX] ;Guardo a buen recaudo 
                              ;el contenido de AX:DX
                            ;ya que voy a necesitarlos ahora
            MOV AH, 9h ;Preparo la funcion a la que quiero llamar
            MOV DX, OFFSET input
            INT 21h

            CALL PRINTINRESULT

            MOV AH, 9h ;Preparo la funcion a la que quiero llamar
            MOV DX, OFFSET output
            INT 21h

            CALL PRINTOUTRESULT

            MOV AH, 9h
            MOV DX, OFFSET computation
            INT 21h


            MOV AH, 2h
            MOV DL, '?'
            INT 21h

            CALL PRINTSEPARATOR

            MOV AH, 2h
            MOV DL, '?'
            INT 21h

            CALL PRINTSEPARATOR
			
            MOV AH, 2h
            MOV DL, prodVECTOR[0]
            ADD DL, 30h
            INT 21h

            CALL PRINTSEPARATOR

            MOV AH, 2h
            MOV DL, '?'
            INT 21h

            CALL PRINTSEPARATOR
            
            MOV AH, 2h
            MOV DL, prodVECTOR[1]
            ADD DL, 30h
            INT 21h

            CALL PRINTSEPARATOR

            MOV AH, 2h
            MOV DL, prodVECTOR[2]
            ADD DL, 30h
            INT 21h

            CALL PRINTSEPARATOR

            MOV AH, 2h
            MOV DL, prodVECTOR[3]
            ADD DL, 30h
            INT 21h

            MOV AH, 9h
            MOV DX, OFFSET endline
            INT 21h

            CALL PRINTP1

            CALL PRINTP2

            CALL PRINTP4
ret
PRINTRES ENDP

; END OF CODE SEGMENT
CODE ENDS
; END OF PROGRAM. OBS: INCLUDES THE ENTRY OR THE FIRST PROCEDURE (i.e. “INICIO”)
END INICIO
