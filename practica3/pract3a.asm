PUBLIC _checkSecretNumber
_checkSecretNumber PROC FAR
    MOV AX, [BP+6]
    MOV DX, [BP+8]
    MOV ES, DX
    MOV CX, 1
    MOV SI, 0
loop:   MOV BX, [ES:AX][SI]
        innerloop: CMP BX, [ES:AX][CX]
                   JZ repeated
                   INC CX
                   CMP CX, 4
                   JNZ innerloop
        INC SI
        MOV CX, SI
        INC CX
        CMP SI, 3
        JNZ loop

ret 0

repeated: ret 1

_checkSecretNumber ENDP


PUBLIC _fillUpAttempt
_fillUpAttempt PROC
    MOV AX, [BP+6]
    MOV DX, [BP+8]
    MOV ES, DX
    MOV BX, [BP+10]
    ES:BX
    
    MOV CL, 10
    MOV SI, 3
loop:   MOV DX, 0
        MOV AH, 0
        DIV CL
        MOV [ES:BX][SI], AL
        MOV AL, AH
        DEC SI
        JNZ loop
    ret

_fillUpAttempt ENDP
