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
overwriteUninstall db 13,10,"A different driver is present, do you want to uninstall? (Y/n):", '$' ; String to ask for an overwrite at uninstall
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
				 
		;Interrupt vector different from zero ?
		push es ax bp si bx ; Save modified registers
		mov cx, 0 ; Store 0 at cx
		mov es, cx ; Store 0 at es
		cmp es:[55h*4], cx ; If the offset is not 0...
		jnz something ; Then, something is installed, we need to see if it's ours
		cmp es:[55h*4+2],cx ; If the segment is 0...
		jz nothing_there ; Then, there is no interrupt installed
	something:
		;First bytes of the service routine belong to the program that is to be uninstalled or installed?
		mov es, cx ; Store 0 at es
		mov bp, es:[55h*4] ; Store the installed interrupt offset at bp
		mov es, es:[55h*4+2] ; Store the installed interrupt segment at es
		mov si, OFFSET isr ; Store our interrupt offset at si
		mov bx, [si] ; Store first 2 bytes of our interrupt at bx
		cmp es:[bp], bx ; Compare bx with installed interruption first bytes
		jnz not_our_driver ; If is not the same, it's not our driver
		mov bx, [si+2] ; Store another 2 bytes of our interrupt at bx
		cmp es:[bp+2], bx ; Compare bx with installed interruption second pair of bytes
		jnz not_our_driver ; If is not the same, it's not our driver
		mov cx, 1 ; We store 1 at cx (our driver is installed)
		jmp return ; Jump to return
	not_our_driver:
		mov cx, 2 ; We store 2 at cx (other driver is installed)
		jmp return ; Jump to return
	nothing_there:
		mov cx, 0 ; We store 0 at cx (there is no driver installed)
	return:
		pop bx si bp ax es ; We restore previous register values
		ret ; Procedure return
checkDriver ENDP

get_info PROC ; Procedure to print the interrupt information
		push cx dx ax ; Save modified registers
		mov cx, 0 ; Store 0 at cx
		mov dx, OFFSET groupInfo ; Store at dx the groupInfo string offset
		mov ah, 9h ; Function number = 9 (print string)
		int 21h
		mov dx, OFFSET installInfo  ; Store at dx the installInfo string offset
		mov ah, 9h ; Function number = 9 (print string)
		int 21h
		
		call checkDriver ; Call to function that checks if our driver is installed
		cmp cx, 0 ; If it is not installed (cx =0)...
		jz not_installed ; Jump to not_installed
		cmp cx, 1 ; If it is installed (cx =1)...
		jz ours ; Jump to ours
		jmp not_ours ; If not, there is something installed, but not our driver
	ours:	
		mov ah, 2 ; Function number = 2 (print char)
		mov dl, 'Y' ; Our driver is installed, so we print an Y
		int 21h
		jmp end_ ; Jump to end
	not_ours:
		mov ah, 9h ; Function number = 9 (print string)
		mov dx, OFFSET notOursInfo ; Store at dx the notOursInfo string offset
		int 21h
		jmp end_ ; Jump to end
	not_installed:
		mov ah,2 ; Function number = 2 (print char)
		mov dl, 'n' ; Our driver is installed, so we print a n
		int 21h
	end_:
		pop ax dx cx ; We restore previous register values
		ret ; Procedure return
get_info ENDP

choice PROC ; Procedure to check the input args and run the proper procedure
		mov cx, 0 ; Store 0 at cx
		cmp BYTE PTR ds:[80h], 0 ; At the PSP direction ds:[80h] is stored the number of input argument
		jz info ; If there are no arguments, we jump to info
		cmp BYTE PTR ds:[80h], 03h ; If not, there should be 3 arguments
		jnz badArgs ; If not, we jump to badArgs
		cmp BYTE PTR ds:[81h], ' ' ; First argument should be an ' ', stored at the PSP direction ds:[81h] 
		jnz badArgs ; If not, we jump to badArgs
		cmp BYTE PTR ds:[82h], '/' ; Second argument should be an '/', stored at the PSP direction ds:[82h] 
		jnz badArgs ; If not, we jump to badArgs
		cmp BYTE PTR ds:[83h], 'I' ; If the third argument is an 'I', stored at the PSP direction ds:[83h]... 
		jz install ; We jump to install
		cmp BYTE PTR ds:[83h], 'U' ; If the third argument is an 'U', stored at the PSP direction ds:[83h]...  
		jz uninstall ; We jump to uninstall
		
		; If not, we inform the user that he had inputed wrong args
	badArgs:
		mov dx, OFFSET wrongParams ; Store at dx the wrongParams string offset
		mov ah, 9h ; Function number = 9 (print string)
		int 21h
		jmp end1 ; Jump to end
		
	info: 
		call get_info ; Call to procedure that prints driver information
		jmp end1 ; Jump to end
		
	install: 
		call checkDriver ; Call to function that checks if our driver is installed
		cmp cx, 0 ; If it is not installed (cx =0)...
		jz call_install ; We jump to call_install
		cmp cx, 1  ; If it is already installed (cx =1)...
		jz end1 ; Jump to end
		
	not_ours1:
		; If not, there is something installed, but not our driver
		; We must ask if the user wants to overwrite
		mov dx, OFFSET overwrite ; Store at dx the overwrite string offset
		mov ah, 9h ; Function number = 9 (print string)
		int 21h
		
		mov ah,0Ah ; Function 0Ah Reading from keyboard 
		mov dx, OFFSET ans  ; Memory  area  allocation  pointing  to  memory  tag ans 
		mov ans[0],2 ; Maximum number of characters to capture = 1, stored at ans[0] (2 because one is the enter)
		int 21h
			
		cmp ans[2], 'Y' ; If user types Y...
		jz call_install ; We jump to call_install
		cmp ans[2], 'n' ; If user types n...
		jz end1 ; We jump to the end
		jmp not_ours1 ; If not, the user has inputed a wrong answer, so we ask again
		
	call_install:
		call installer ; Call the procedure that installs the driver
		jmp end1 ; Jump to end
		
	uninstall:
		call checkDriver ; Call to function that checks if our driver is installed
		cmp cx, 0 ; If it is not installed (cx =0)...
		jz end1 ; Jump to end
		cmp cx, 1  ; If it is already installed (cx =1)...
		jz call_uninstall ; We jump to call_uninstall
		
	not_ours2:
		; If not, there is something installed, but not our driver
		; We must ask if the user wants to uninstall it
		mov dx, OFFSET overwriteUninstall ; Store at dx the overwriteUninstall string offset
		mov ah, 9h ; Function number = 9 (print string)
		int 21h
		
		mov ah,0Ah ; Function 0Ah Reading from keyboard 
		mov dx, OFFSET ans  ; Memory  area  allocation  pointing  to  memory  tag ans 
		mov ans[0],2 ; Maximum number of characters to capture = 1, stored at ans[0] (2 because one is the enter)
		int 21h
			
		cmp ans[2], 'Y' ; If user types Y...
		jz call_uninstall ; We jump to call_uninstall
		cmp ans[2], 'n' ; If user types n...
		jz end1 ; We jump to the end
		jmp not_ours2 ; If not, the user has inputed a wrong answer, so we ask again
		
	call_uninstall:
		call uninstaller ; Call the procedure that uninstalls the driver

	end1:
		mov ax, 4C00h ; Program ends
		int 21h
choice ENDP
	
code ENDS
END start
