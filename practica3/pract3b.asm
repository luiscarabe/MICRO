;**************************************************************************
; 3rd DELIVERABLE - pract3b.asm
; Juan Riera, Luis Carabe
; Group 2351 Team 02
;**************************************************************************

; Start of Code Segment

PRAC3B SEGMENT BYTE PUBLIC 'CODE'

PUBLIC _computeMatches ; With PUBLIC we make this function accessible from the main C program

ASSUME CS: PRAC3B

_computeMatches PROC FAR ; computeMatches in C
	PUSH BP ; We store the value of BP in the stack
	MOV BP, SP ; Now we use BP in order to address the stack
	PUSH ES DS BX SI CX ; We store all the registers that we are going to use in the stack
    LES AX, [BP+6] ; We store the first arg (char*), this is, the direction of secretNum: ES <- SEGMENT, AX <- OFFSET (4 bytes in total)
	LDS BX, [BP+10] ; We store the second arg (char*), this is, the direction of attemptDigits: DS <- SEGMENT, BX <- OFFSET (4 bytes in total)
	
	MOV SI, 0 ; We are going to use SI as the index of the two char*, so we initialize it with 0
	MOV CX, 0 ; We are going to use CX as the matches counter, so we initialize it with 0
	
compute:	
			MOV DL, [DS:BX][SI] ; Value of the appropiate digit of the attempt at register DL
			XCHG BX, AX ; Exchange of registers BX and AX, in order to access es:ax properly (es:ax is an illegal indexing mode)
			CMP DL, [ES:BX][SI] ; Comparison between the digits of the attempt and the secret num
			JNZ nohit ; If they are not the same, we do not increment the matches counter
			INC CX ; If they are the same, we increment the matches counter
	nohit: 	XCHG BX, AX ; We exchange again BX and AX, to keep data consistency
			INC SI ; Increment of the index
			CMP SI,4 ; We compare the index with 4 (number of digits to compare)
			JNZ compute ; If we have not finished, we compute other digits
	MOV AX, CX ; Value returned through AX since function is int
	POP CX SI BX DS ES BP ; We restore previous register values
	RET ; Return to the procedure that called _computeMatches 
_computeMatches ENDP

PUBLIC _computeSemiMatches ; With PUBLIC we make this function accessible from the main C program

_computeSemiMatches PROC FAR ; computeSemiMatches in C
	PUSH BP ; We store the value of BP in the stack
	MOV BP, SP ; Now we use BP in order to address the stack
	PUSH DS BX DX SI CX DI ; We store all the registers that we are going to use in the stack
    LES BX, [BP+6] ; We store the first arg (char*), this is, the direction of secretNum: ES <- SEGMENT, BX <- OFFSET (4 bytes in total)
    LDS DX, [BP+10] ; We store the second arg (char*), this is, the direction of attemptDigits: DS <- SEGMENT, DX <- OFFSET (4 bytes in total)
    MOV SI, 0
	MOV CX, 0 ; We are going to use CX as the semimatches counter, so we initialize it with 0
	
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
				
	MOV AX, CX ; Value returned through AX since function is int
	POP DI CX SI DX BX DS BP ; We restore previous register values
	RET ; Return to the procedure that called _computeSemiMatches 

bingo:	INC CX
		JMP back
_computeSemiMatches ENDP

; END OF CODE SEGMENT
PRAC3B ENDS
END