;**************************************************************************
; 4th DELIVERABLE - p4c.asm
; Juan Riera, Luis Carabe
; Group 2351 Team 02
;**************************************************************************
; DATA SEGMENT DEFINITION
DATOS SEGMENT
info DB 13,10,"Do you want to encrypt (cod), decrypt (dec) or quit (quit)?", 13,10,'$' ; We will print this
													; string at the start of the program
endline DB 13, 10, '$' ; This string is printed when we need an end of line
inputString DB ?,?,31 dup(0) ; Here we will store whatever the user types, and
						; also the encrypted/decrypted string before we print it
codString DB "cod"	; We will use this variable to check if the input string is 'enc'
decString DB "dec" ; We will use this variable to check if the input string is 'dec'
quitString DB "quit" ; We will use this variable to check if the input string is 'quit'
encryptingModeAct DB "Encrypting mode", 13, 10, '$' ; We will print this string to inform the user
												; that they has changed the mode to encrypting
decryptingModeAct DB "Decrypting mode", 13, 10, '$'; We will print this string to inform the user
												; that they has changed the mode to decrypting
flagNotPrint DB 0 ; This flag is used to print half of the times so that we print in 1 hz
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
	mov al, 0Ch ; We want the c register
	out 70h, al ; Tell the rtc what we want
	in al, 71h ; Get it's answer
	; Check if the c register is the correct one
	test al, 01000000b ; Check it is a periodic interrupt
	jz finish ; If not end the interrupt
	cmp flagNotPrint, 1 ; We check if we don't have to print (we want to print half of the times)
	jz notPrint ; If we don't have to print we put the flagNotPrint variable to 0 and end
	mov flagNotPrint, 1 ; We have to print, so the next time we won't print
	mov ah, 2h ; Prepare the print function
	mov dl, inputString[di] ; Get the ascii char
	int 21h ; Print it

	inc di ; Increment the indexer
	cmp byte ptr inputString[di], '$' ; Have we reached the end of the string?
	jnz finish	; If we haven't end the interrupt
	; If we have, make it stop the interrupts
	mov al, 0Bh ; Load register b
    out 70h, al ; Enable 0Bh register
    in al, 71h ; Read the 0Bh register
    mov ah, al
    and ah, 10111111b ; Set the PIE bit to 0
    mov al, 0Bh ; Write the b register back
    out 70h, al ; Enable the 0Bh register
    mov al, ah	
    out 71h, al ; Write the 0Bh register
	jmp finish ; We don't want to clear the flagNotPrintVariable, we want it to be 1
notPrint:
	mov flagNotPrint, 0
finish:
	mov al, 20h ; Load EOI
	out 20h, al ; Send it to the master PIC
	out 0A0h, al ; Send it to the slave PIC
 	pop bx
	pop ax
	iret ; End the interrupt
rtc_isr endp

confRTC PROC FAR
	push bx
	push cx
	push ax
	cli
	mov ax, 0 ; Load a 0 in ax
	mov es, ax ; and put it in es to install the interrupt
	mov cx, OFFSET rtc_isr ; Get the offset od the isr
	
	mov es:[70h*4], cx ; Store the offset in 0:[70h*4]
	mov bx, cs ; Store the segment
	mov es:[70h*4+2], bx ; in 0:[70h*4+2]
  
    ; SET the frequency
    mov al, 0Ah 
	out 70h, al ;Enable 0Ah register
    mov al, 00101111b ; (DV=010b, RS=1111b) = 2 hz 
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
	MOV AH, 9H ; Print the info string
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
checkEnc: MOV al, inputString[SI+2] ; We get each character, we are not interested 									; in the first two (because they are metavalues  									; of the string, we want the string itself) ; We get each character, we are not interested
									; in the first two (because they are metavalues 
									; of the string, we want the string itself)
        CMP al, codString[SI] ; Check if the characters are equal
		JNZ checkDecInit ; If they are not we leave and check if 
                        ; the string is 'dec'
        INC SI ; Increment the indexer          ; else, keep checking 
        CMP SI, 3 ; Check if we have reached the end of 'enc'
        JL checkEnc ; If we haven't we jump back to the start of the loop

        mov mode, 0 ; If we reach this point the string is
                    ; 'enc' and therefore we change the mode
        MOV DX, OFFSET encryptingModeAct
	    MOV AH, 9H ; We print a string to inform the user of this
	    INT 21H
        JMP question

