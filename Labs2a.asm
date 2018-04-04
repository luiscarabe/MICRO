;**************************************************************************
; 2st DELIVERABLE - Labs2a.asm
; Juan Riera, Luis Carabe
;**************************************************************************
; DATA SEGMENT DEFINITION
DATOS SEGMENT
COUNTER DW 0 ; Reserve memory for the counter, one word (two bytes), set to 0
dataVECTOR DB 4 dup(?) ;
prodVECTOR DB 8 dup(0) ; Result of multi
genMATRIX DB 1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1,1,1,0,1,1,0,1,1,0,1,1,1 ; Generation MATRIX (array) TRASPUESTA
input db "Input: ", '$'
output db "Output: ", '$'
computation db "Computation: ", 13, 10, "     | P1 | P2 | D1 | P4 | D2 | D3 | D4  ", 13, 10, "Word | ", '$'
separator db "  | ", '$'
p1 db "P1   | ", '$'
p2 db "P2   |    | ", '$'
p4 db "P4   |    |    |    | ", '$'
result db 2 dup(0)
endline db 13, 10, '$'
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

; PROGRAM START
; Guardo el numerito, ORDEN??
MOV DH, 1
MOV DL, 0
MOV BH, 1
MOV BL, 1
CALL MULTMATRIX
CALL PRINTRES
; PROGRAM END
MOV AX, 4C00H
INT 21H
INICIO ENDP

MULTMATRIX PROC 

; Guardamos los datos OJO: NO SE MU BIEN SI GUARDO EN EL ORDEN CORRECTO
MOV dataVECTOR[0], DH
MOV dataVECTOR[1], DL
MOV dataVECTOR[2], BH
MOV dataVECTOR[3], BL

MOV DI, 0 ; DI va a ser el que apunte a las filas


SETMULT:	MOV BX, 0 ; BX va a ser el que apunte a las columnas
			MOV DX, 0 ; Suma de cada mult de fila (estamos en traspuestas)

MULT:		MOV AL, dataVECTOR[BX] ; operando de la mult
			MOV CL, genMATRIX[BX][DI] ; operando de la mult
			MUL CL ;multiplicamos CL por AL, resultado en AX
			ADD DX, AX ; hacemos la suma parcial
			INC BX
			CMP BX, 4 ; Comprobamos que hayamos sumado todas las columnas
			JNZ MULT
			MOV BX, COUNTER ; Contador para escribir correctamente el resultado
			MOV prodVECTOR[BX], DL ; Guardamos digito
			INC COUNTER
			ADD DI, 4 ; Cambiamos de fila (4 elems por fila so sumamos 4)
			CMP COUNTER, 7 ; Miramos si hemos multiplicado todas las filas
			JNZ SETMULT
			
			MOV BX, 0; Index para hacer modulo
			MOV CL, 2 ; Divisor pa hacer MOD 2
resMOD:		MOV AL, prodVECTOR[BX] ; Guardamos dividendo
			MOV AH, 0
			MOV DX, 0
			DIV CL ; (AX entre 2), resto en AH
			MOV prodVECTOR[BX], AH
			INC BX
			CMP BX, 7
			JNZ resMOD
			
MOV DX, SEG prodVECTOR
MOV AX, OFFSET prodVECTOR
ret

MULTMATRIX ENDP

PRINTINRESULT PROC

            MOV CX, 0
            MOV AH, 2h
;;CAMBIAR SIGUIENTE LINEA
printloop1: MOV DL, prodVECTOR[0]
            ADD DL, 30h
            INT 21h
            MOV DL, ' '
            INT 21h
            INC CX
            CMP CX, 3
            JNZ printloop1
            
            MOV DL, prodVECTOR[3]
            ADD DL, 30h
            INT 21h 
            
            MOV DX, OFFSET endline
            MOV AH, 9h
            INT 21h
ret
PRINTINRESULT ENDP

PRINTOUTRESULT PROC
        
            MOV CX, 0
            MOV AH, 2h

            MOV DL, prodVECTOR[4]
            ADD DL, 30h
            INT 21h
            MOV DL, ' '
            INT 21h
            MOV DL, prodVECTOR[5]
            ADD DL, 30h
            INT 21h
            MOV DL, ' '
            INT 21h
            MOV DL, prodVECTOR[0]
            ADD DL, 30h
            INT 21h
            MOV DL, ' '
            INT 21h
            MOV DL, prodVECTOR[6]
            ADD DL, 30h
            INT 21h
            MOV DL, ' '
            INT 21h
            MOV DL, prodVECTOR[1]
            ADD DL, 30h
            INT 21h
            MOV DL, ' '
            INT 21h
            MOV DL, prodVECTOR[2]
            ADD DL, 30h
            INT 21
            MOV DL, ' '
            INT 21h
            MOV DL, prodVECTOR[3]
            ADD DL, 30h
            INT 21h
            
            
            MOV DX, OFFSET endline
            MOV AH, 9h
            INT 21h
ret
PRINTOUTRESULT ENDP

PRINTSEPARATOR PROC

            MOV AH, 9h
            MOV DX, OFFSET separator
            INT 21h
