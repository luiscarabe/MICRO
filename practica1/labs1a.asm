;**************************************************************************
; 1st DELIVERABLE - labs1a.asm
; Juan Riera, Luis Carabe
;**************************************************************************
; DATA SEGMENT DEFINITION
DATOS SEGMENT
;-- complete with the data requested
DATOS ENDS
;**************************************************************************
; STACK SEGMENT DEFINITION
PILA SEGMENT STACK "STACK"
DB 40H DUP (0) ; initialization example, 64 bytes set to 0
PILA ENDS
;**************************************************************************
; EXTRA SEGMENT DEFINITION
EXTRA SEGMENT
RESULT DW 0,0 ; initialization example. 2 WORDS (4 BYTES)
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
;
; PROGRAM START
MOV AX, 13h ;Loading 13h into AX
MOV BX, 0BAh ;Loading bah into BX (we need to put a 0 before the number, because if not, the compiler will interpret it as a label)
MOV CX, 3412h ;Loading 3412h into CX
MOV DX, CX ;Moving data from the register named by CX to another register, named DX
MOV AX, 6524h ;We need to use an auxiliar register because we can not store an immediate value in the data segment register
MOV ES, AX ;Now we move the memory address we want to access into the es register
MOV AL, [ES:6] ;Loading the content of the memory address 65246h (es with offset 6) into AL
MOV AH, [ES:7] ;Loading the content of the memory address 65247h (es with offset 7) into AH
MOV AX, 4000h ;We store the segment start because we can not store an immediate value directly into a segment register
MOV ES, AX ;Now we move the memory address we want to access into the es register
MOV [ES:4], CH ;We store the content of CH into the memory address in segment ES offset 4
MOV AX, [DI] ;The default segment for DI is the one stored in DS
MOV AX, [BP+8] ;The default segment for BP is the one stored in SS

; PROGRAM END
MOV AX, 4C00H
INT 21H
INICIO ENDP
; END OF CODE SEGMENT
CODE ENDS
; END OF PROGRAM. OBS: INCLUDES THE ENTRY OR THE FIRST PROCEDURE (i.e. “INICIO”)
END INICIO