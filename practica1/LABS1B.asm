;**************************************************************************
; 1st DELIVERABLE - labs1b.asm
; Juan Riera, Luis Carabe
;**************************************************************************
; DATA SEGMENT DEFINITION
DATOS SEGMENT
COUNTER db ? ; Reserve memory for one byte (db), the character ? means that we don't initialize the byte
GRAB dw 0CAFEH ; Reserve memory for two bytes (dw), initialized with CAFEh (we need to put a 0 before the number, 
				; because if not, the compiler will interpret it as a label)
TABLE100 db 100 dup(?) ; Reserve memory for a table of 100 uninitialized bytes 
ERROR1 db "Incorrect data. Try again" ; Reserve memory for a string, each char has a length of one byte, so we need to use db
DATOS ENDS
;**************************************************************************
; STACK SEGMENT DEFINITION
PILA SEGMENT STACK "STACK"
DB 40H DUP (0) ; initialization example, 64 bytes set to 0
PILA ENDS
;**************************************************************************
; EXTRA SEGMENT DEFINITION
EXTRA SEGMENT
RESULT DW 0,0 ; initialization example. 2 WORDS (4 BYTES)
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
MOV AH, ERROR1[5] ; We copy he 6th byte of error into the auxiliar register AH, because we can not move data from memory to memory directly
MOV TABLE100+52h, AH ; Now we take the data and store it in the 54th position of the variable table100
						; In neither of the previous we needed to specify the segment in which we were working
						; Because by default, it is the data segment.
MOV AX, GRAB		; We move the contents of the variable GRAB into an auxiliar register for the same reason
MOV WORD PTR TABLE100+21h, AX ; Since the data in AX and GRAB were 2 bytes long, we need to specify that we
								; are moving them into a one byte allocated array on purpose with the PTR instruction
MOV COUNTER, AH				; Taking advantage of the fact that the variable GRAB is still on the auxiliar register
							; we used before, we move the highest byte of the register into COUNTER


; PROGRAM END
MOV AX, 4C00H
INT 21H
INICIO ENDP
; END OF CODE SEGMENT
CODE ENDS
; END OF PROGRAM. OBS: INCLUDES THE ENTRY OR THE FIRST PROCEDURE (i.e. “INICIO”)
END INICIO