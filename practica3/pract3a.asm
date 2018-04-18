PRAC3A SEGMENT BYTE PUBLIC 'CODE'
PUBLIC _checkSecretNumber
ASSUME CS: PRAC3A
_checkSecretNumber PROC FAR
	PUSH BP
	MOV BP, SP
	PUSH ES
	PUSH SI
	PUSH BX
	PUSH DI
    LES BX, [BP+6]
    MOV DI, 1
    MOV SI, 0
loop:   MOV AL, [ES:BX][SI]
        innerloop: CMP AL, [ES:BX][DI]
                   JZ repeated
                   INC DI
                   CMP DI, 4
                   JNZ innerloop
        INC SI
        MOV DI, SI
        INC DI
        CMP SI, 3
        JNZ loop
		POP DI
		POP BX
		POP SI
		POP ES
		POP BP
		MOV AX, 0
		ret 

repeated: 	POP DI
			POP BX
			POP SI
			POP ES
			POP BP
			MOV AX, 1
			ret 

_checkSecretNumber ENDP


PUBLIC _fillUpAttempt
_fillUpAttempt PROC FAR
	PUSH BP
	MOV BP, SP
	PUSH ES
	PUSH BX
	PUSH CX
	PUSH SI
	PUSH DX
    MOV AX, [BP+6]
    LES BX, [BP+8]
    
    
    MOV CX, 10
    MOV SI, 4
loop1:  MOV DX, 0
        DIV CX
        MOV [ES:BX][SI-1], DL
        DEC SI
        JNZ loop1
	POP DX
	POP SI
	POP CX
	POP BX
	POP ES
	POP BP
    ret

_fillUpAttempt ENDP
PRAC3A ENDS
END
