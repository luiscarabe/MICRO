PRAC3A SEGMENT BYTE PUBLIC 'CODE'
PUBLIC _checkSecretNumber
ASSUME CS: PRAC3A
_checkSecretNumber PROC FAR
	PUSH BP
	MOV BP, SP
    LES BX, [BP+6]
    MOV DI, 1
    MOV SI, 0
loop:   MOV AX, [ES:BX][SI]
        innerloop: CMP AX, [ES:BX][DI]
                   JZ repeated
                   INC DI
                   CMP DI, 4
                   JNZ innerloop
        INC SI
        MOV DI, SI
        INC DI
        CMP SI, 3
        JNZ loop
		POP BP
		MOV AX, 0
		ret 

repeated: POP BP
		  MOV AX, 1
		  ret 

_checkSecretNumber ENDP


PUBLIC _fillUpAttempt
_fillUpAttempt PROC FAR
	PUSH BP
	MOV BP, SP
    MOV AX, [BP+6]
    LES BX, [BP+10]
    
    
    MOV CL, 10
    MOV SI, 3
loop1:   MOV DX, 0
        MOV AH, 0
        DIV CL
        MOV [ES:BX][SI], AL
        MOV AL, AH
        DEC SI
        JNZ loop1
	
	POP BP
    ret

_fillUpAttempt ENDP
PRAC3A ENDS
END