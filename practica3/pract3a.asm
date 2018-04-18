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
    LES BX, [BP+6] ;Load the segment and the offset of the first argument
    MOV DI, 1   ; We initialize de indexes that we will use in the loop
    MOV SI, 0
loop:   MOV AL, [ES:BX][SI]     ;Load in AL a number of the array
        innerloop: CMP AL, [ES:BX][DI]  ; Compare it to the rest of the elements of the array
                   JZ repeated          ; If it is repeated we jump to 'repeated'
                   INC DI               ; If not we increase DI
                   CMP DI, 4            ; If we haven't reached the end of the array
                   JNZ innerloop        ;  We jump back to the start of he inner loop
        INC SI      ; If not we increase SI
        MOV DI, SI  ; And move SI to DI so that we don't start in the inner loop from the start
        INC DI      ; But from the position after SI, in that way we don't re-check
        CMP SI, 3   ; We check now if we have checked all the numbers (exept for the last one,
                    ; which is not necessary with this algorythm)
        JNZ loop    ; If we haven't reached the end we jump back to the start
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
    MOV AX, [BP+6] ; We load in AX the first argument
    LES BX, [BP+8] ; Load in ES the segment and in BX the offset of the second
    
    
    MOV CX, 10 ; We will be dividing by 10
    MOV SI, 4  ; Initialize SI to 4, we will go from last to first (4 3 2 1)
loop1:  MOV DX, 0 ; Initialize DX to 0 so that it doesn't bother in the division
        DIV CX  ; Divide by 10
        MOV [ES:BX][SI-1], DL ; Store the result
        DEC SI  ; Point at the previous number
        JNZ loop1 ; If the pointer is not 0 we jumpt back to the start of the loop
	POP DX SI CX BX ES BP ; We restore previous register values
    RET ; Return to the procedure that called _fillUpAttempt 

_fillUpAttempt ENDP

; END OF CODE SEGMENT
PRAC3A ENDS
END
