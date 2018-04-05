;**************************************************************************
; 2nd DELIVERABLE - dec2AS.asm
; Juan Riera, Luis Carabe
; Group 2351 Team 02
;**************************************************************************
; DATA SEGMENT DEFINITION
DATOS SEGMENT
COUNTERup DW 0 ; Reserve memory for the counter, one word (two bytes), set to 0
ASCIINUM DB 6 DUP (?) ; Reserve memory for the result of the conversion to ASCII, 6 bytes (one for each hexa digit plus one for the '$' plus one for better performance)
DATOS ENDS			  ; One for each hexa digit because to convert one hexadecimal digit, we need to add 30h, so the result will be of 1 byte
					  ; The byte of performance is because we need to reserve an even number of bytes due to internal reasons
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
;
; PROGRAM START
MOV BX, 65335 ; We move to BX the number (in decimal) that we want to print
CALL CONVERTER ; We call the proc to convert the number to ASCII
; Now we need to make an interrupt, in order to get the printed number, we must set some registers first:
MOV DX, OFFSET ASCIINUM ; DX : offset to first position of the string text to print 
MOV AH, 9 ; Function number = 9 (print string) 
INT 21h

; PROGRAM END
MOV AX, 4C00H
INT 21H
INICIO ENDP

CONVERTER PROC 
; In this procedure, we will divide the number by 10 till the quotient is 0
; We may store each remainder converted to ASCII in the stack
; So, after this, we only need to pop and store the result as many times as needed
MOV AX, BX ; We move the number to AX, this register will be used by div as the dividend
MOV CX, 10 ; We assign the value 10 to CX, this register will be used as the divisor

dig2ASCII:	INC COUNTERup ; Increment by one the counter
			MOV DX, 0 ; We must store a 0 in DX in order to use div properly	
			DIV CX ; We divide AX by CX (10), the quotient is in AX and the remainder in DX
			ADD DX, 30h ;We add 30h to the remainder, in order to convert the digit to ASCII
			PUSH DX ; Then we store the ASCII value at the stack
			CMP AX, 0 ; Compare the quotient with 0
			JNZ dig2ASCII ; if it isn't 0, we have not finished, so we must convert the rest of the number
			MOV BX, 0 ; We store a 0 in bx in order to have an auxiliar counter to reorder and store the result
			
reorderNum:	POP DX ; We extract one value from the stack and store it in DX
			MOV ASCIINUM[BX], DL ; We move the value to ASCIINUM (the result size is 8 bits so it is stored at DL)
			INC BX ; Increment by one the auxiliar counter (BX)
			CMP BX, COUNTERup ; Compare the aux counter with COUNTERup
			JNZ reorderNum ; If is not the same, it means that we still need to pop some digits
			MOV ASCIINUM[BX], '$' ; We store '$' to indicate that is the end of the string
			MOV DX, SEG ASCIINUM ; Store of the result segment at DX
			MOV AX, OFFSET ASCIINUM ; Store of the result offset at AX
			ret ; Return to the procedure that called the CONVERTER 
CONVERTER ENDP

; END OF CODE SEGMENT
CODE ENDS
; END OF PROGRAM. OBS: INCLUDES THE ENTRY OR THE FIRST PROCEDURE (i.e. “INICIO”)
END INICIO
