;**************************************************************************
; 4th DELIVERABLE - p4c.asm
; Juan Riera, Luis Carabe
; Group 2351 Team 02
;**************************************************************************
; DATA SEGMENT DEFINITION
DATOS SEGMENT
info DB 13,10,"Do you want to encrypt (cod), decrypt (dec) or quit (quit)?", 13,10,'$'
enterString DB 13,10,"Please, enter a string (30 char max):",13,10,'$'
endline DB 13, 10, '$'
inputString DB ?,?,31 dup(0)
codString DB "cod"
decString DB "dec"
quitString DB "quit"
encryptingModeAct DB "Encrypting mode", 13, 10, '$'
decryptingModeAct DB "Decrypting mode", 13, 10, '$'
debugString db "hey q paxa", 13,  10, '$'
mode DB (0) ; Variable that stores if we are encrypting (0) or decrypting (1)
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

rtc_isr PROC
	sti	
	push ax
	push bx
	mov al, 0Ch
	out 70h, al
	in al, 71h
	; Check if the c register is the correct one
	test al, 11110000b
	jz finish
	; [Dx+DI] should contain the ascii to print
	mov ah, 2h 
	mov dl, inputString[di]
	int 21h

	inc di
	cmp byte ptr inputString[di], '$'
	jnz finish
	; Make it stop interrupts
	mov al, 0Bh
    out 70h, al ; Enable 0Bh register
    in al, 71h ; Read the 0Bh register
    mov ah, al
    and ah, 10111111b ; Set the PIE bit
    mov al, 0Bh
    out 70h, al ; Enable the 0Bh register
    mov al, ah
    out 71h, al ; Write the 0Bh register

finish:
	mov al, 20h
	out 20h, al
	out 0A0h, al
 	pop bx
	pop ax
	iret
rtc_isr endp

confRTC PROC FAR
	push bx
	push cx
	push ax
	cli
	mov ax, 0
	mov es, ax
	mov cx, OFFSET rtc_isr
	
	mov es:[70h*4], cx
	mov bx, cs
	mov es:[70h*4+2], bx
    mov al, 0Ah
    ; SET the frequency
    
	out 70h, al ;Enable 0Ah register
    mov al, 00101111b ; DV=001b, RS=0111b 
    out 71h, al ; Write 0Ah register
	mov al, 0Bh
    out 70h, al ; Enable 0Bh register
    in al, 71h ; Read the 0Bh register
    mov ah, al
    and ah, 10111111b ; Set the PIE bit
    mov al, 0Bh
    out 70h, al ; Enable the 0Bh register
    mov al, ah
    out 71h, al ; Write the 0Bh register
	sti
    pop ax
	pop cx
	pop bx
    ret
confRTC endp

activateRTC PROC FAR
    push ax
        ; Active Interrupt
    mov al, 0Bh
    out 70h, al ; Enable 0Bh register
    in al, 71h ; Read the 0Bh register
    mov ah, al
    or ah, 01000000b ; Set the PIE bit
    mov al, 0Bh
    out 70h, al ; Enable the 0Bh register
    mov al, ah
    out 71h, al ; Write the 0Bh register
    pop ax
    ret
activateRTC endp




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

    CALL confRTC

	MOV DX, OFFSET info
	MOV AH, 9H
	INT 21H

question:	
		MOV DX, OFFSET endLine
	    MOV AH, 9H ; We print a string to inform the user of this
	    INT 21H
		
		MOV AH,0Ah ; Function 0Ah Reading from keyboard 
		MOV DX, OFFSET inputString  ;Memory  area  allocation  pointing  to  memory  tag inputString
		MOV inputString[0],31 ;Maximum number of characters to capture = 30
		INT 21h
		
        MOV SI, 0 ; Si will be used as a pointer in the
                ;string
        ; We will now check if the string is 'enc'
checkEnc: MOV al, inputString[SI+2] 
        CMP al, codString[SI] ; Check if the characters are equal
		JNZ checkDecInit ; If they are not we leave and check if 
                        ; the string is 'dec'
        INC SI          ; else, keep checking 
        CMP SI, 3
        JL checkEnc

        mov mode, 0 ; If we reach this point the string is
                    ; 'enc' and therefore we change the mode
        MOV DX, OFFSET encryptingModeAct
	    MOV AH, 9H ; We print a string to inform the user of this
	    INT 21H
        JMP question

checkDecInit: MOV SI, 0
checkDec: MOV al, inputString[SI+2]
        CMP al, decString[SI]
		JNZ checkQuitInit
        INC SI
        CMP SI, 3
        JL checkDec
        MOV DX, OFFSET decryptingModeAct
	    MOV AH, 9H
	    INT 21H
        mov mode, 1
        JMP question

checkQuitInit: MOV SI, 0
checkQuit: MOV al, inputString[SI+2]
        CMP al, quitString[SI]
		JNZ normalString
        INC SI
        CMP SI, 4
        JL checkQuit

        JMP quit

normalString:
    MOV BL, inputString[1] ;Number of chars read
	MOV BH, 0
	ADD BL, 2 ; skip inputString[0]/[1]
	MOV inputString[BX], '$'

    MOV DX, OFFSET endline
	MOV AH, 9H
	INT 21H

    cmp mode, 1
    JZ decrypt

	encrypt:

		MOV DX, OFFSET inputString
		ADD DX, 2
		MOV AH, 12H
		INT 55H

		JMP printer
	decrypt:
	
		MOV DX, OFFSET inputString
		ADD DX, 2
		MOV AH, 13H
		INT 55H

		JMP printer

    printer:
        mov di, 2
		call activateRTC
	
    waiter: cmp inputString[di], '$'
        JNZ waiter

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