ret
PRINTSEPARATOR ENDP

PRINTP1 PROC
            MOV AH, 9h
            MOV DX, OFFSET p1
            INT 21h

            MOV AH, 2h
            MOV DL, prodVECTOR[4]
            ADD DL, 30h
            INT 21h

            CALL PRINTSEPARATOR

            MOV AH, 2h
            MOV DL, ' '
            INT 21h

            CALL PRINTSEPARATOR

            MOV AH, 2h
            MOV DL, prodVECTOR[0]
            ADD DL, 30h
            INT 21h

            CALL PRINTSEPARATOR

            MOV AH, 2h
            MOV DL, ' '
            INT 21h

            CALL PRINTSEPARATOR

            MOV AH, 2h
            MOV DL, prodVECTOR[1]
            ADD DL, 30h
            INT 21h 
            
            CALL PRINTSEPARATOR

            MOV AH, 2h
            MOV DL, ' '
            INT 21h

            CALL PRINTSEPARATOR

            MOV AH, 2h
            MOV DL, prodVECTOR[3]
			ADD DL, 30h
            INT 21h


            MOV DX, OFFSET endline
            MOV AH, 9h
            INT 21h
ret
PRINTP1 ENDP


PRINTP2 PROC

            MOV AH, 9h
            MOV DX, OFFSET p2
            INT 21h

            MOV AH, 2h
            MOV DL, prodVECTOR[5]
            ADD DL, 30h
            INT 21h

            CALL PRINTSEPARATOR

            MOV AH, 2h
            MOV DL, prodVECTOR[0]
            ADD DL, 30h
            INT 21h

            CALL PRINTSEPARATOR

            MOV AH, 2h
            MOV DL, ' '
            INT 21h

            CALL PRINTSEPARATOR

            MOV AH, 2h
            MOV DL, ' '
            INT 21h 
            
            CALL PRINTSEPARATOR

            MOV AH, 2h
            MOV DL, prodVECTOR[2]
            ADD DL, 30h
            INT 21h

            CALL PRINTSEPARATOR

            MOV AH, 2h
            MOV DL, prodVECTOR[3]
			ADD DL, 30h
            INT 21h


            MOV DX, OFFSET endline
            MOV AH, 9h
            INT 21h
ret
PRINTP2 ENDP

PRINTP4 PROC

            MOV AH, 9h
            MOV DX, OFFSET p4
            INT 21h
            
            MOV AH, 2h
            MOV DL, prodVECTOR[6]
            ADD DL, 30h
            INT 21h

            CALL PRINTSEPARATOR

            MOV AH, 2h
            MOV DL, prodVECTOR[1]
            ADD DL, 30h
            INT 21h 
            
            CALL PRINTSEPARATOR

            MOV AH, 2h
            MOV DL, prodVECTOR[2]
            ADD DL, 30h
            INT 21h

            CALL PRINTSEPARATOR

            MOV AH, 2h
            MOV DL, prodVECTOR[3]
			ADD DL, 30h
            INT 21h


            MOV DX, OFFSET endline
            MOV AH, 9h
            INT 21h
ret
PRINTP4 ENDP


PRINTRES PROC
			;MOV ES, DX
	        ;MOV result, [ES:AX] ;Guardo a buen recaudo 
                              ;el contenido de AX:DX
                            ;ya que voy a necesitarlos ahora
            MOV AH, 9h ;Preparo la funcion a la que quiero llamar
            MOV DX, OFFSET input
            INT 21h

            CALL PRINTINRESULT

            MOV AH, 9h ;Preparo la funcion a la que quiero llamar
            MOV DX, OFFSET output
            INT 21h

            CALL PRINTOUTRESULT

            MOV AH, 9h
            MOV DX, OFFSET computation
            INT 21h


            MOV AH, 2h
            MOV DL, '?'
            INT 21h

            CALL PRINTSEPARATOR

            MOV AH, 2h
            MOV DL, '?'
            INT 21h

            CALL PRINTSEPARATOR
			
            MOV AH, 2h
            MOV DL, prodVECTOR[0]
            ADD DL, 30h
            INT 21h

            CALL PRINTSEPARATOR

            MOV AH, 2h
            MOV DL, '?'
            INT 21h

            CALL PRINTSEPARATOR
            
            MOV AH, 2h
            MOV DL, prodVECTOR[1]
            ADD DL, 30h
            INT 21h

            CALL PRINTSEPARATOR

            MOV AH, 2h
            MOV DL, prodVECTOR[2]
            ADD DL, 30h
            INT 21h

            CALL PRINTSEPARATOR

            MOV AH, 2h
            MOV DL, prodVECTOR[3]
            ADD DL, 30h
            INT 21h

            MOV AH, 9h
            MOV DX, OFFSET endline
            INT 21h

            CALL PRINTP1

            CALL PRINTP2

            CALL PRINTP4
ret
PRINTRES ENDP

; END OF CODE SEGMENT
CODE ENDS
; END OF PROGRAM. OBS: INCLUDES THE ENTRY OR THE FIRST PROCEDURE (i.e. “INICIO”)
END INICIO
