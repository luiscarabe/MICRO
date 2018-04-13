PUBLIC _computeMatches

_computeMatches PROC FAR
	PUSH BP
	PUSH ES
	PUSH DS
	MOV BP, SP
    LES AX, [BP+6] ; es - seg de secretNum ax - off de secretNum
	LDS BX, [BP+10]
	
	MOV SI, 0 ; SI contador
	MOV CX, 0 ; CX CONTADOR DE MATCHES
	
compute:	MOV DL, ES[AX+SI]
			CMP DL, DS[AX+SI]
			JNZ no-hit
			INC CX
	no-hit: INC SI
			CMP SI,4
			JNZ compute

				
	POP DS
	POP ES
	POP BP
	MOV AX, CX ; value returned through AX since function is int
	RET
	
_computeMatches ENDP

;- unsigned int computeMatches(unsigned char* secretNum, unsigned char* attemptDigits);
