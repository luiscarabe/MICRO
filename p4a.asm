code SEGMENT
ASSUME cs : code
ORG 256
start: jmp choice
; Global variables
groupInfo db "Juan Riera and Luis Carabe, team number: 2 ", '$'
installInfo db "Installed (Y/n): ", '$'

isr PROC FAR ; Interrupt service routine
	push ax si bx; Save modified registers
	mov si, 0
	cmp 12h, ah
	jz encrypt
	; Control de errores si Ah no es 12 o 13??
	jmp decrypt
	; The strings shall be pointed by DS:DX and they shall end with $
encrypt: 
	mov bx, ds:dx[si]
	cmp bx, '$'
	jz printer
	add bx, 5
	mov ds:dx[si], bx
	add si, 2
	jmp encrypt
	
decrypt:
	mov bx, ds:dx[si]
	cmp bx, '$'
	jz printer
	dec bx, 5
	mov ds:dx[si], bx
	add si, 2
	jmp decrypt
	
printer:	mov ah, 9h
			int 21h
	
	pop bx si ax
	iret
isr ENDP

installer PROC
	mov ax, 0
	mov es, ax
	mov ax, OFFSET isr
	mov bx, cs
	cli
	mov es:[ 55h*4 ], ax
	mov es:[ 55h*4+2 ], bx
	sti
	mov dx, OFFSET installer
	int 27h ; Terminate and stay resident
	; PSP, variables, isr routine.
installer ENDP

uninstaller PROC ; Uninstall ISR of INT 55h

	push ax bx cx ds es
	mov cx, 0
	mov ds, cx ; Segment of interrupt vectors
	mov es, ds:[ 55h*4+2 ] ; Read ISR segment
	mov bx, es:[ 2Ch ] ; Read segment of environment from ISR’s PSP.
	mov ah, 49h
	int 21h ; Release ISR segment (es)
	mov es, bx
	int 21h ; Release segment of environment variables of ISR
	; Set vector of interrupt 40h to zero
	cli
	mov ds:[ 55h*4 ], cx ; cx = 0
	mov ds:[ 55h*4+2 ], cx
	sti
	pop es ds cx bx ax
	ret
uninstaller ENDP

get_info PROC
	push dx ax
	mov dx, OFFSET groupInfo
	mov ah, 9h
	int 21h
	mov dx, OFFSET installInfo
	mov ah, 9h
	int 21h
	cmp ds:[55h*4], 0
	jnz not_installed
	cmp ds:[55h*4+2],0
	jnz not_installed
	mov ah, 2
	mov dl, 'Y'
	int 21h
not_installed:
	mov ah,2
	mov dl, 'n'
	int 21h
fin:
	pop ax dx
	ret
get_info ENDP

choice PROC 
; VER SI ESTAMOS INSTALANDO, DESINSTALANDO, O SIMPLEMENTE PIDIENDO INFOR


	
not_installed:	

choice ENDP

	
	
	
code ENDS
END start