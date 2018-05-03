code SEGMENT
ASSUME cs : code
ORG 256
start: jmp choice
; Global variables
groupInfo db "Juan Riera and Luis Carabe, team number: 2 ", 10, '$'
installInfo db "Installed (Y/n): ", '$'
notOursInfo db 13,10, "Something is installed, but not our driver.",'$'
wrongParams db "Wrong params, you can only use /I or /U", 13, 10,'$'
overwrite db 13,10,"A different driver is present, do you want to overwrite? (Y/n):", '$'
ans db 3 dup(?)

isr PROC FAR ; Interrupt service routine
		push ax bx si; Save modified registers
		mov si, dx
		cmp ah, 12h
		jz encrypt
		; Control de errores si Ah no es 12 o 13??
		cmp ah, 13h
		jz decrypt
		jmp inter_end
		; The strings shall be pointed by DS:DX and they shall end with $
	encrypt:
		mov bl, [si]
		cmp bl, '$'
		jz inter_end
		cmp bl, 61h ; si el codigo es menor que la a minuscula
		jb no_change ; letra < a
		cmp bl, 7Ah ;
		ja no_change ; letra > z
		add bl, 5 ; sumamos 5
		cmp bl, 7Ah ; si nos hemos pasado de la z al sumar
		jbe no_mod
		sub bl, 26 ; restamos el num de letras
	no_mod:
		mov [si], bl ; guardamos el encriptado
	no_change:
		inc si
		jmp encrypt
		
	decrypt:
		mov bl, [si]
		cmp bl, '$'
		jz inter_end
		cmp bl, 61h
		jb no_change2 ; letra < a
		cmp bl, 7Ah
		ja no_change2 ; letra > z
		sub bl, 5 ; restamos 5
		cmp bl, 61h
		jae no_mod2 ;no nos hemos pasado de la a al restar
		add bl, 26 ; sumamos el num de letras
	no_mod2:
		mov [si], bl
	no_change2:
		inc si
		jmp decrypt
		
	inter_end:
		pop si bx ax
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

checkDriver PROC
		push es ax bp si bx 
		mov cx, 0
		mov es, cx 
		cmp es:[55h*4], cx
		jnz something
		cmp es:[55h*4+2],cx
		jz nothing_there
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
		pop bx si bp ax es
		ret
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