checkDecInit: MOV SI, 0
checkDec: MOV al, inputString[SI+2] ; We get each character, we are not interested 
									; in the first two (because they are metavalues  
									; of the string, we want the string itself)
        CMP al, decString[SI] ; Check if the characters are equals in both strings
		JNZ checkQuitInit ; If they are not jump to check if the string is 'quit'
        INC SI ; Increment the indexer
        CMP SI, 3 ; Check if we have reached the end of 'dec'
        JL checkDec ; If we haven't, jump to the start of the loop
		
		; If we reach this point the string is 'dec' 
        MOV DX, OFFSET decryptingModeAct ; So we inform the user 
	    MOV AH, 9H ; printing the decryptModeAct string
	    INT 21H
        mov mode, 1; If we reach this point the string is
                    ; 'dec' and therefore we change the mode
        JMP question ; Jump back to the start and ask for another string

checkQuitInit: MOV SI, 0
checkQuit: MOV al, inputString[SI+2] ; We get each character, we are not interested 
									; in the first two (because they are metavalues
									; of the string, we want the string itself)
        CMP al, quitString[SI] ; Check if the characters are equalsin both strings
		JNZ normalString ; If they are not, we encrypt/decrypt the string, because
						; it is not 'enc', 'dec' or 'quit'
        INC SI ; Increment the indexer
        CMP SI, 4 ; Check if we have reached the end of 'quit'
        JL checkQuit ; If we haven't we jump back to the start of the loop
				; If we reach this point the string is
        JMP quit   ; 'quit' and therefore we end the program
        

normalString: ; We jump here if the string is not 'dec' or 'enc' or 'quit'
    MOV BL, inputString[1] ;Number of chars read
	MOV BH, 0 ; Expand bl to the whole bx
	ADD BL, 2 ; skip inputString[0]/[1]
	MOV inputString[BX], '$' ; Add a line end to the end of the string

    MOV DX, OFFSET endline ; Print an
	MOV AH, 9H				; end of line
	INT 21H

    cmp mode, 1 ; Check if we are decrypting
    JZ decrypt ; If we are, jump to decrypt, if not continue

	encrypt:

		MOV DX, OFFSET inputString ; Load in DX the offset of inputString + 2
		ADD DX, 2	; because it will be taken as argument by the int 55 function
		MOV AH, 12H ; Call encrypt
		INT 55H

		JMP printer ; When the string has been encrypted it is stored in inputString,
					; so we just print it

	decrypt:
	
		MOV DX, OFFSET inputString; Load in DX the offset of inputString + 2
		ADD DX, 2	; because it will be taken as argument by the int 55 function
		MOV AH, 13H ; Call decrypt
		INT 55H

		JMP printer ; When the string has been decrypted it is stored in inputString,
					; so we just print it

    printer:
        mov di, 2 ; Start printing from the third byte (skip the metadata)
		call activateRTC ; Activate the clock periodic signals
	
    waiter: cmp inputString[di], '$' ; Wait in an infinite loop
        JNZ waiter					; until que reach the end in '$'

        JMP question				; Jump back to get another string
    quit:
		; PROGRAM END
		MOV AX, 4C00H
		INT 21H
INICIO ENDP


; END OF CODE SEGMENT
CODE ENDS
; END OF PROGRAM. OBS: INCLUDES THE ENTRY OR THE FIRST PROCEDURE (i.e. “INICIO”)
END INICIO
