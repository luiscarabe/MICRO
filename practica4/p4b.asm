;**************************************************************************
; 4th DELIVERABLE - p4b.asm
; Juan Riera, Luis Carabe
; Group 2351 Team 02
;**************************************************************************
; DATA SEGMENT DEFINITION
DATOS SEGMENT
info DB 13,10,"Do you want to encrypt (e), decrypt (d) or quit (q)?", 13,10,'$'
enterString DB 13,10,"Please, enter the string (30 char max):",13,10,'$'
endline DB 13, 10, '$'
ansInfo DB 3 dup(?)
inputString DB ?,?,31 dup(0)
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

	question:
		MOV DX, OFFSET info
		MOV AH, 9H
		INT 21H
		
		MOV AH,0Ah ; Function 0Ah Reading from keyboard 
		MOV DX, OFFSET ansInfo  ;Memory  area  allocation  pointing  to  memory  tag ansInfo
		MOV ansInfo[0],2 ;Maximum number of characters to capture = 1
		INT 21h
		
		CMP ansInfo[2],'e'
		JZ encrypt
		CMP ansInfo[2],'d'
		JZ decrypt
		CMP ansInfo[2],'q'
		JNZ question
		JMP quit
		
	encrypt:
		MOV DX, OFFSET enterString
		MOV AH, 9H
		INT 21H
		
		MOV AH, 0Ah
		MOV inputString[0], 31 
		MOV DX, OFFSET inputString
		INT 21H
		
		MOV BL, inputString[1] ;Number of chars read
		MOV BH, 0
		ADD BL, 2 ; skip inputString[0]/[1]
		MOV inputString[BX], '$'
		
		MOV DX, OFFSET endline
		MOV AH, 9H
		INT 21H
		
		MOV DX, OFFSET inputString
		ADD DX, 2
		MOV AH, 12H
		INT 55H

		JMP question
	decrypt:
		MOV DX, OFFSET enterString
		MOV AH, 9H
		INT 21H
		
		MOV AH, 0Ah
		MOV inputString[0], 31 
		MOV DX, OFFSET inputString
		INT 21H
		
		MOV BL, inputString[1] ;Number of chars read
		MOV BH, 0
		ADD BL, 2 ; skip inputString[0]/[1]
		MOV inputString[BX], '$'
		
		MOV DX, OFFSET endline
		MOV AH, 9H
		INT 21H
		
		MOV DX, OFFSET inputString
		ADD DX, 2
		MOV AH, 13H
		INT 55H

		JMP question
	quit:
		; PROGRAM END
		MOV AX, 4C00H
		INT 21H
INICIO ENDP
; END OF CODE SEGMENT
CODE ENDS
; END OF PROGRAM. OBS: INCLUDES THE ENTRY OR THE FIRST PROCEDURE (i.e. “INICIO”)
END INICIO
