;**************************************************************************
; 3rd DELIVERABLE - pract3a.asm
; Juan Riera, Luis Carabe
; Group 2351 Team 02
;**************************************************************************

; Start of Code Segment

PRAC3A SEGMENT BYTE PUBLIC 'CODE'

PUBLIC _checkSecretNumber ; With PUBLIC we make this function accessible from the main C program

ASSUME CS: PRAC3A
_checkSecretNumber PROC FAR ; checkSecretNumber in C
	PUSH BP ; We store the value of BP in the stack
	MOV BP, SP ; Now we use BP in order to address the stack
	PUSH ES SI BX DI ; We store all the registers that we are going to use in the stack
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
		POP DI BX SI ES BP ; We restore previous register values
		MOV AX, 0 ; Value returned through AX since function is int
		RET	; Return to the procedure that called _checkSecretNumber 	

repeated: 	POP DI BX SI ES BP ; We restore previous register values
			MOV AX, 1 ; Value returned through AX since function is int
			RET ; Return to the procedure that called _checkSecretNumber 

_checkSecretNumber ENDP


PUBLIC _fillUpAttempt ; With PUBLIC we make this function accessible from the main C program

_fillUpAttempt PROC FAR ; fillUpAttempt in C
	PUSH BP ; We store the value of BP in the stack
	MOV BP, SP ; Now we use BP in order to address the stack
	PUSH ES BX CX SI DX ; We store all the registers that we are going to use in the stack
    MOV AX, [BP+6]
    LES BX, [BP+8]
    
    
    MOV CX, 10
    MOV SI, 4
loop1:  MOV DX, 0
        DIV CX
        MOV [ES:BX][SI-1], DL
        DEC SI
        JNZ loop1
	POP DX SI CX BX ES BP ; We restore previous register values
    RET ; Return to the procedure that called _fillUpAttempt 

_fillUpAttempt ENDP

; END OF CODE SEGMENT
PRAC3A ENDS
END
