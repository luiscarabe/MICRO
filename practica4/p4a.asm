;**************************************************************************
; 4th DELIVERABLE - p4a.asm
; Juan Riera, Luis Carabe
; Group 2351 Team 02
;**************************************************************************
code SEGMENT
ASSUME cs : code
ORG 256 ; Directive ORG 256 must be used prior to the first assembly instruction.
start: jmp choice ; Jump to the procedure that checks input args
; Global variables
groupInfo db "Juan Riera and Luis Carabe, team number: 2 ", 10, '$' ; String with our info
installInfo db "Installed (Y/n): ", '$' ; String for the installation info
notOursInfo db 13,10, "Something is installed, but not our driver.",'$' ;String to inform that the driver installed is not ours
wrongParams db "Wrong params, you can only use /I or /U", 13, 10,'$' ; String to inform that the user did not write correct args
overwrite db 13,10,"A different driver is present, do you want to overwrite? (Y/n):", '$' ; String to ask for an overwrite
ans db 3 dup(?) ; Memory reserved for the user's answer about the overwrite 

isr PROC FAR ; Interrupt service routine

	;Encryption or decryption of one string (only lowercase letters)
	
		push ax bx si ; Save modified registers
		mov si, dx ; The string is pointed by DS:DX, so we store DX (the OFFSET) at register si
		cmp ah, 12h ; If in ah is stored 12h, we must encrypt the string
		jz encrypt
		cmp ah, 13h ; If in ah is stored 13h, we must decrypt the string
		jz decrypt
		
		jmp inter_end ; If ah is neither 12h or 13h, we finish the interrupt
		
	encrypt:
		mov bl, [si] ; Move one letter (1 byte) to bl 
		cmp bl, '$' ; Is the letter equal to '$' (end of string)?
		jz printer ; If true, we print the result
		cmp bl, 61h ; We compare the letter with 61h ("a")
		jb no_change ; If letter < a we must not change its value (we only encrypt lowercase letters)
		cmp bl, 7Ah ; We compare the letter with 7Ah ("z")
		ja no_change ; If letter > z we must not change its value (we only encrypt lowercase letters)
		add bl, 5 ; Add 5 to the letter in order to encrypt (3+2)
		cmp bl, 7Ah ; If encrypted letter is <= "z" ...
		jbe no_mod ; We don't need to change the result
		sub bl, 26 ; If not, our letter has a value bigger than 7Ah ("z"), so we need to sub 26 (number of letters) 
		; For example, y -> d
	no_mod:
		mov [si], bl ; We store the changed letter at the original position
	no_change:
		inc si ; We increment si (offset) to get the next char (1 byte)
		jmp encrypt ; Jump to encrypt the rest of the string
		
	decrypt:
		mov bl, [si] ; Move one letter (1 byte) to bl 
		cmp bl, '$' ; Is the letter equal to '$' (end of string)?
		jz printer ; If true, we print the result
		cmp bl, 61h ; We compare the letter with 61h ("a")
		jb no_change2 ; If letter < a we must not change its value (we only decrypt lowercase letters)
		cmp bl, 7Ah ; We compare the letter with 7Ah ("z")
		ja no_change2  ; If letter > z we must not change its value (we only decrypt lowercase letters)
		sub bl, 5 ; Sub 5 to the letter in order to decrypt (3+2)
		cmp bl, 61h ; If encrypted letter is >= "a" ...
		jae no_mod2 ; We don't need to change the result
		add bl, 26 ; If not, our letter has a value smaller than 61h ("a"), so we need to add 26 (number of letters)
		; For example, d -> y
	no_mod2:
		mov [si], bl ; We store the changed letter at the original position
	no_change2:
		inc si ; We increment si (offset) to get the next char (1 byte)
		jmp decrypt ; Jump to decrypt the rest of the string
		
	printer:	
		mov ah, 9h  ; Function number = 9 (print string)
		;DX is already pointing to the string offset
		int 21h	
	inter_end:
		pop si bx ax ; We restore previous register values
		iret ; Interrupt return 
isr ENDP

installer PROC ; Procedure to install the interrupt 55h
		mov ax, 0
		mov es, ax ; Store 0 at es
		mov ax, OFFSET isr ; Store interrupt offset at ax
		mov bx, cs ; Store interrupt segment at cs
		cli ; Disable interrupts
		mov es:[ 55h*4 ], ax ; Store interrupt offset at its appropriate memory location 
		mov es:[ 55h*4+2 ], bx ; Store interrupt segment at its appropriate memory location 
		sti ; Enable interrupts
		mov dx, OFFSET installer ; Store installer offset at dx
		int 27h ; Terminate and stay resident
installer ENDP

