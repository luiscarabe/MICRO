;**************************************************************************
; 2bd DELIVERABLE - Labs2b.asm
; Juan Riera, Luis Carabe
;**************************************************************************
; DATA SEGMENT DEFINITION
DATOS SEGMENT
askuser db "Porfavor introduzca un caracter:", 13, 10, '$'
character db 2, 2, 3 dup(31h)
endline db 13, 10, '$'
result db 4 dup(30h), '$'
errormessage db "Error: datos introducidos incorrectos", 13, 10, '$'
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
start: CALL GETASCIIFROMUSER
MOV AL, character[1]
CMP AL, 0
JZ ERRORMSG
CMP AL, 1
JZ ONECHAR
CALL TWOCHAR

;; Comprobar errores

division: CMP AL, 15
JG ERRORMSG
MOV CL, 0
CMP CL, AL
JG ERRORMSG
MOV SI, 3
             	MOV CL, 2
				
divisionloop:	MOV AH, 0
				MOV DX, 0
				DIV CL
				MOV DL, AH
				MOV AH, 0
				MOV DH, 0h
				ADD DX, 30h
				MOV result[SI], DL
				SUB SI, 1
				CMP AL, 0
				JNZ divisionloop
				
MOV AH, 09h
MOV DL, OFFSET endline
INT 21h
MOV DL, OFFSET result	
INT 21h
MOV AX, 4C00h
INT 21h

INICIO ENDP

ONECHAR PROC
ONECHAR: MOV AL, character[2]
	SUB AL, 30h
	JMP division
ONECHAR ENDP

TWOCHAR PROC
	MOV AL, character[2]
	SUB AL, 30h
	MOV AH, 0
	MOV CL, 10
	MUL CL
	MOV DL, character[3]
	SUB DL, 30h
	ADD AL, DL
	JMP division
TWOCHAR ENDP

ERRORMSG PROC
ERRORMSG:	MOV DX, OFFSET errormessage
	MOV AH, 09h
	INT 21h
	JMP start
ERRORMSG ENDP
	
GETASCIIFROMUSER PROC
	MOV DX, OFFSET askuser
	MOV AH, 09h
	INT 21h
	
	MOV AH, 0AH
	MOV DX, OFFSET character
	MOV character[0], 3
	INT 21h
ret
GETASCIIFROMUSER ENDP

CODE ENDS

END INICIO
