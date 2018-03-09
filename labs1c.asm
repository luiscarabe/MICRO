;**************************************************************************
; 1st DELIVERABLE - labs1c.asm
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
MOV AX, 0511h
MOV DS, AX
MOV AX, PILA
MOV SS, AX
MOV AX, EXTRA
MOV ES, AX
MOV SP, 64 ; LOAD THE STACK POINTER WITH THE HIGHEST VALUE
;
; PROGRAM START
MOV BX, 0211h ;; Initialize the registers needed
MOV DI, 1010h

MOV AL, DS:[1234h] ;; It will access the direction 06344h
MOV AX, [BX] ;; It will access the direction 07220h = DS*10h + BX and load the content to AX

;;We found out that the address 07220h is part of the memory that is reserved for drivers, in our test,we found 832Bh

MOV [DI], AL ;; It will access DS:2Bh (the value of AL in this moment) to store the content	
			 ;; of that address memory to DS:DI -> 6120h

; PROGRAM END
MOV AX, 4C00H
INT 21H
INICIO ENDP
; END OF CODE SEGMENT
CODE ENDS
; END OF PROGRAM. OBS: INCLUDES THE ENTRY OR THE FIRST PROCEDURE (i.e. “INICIO”)
END INICIO