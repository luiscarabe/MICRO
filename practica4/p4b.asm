;**************************************************************************
; 4th DELIVERABLE - p4b.asm
; Juan Riera, Luis Carabe
; Group 2351 Team 02
;**************************************************************************
; DATA SEGMENT DEFINITION
DATOS SEGMENT
info DB 13,10,"Do you want to encrypt (e), decrypt (d) or quit (q)?", 13,10,'$' ; String to ask the user what to do
enterString DB 13,10,"Please, enter the string (30 char max):",13,10,'$' ; String to ask the user to input an string
endline DB 13, 10, '$' ; Used to print an end of line 
ansInfo DB 3 dup(?) ; Reserved memory to store the user answer
inputString DB ?,?,31 dup(0) ; Reserved memory to store the user string
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
		MOV DX, OFFSET info ; Store at dx the info string offset
		MOV AH, 9H ; Function number = 9 (print string)
		INT 21H
		
		MOV AH,0Ah ; Function 0Ah Reading from keyboard 
		MOV DX, OFFSET ansInfo  ; Memory  area  allocation  pointing  to  memory  tag ansInfo
		MOV ansInfo[0],2 ; Maximum number of characters to capture = 1, stored at ansInfo[0] (2 because one is the enter)
		INT 21h
		
		CMP ansInfo[2],'e' ; If user types "e"...
		JZ encrypt ; We jump to encrypt
		CMP ansInfo[2],'d' ; If user types "d"...
		JZ decrypt ; We jump to decrypt
		CMP ansInfo[2],'q' 
		JNZ question ; If user does not type "q", he has inputed a wrong answer, so we ask again
		JMP quit ; If user types "q" we jump to quit
		
	encrypt:
		MOV DX, OFFSET enterString ; Store at dx the enterString string offset
		MOV AH, 9H ; Function number = 9 (print string)
		INT 21H
		
		MOV AH, 0Ah ; Function 0Ah Reading from keyboard 
		MOV DX, OFFSET inputString ; Memory  area  allocation  pointing  to  memory  tag inputString
		MOV inputString[0], 31  ; Maximum number of characters to capture = 30, stored at inputString[0] (30+1 because one is the enter)
		INT 21H
		
		MOV BL, inputString[1] ; Number of chars read
		MOV BH, 0 ; Store 0 at BH (in order to index appropriately)
		ADD BX, 2 ; Skip inputString[0]/[1] (max num of chars and chars read) by adding 2 to BX
		MOV inputString[BX], '$' ; Store '$' (end of string) at the input string end
		
		MOV DX, OFFSET endline ; Print a new line (store in dx endline offset)
		MOV AH, 9H ; Function number = 9 (print string)
		INT 21H
		
		MOV DX, OFFSET inputString ; Move to dx the inputString offset
		ADD DX, 2 ; Skip inputString[0]/[1] (max num of chars and chars read) by adding 2 to DX
		MOV AH, 12H ; Move 12h to ah in order to encrypt
		INT 55H ; Call to interrupt 55h

		JMP question ; We ask the user again
	decrypt:
		MOV DX, OFFSET enterString ; Store at dx the enterString string offset
		MOV AH, 9H ; Function number = 9 (print string)
		INT 21H
		
		MOV AH, 0Ah ; Function 0Ah Reading from keyboard 
		MOV DX, OFFSET inputString ; Memory  area  allocation  pointing  to  memory  tag inputString
		MOV inputString[0], 31 ; Maximum number of characters to capture = 30, stored at inputString[0] (30+1 because one is the enter)
		INT 21H
		
		MOV BL, inputString[1] ; Number of chars read
		MOV BH, 0 ; Store 0 at BH (in order to index appropriately)
		ADD BX, 2 ; Skip inputString[0]/[1] (max num of chars and chars read) by adding 2 to BX
		MOV inputString[BX], '$' ; Store '$' (end of string) at the input string end
		
		MOV DX, OFFSET endline ; Print a new line (store in dx endline offset)
		MOV AH, 9H ; Function number = 9 (print string)
		INT 21H
		
		MOV DX, OFFSET inputString ; Move to dx the inputString offset
		ADD DX, 2 ; Skip inputString[0]/[1] (max num of chars and chars read) by adding 2 to DX
		MOV AH, 13H ; Move 13h to ah in order to decrypt
		INT 55H ; Call to interrupt 55h

		JMP question ; We ask the user again
	quit:
		; PROGRAM END
		MOV AX, 4C00H
		INT 21H
INICIO ENDP
; END OF CODE SEGMENT
CODE ENDS
; END OF PROGRAM. OBS: INCLUDES THE ENTRY OR THE FIRST PROCEDURE (i.e. “INICIO”)
END INICIO
