code SEGMENT
ASSUME cs : code
ORG 256
start: jmp choice
; Global variables
groupInfo db "Juan Riera and Luis Carabe, team number: 2 ", '$'
installInfo db "Installed (Y/n): ", '$'

wrongParams db "Wrong params, you can only use /I or /U", '$'
overwrite db "A different driver is present, do you want to overwrite? (Y/n)", '$'
ans db 2 dup(?)

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
		cmp bx, 61h ; si el codigo es menor que la a minuscula
		jb no_change ; letra < a
		cmp 7Ah, bx ;
		ja no_change ; letra > z
		add bx, 5 ; sumamos 5
		cmp 7Ah, bx ; si nos hemos pasado de la z al sumar
		jbe no_mod
		dec bx, 26 ; restamos el num de letras
	no_mod:
		mov ds:dx[si], bx ; guardamos el encriptado
	no_change:
		add si, 2
		jmp encrypt
		
	decrypt:
		mov bx, ds:dx[si]
		cmp bx, '$'
		jz printer
		cmp bx, 61h
		jb no_change2 ; letra < a
		cmp 7Ah, bx
		ja no_change2 ; letra > z
		dec bx, 5 ; restamos 5
		cmp bx, 61h
		jae no_mod2 ;no nos hemos pasado de la a al restar
		add bx, 26 ; sumamos el num de letras
	no_mod2:
		mov ds:dx[si], bx
	no_change2:
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
		push dx ax es bx
		mov dx, OFFSET groupInfo
		mov ah, 9h
		int 21h
		mov dx, OFFSET installInfo
		mov ah, 9h
		int 21h
		;Miramos si esta instalado viendo si:
		;Interrupt vector different from zero.
		;First bytes of the service routine belong to the program that is to be uninstalled
		cmp ds:[55h*4], 0
		jnz not_installed
		cmp ds:[55h*4+2],0
		jnz not_installed
		mov ax, 0
		mov es, ax
		mov ax, OFFSET isr
		mov bx, cs
		cmp es:[55h*4], ax
		jnz not_installed
		cmp es:[ 55h*4+2 ], bx
		jnz not_installed
		mov ah, 2
		mov dl, 'Y'
		int 21h
		jmp end_
	not_installed:
		mov ah,2
		mov dl, 'n'
		int 21h
	end_:
		pop bx es ax dx
		ret
get_info ENDP

choice PROC 
	; VER SI ESTAMOS INSTALANDO, DESINSTALANDO, O SIMPLEMENTE PIDIENDO INFOR
		push ax bx dx es
		cmp 0, [80h]
		jz info
		cmp 03h, [80h] ; Comprobamos que hay 3 bytes de argumentos
		jnz badArgs
		cmp [81h], ' '
		jnz badArgs
		cmp [82h], '/'
		jnz badArgs
		cmp [83h], 'I'
		jz install
		cmp [83h], 'U'
		jz uninstall
		
	badArgs:
		mov dx, OFFSET wrongParams
		mov ah, 9h
		int 21h
		
	info: 
		call get_info
		jmp end_

	;Miramos si esta instalado viendo si:
	;Interrupt vector different from zero.
	;First bytes of the service routine belong to the program that is to be uninstalled
	install: 
		cmp ds:[55h*4], 0
		jnz not_zero
		cmp ds:[55h*4+2],0
		jnz not_zero
		call installer
		jmp end_
	not_zero:
		mov ax, 0
		mov es, ax
		mov ax, OFFSET isr
		mov bx, cs
		cmp es:[55h*4], ax
		jnz not_ours
		cmp es:[ 55h*4+2 ], bx
		jnz not_ours
		jmp end_
	not_ours:
		; Si no es nuestro preguntamos si queremos sobreescribir
		mov dx, OFFSET overwrite
		mov ah, 9h
		int 21h
		
		mov ah,0Ah ; Function 0Ah Reading from keyboard 
		mov dx, OFFSET ans  ;Memory  area  allocation  pointing  to  memory  tag ans 
		mov ans[0],1 ;Maximum number of characters to capture = 1
		int 21h
			
		cmp ans[1], 'Y'
		jnz end_
		call installer
		jmp end_
		
	uninstall:
		cmp ds:[55h*4], 0
		jnz end_
		cmp ds:[55h*4+2],0
		jnz end_
		mov ax, 0
		mov es, ax
		mov ax, OFFSET isr
		mov bx, cs
		cmp es:[55h*4], ax
		jnz end_
		cmp es:[ 55h*4+2 ], bx
		jnz end_
		call uninstaller

	end_:
		pop es dx bx ax
		ret
choice ENDP
	
code ENDS
END start