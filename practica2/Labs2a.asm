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

; END OF CODE SEGMENT
CODE ENDS
; END OF PROGRAM. OBS: INCLUDES THE ENTRY OR THE FIRST PROCEDURE (i.e. “INICIO”)
END INICIO