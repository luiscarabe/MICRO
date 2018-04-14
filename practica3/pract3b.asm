PRAC3B SEGMENT BYTE PUBLIC 'CODE'
PUBLIC _computeMatches
ASSUME CS: PRAC3B
_computeMatches PROC FAR
	PUSH BP
	MOV BP, SP
	PUSH ES
	PUSH DS
	PUSH BX
	PUSH SI
	PUSH CX
    LES AX, [BP+6] ; es - seg de secretNum ax - off de secretNum
	LDS BX, [BP+10]
	
	MOV SI, 0 ; SI contador
	MOV CX, 0 ; CX CONTADOR DE MATCHES
	
compute:	
			MOV DL, [DS:BX][SI]
			XCHG BX, AX
			CMP DL, [ES:BX][SI]
			JNZ nohit
			INC CX
	nohit: 	XCHG BX, AX
			INC SI
			CMP SI,4
			JNZ compute
	MOV AX, CX ; value returned through AX since function is int
	POP CX
	POP SI
	POP BX
	POP DS
	POP ES
	POP BP
	RET
	
_computeMatches ENDP

PUBLIC _computeSemiMatches

_computeSemiMatches PROC FAR
	PUSH BP
	MOV BP, SP
	PUSH DS
	PUSH BX
	PUSH DX
	PUSH SI
	PUSH CX
	PUSH DI
    LES BX, [BP+6]
    LDS DX, [BP+10]
    MOV SI, 0
	MOV CX, 0
	
loop:	MOV DI, 0
	MOV AL, [ES:BX][SI]
	innerloop:	XCHG DX, BX
				CMP SI, DI
				JZ back	
				
				CMP AL, [DS:BX][DI]
				
				JZ bingo
		back:	XCHG DX, BX
				INC DI
				CMP DI, 4
				JNZ innerloop
	INC SI
	CMP SI, 4
	JNZ loop
				
	MOV AX, CX
	POP DI
	POP CX
	POP SI
	POP DX
	POP BX
	POP DS
	POP BP
	
ret 

bingo:	INC CX
		JMP back
_computeSemiMatches ENDP
PRAC3B ENDS
END