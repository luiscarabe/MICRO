;**************************************************************************
; 2bd DELIVERABLE - Labs2b.asm
; Juan Riera, Luis Carabe
;**************************************************************************
; DATA SEGMENT DEFINITION
DATOS SEGMENT
computation db "Computation: ", 13, 10, "     | P1 | P2 | D1 | P4 | D2 | D3 | D4  ", 13, 10, "Word | ", '$'

askuser db "Porfavor introduzca un caracter:", 13, 10, '$'
character dw 2, 3 dup(0)
endline db 13, 10, '$'
result dw 4 dup(0)
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
CALL GETASCIIFROMUSER
MOV AX, character[2]
SUB AX, 30h
MUL 10
MOV DX, character[3]
SUB DX, 30h
ADD AX, DX

;; Comprobar errores

MOV SI, 0
             	MOV CL, 2
divisionloop:	DIV CL
				MOV DL, AH
				MOV DH, 0h
				ADD DX, 30h
				MOV result[SI], DX
				MOV DX, 0
				INC SI
				CMP AX, 0
				JNZ divisionloop
				
MOV result[SI], '$'
MOV AH, 09h
MOV DL, OFFSET endline
INT 21h
MOV DL, OFFSET result	
INT 21h
MOV AX, 4C00h
INT 21h

INICIO ENDP
		
GETASCIIFROMUSER PROC
	MOV DX, OFFSET askuser
	MOV AH, 09h
	INT 21h
	
	MOV AH, 0AH
	MOV DX, OFFSET character
	INT 21h
ret
GETASCIIFROMUSER ENDP

CODE ENDS

END INICIO