uninstaller PROC ; Procedure to uninstall the interrupt 55h
		push ax bx cx ds es ; Save modified registers
		mov cx, 0 ; Store 0 at cx
		mov ds, cx ; Segment of interrupt vectors
		mov es, ds:[ 55h*4+2 ] ; Read ISR segment
		mov bx, es:[ 2Ch ] ; Read segment of environment from ISR’s PSP.
		mov ah, 49h
		int 21h ; Release ISR segment (es)
		mov es, bx
		int 21h ; Release segment of environment variables of ISR
		; Set vector of interrupt 55h to zero (cx = 0)
		cli ; Disable interrupts
		mov ds:[ 55h*4 ], cx ; Interrupt offset = 0
		mov ds:[ 55h*4+2 ], cx ;Interrupt segment = 0
		sti ; Enable interrupts
		pop es ds cx bx ax ; We restore previous register values
		ret ; Procedure return
uninstaller ENDP

checkDriver PROC ; Procedure that checks if there is no driver installed (at 55h), 
				 ; if there is someones driver installed or if it's our driver
		push es ax bp si bx ; Save modified registers
		mov cx, 0 ; Store 0 at cx
		mov es, cx ; Store 0 at es
		cmp es:[55h*4], cx ; If the offset is not 0...
		jnz something ; Then, something is installed, we need to see if it's ours
		cmp es:[55h*4+2],cx ; If the segment is 0...
		jz nothing_there ; Then, there is no interrupt installed
	something:
		mov ax, 0
		mov es, ax
		mov bp, es:[55h*4]
		mov es, es:[55h*4+2]
		mov si, OFFSET isr
		mov bx, [si]
		cmp es:[bp], bx
		jnz not_our_driver
		mov bx, [si+2]
		cmp es:[bp+2], bx
		jnz not_our_driver
		mov cx, 1
		jmp return
	not_our_driver:
		mov cx, 2
		jmp return
	nothing_there:
		mov cx, 0
	return:
		pop bx si bp ax es ; We restore previous register values
		ret ; Procedure return
checkDriver ENDP

get_info PROC
		push cx dx ax 
		mov cx, 0
		mov dx, OFFSET groupInfo
		mov ah, 9h
		int 21h
		mov dx, OFFSET installInfo
		mov ah, 9h
		int 21h
		;Miramos si esta instalado viendo si:
		;Interrupt vector different from zero.
		;First bytes of the service routine belong to the program that is to be uninstalled
		call checkDriver
		cmp cx, 0 ;Not installed
		jz not_installed
		cmp cx, 1 ; Ours
		jz ours
		jmp not_ours
	ours:	
		mov ah, 2
		mov dl, 'Y'
		int 21h
		jmp end_
	not_ours:
		mov ah, 9h
		mov dx, OFFSET notOursInfo
		int 21h
		jmp end_
	not_installed:
		mov ah,2
		mov dl, 'n'
		int 21h
	end_:
		pop ax dx cx
		ret
get_info ENDP

choice PROC 
;ES UN PROGRAMA NORMAL? (NO HACER PUSH/POP + TERMINAR CON INT)????
	; VER SI ESTAMOS INSTALANDO, DESINSTALANDO, O SIMPLEMENTE PIDIENDO INFOR
		mov cx, 0
		cmp BYTE PTR ds:[80h], 0
		jz info
		cmp BYTE PTR ds:[80h], 03h ; Comprobamos que hay 3 bytes de argumentos
		jnz badArgs
		cmp BYTE PTR ds:[81h], ' '
		jnz badArgs
		cmp BYTE PTR ds:[82h], '/'
		jnz badArgs
		cmp BYTE PTR ds:[83h], 'I'
		jz install
		cmp BYTE PTR ds:[83h], 'U'
		jz uninstall
		
	badArgs:
		mov dx, OFFSET wrongParams
		mov ah, 9h
		int 21h
		jmp end1
		
	info: 
		call get_info
		jmp end1

	;Miramos si esta instalado viendo si:
	;Interrupt vector different from zero.
	;First bytes of the service routine belong to the program that is to be uninstalled
	install: 
		call checkDriver
		cmp cx, 0 ;Not installed
		jz call_install
		cmp cx, 1 ; Ours
		jz end1
		
	not_ours1:
		; Si no es nuestro preguntamos si queremos sobreescribir
		mov dx, OFFSET overwrite
		mov ah, 9h
		int 21h
		
		mov ah,0Ah ; Function 0Ah Reading from keyboard 
		mov dx, OFFSET ans  ;Memory  area  allocation  pointing  to  memory  tag ans 
		mov ans[0],2 ;Maximum number of characters to capture = 1
		int 21h
			
		cmp ans[2], 'Y'
		jz call_install
		cmp ans[2], 'n'
		jz end1
		jmp not_ours1
		
	call_install:
		call installer
		jmp end1
		
	uninstall:
		mov es, cx
		cmp es:[55h*4], cx
		jnz call_uninstall
		cmp es:[55h*4+2],cx
		jz end1
		;Si hay uno instalado y no es nuestro nos la pela un poco
	call_uninstall:
		call uninstaller

	end1:
		mov ax, 4C00h
		int 21h
choice ENDP
	
code ENDS
END start
