PRAC3B SEGMENT BYTE PUBLIC 'CODE'
PUBLIC _computeMatches
ASSUME CS: PRAC3B
_computeMatches PROC FAR
	PUSH BP
	PUSH ES
	PUSH DS
	MOV BP, SP
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

				
	POP DS
	POP ES
	POP BP
	MOV AX, CX ; value returned through AX since function is int
	RET
	
_computeMatches ENDP

PUBLIC _computeSemiMatches

_computeSemiMatches PROC FAR
	PUSH BP
	PUSH DS
	MOV BP, SP
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
				
	
	
	POP DS
	POP BP
	
MOV AX, CX
ret 

bingo:	INC CX
		JMP back
_computeSemiMatches ENDP
PRAC3B ENDS
END