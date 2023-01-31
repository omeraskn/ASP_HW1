myds SEGMENT PARA 'veri'
	SPACE	DW  10
myds ENDS

myss SEGMENT PARA STACK 'yigin'
	DW 256 DUP(?)
myss ENDS

mycs SEGMENT PARA 'kod'
	ASSUME CS:mycs, SS:myss, DS:myds
	
DNUM PROC FAR
		PUSH BP
		PUSH CX
		MOV BP, SP
		MOV CX, [BP+8] 				; 2 RW + CS + IP = 8bytes
		
		CMP CX, 0
		JA ENDNUM
		
		MOV WORD PTR [BP+8], 0
		POP CX
		POP BP
		RETF
ENDNUM:		
		CMP CX, 2
		JA DNUMN
		MOV WORD PTR [BP+8], 1
		POP CX
		POP BP
		RETF
DNUMN:	
		PUSH AX						 ; D(n) = D(D(n-1))+D(n-1-D(n-2))
		PUSH BX
		PUSH DX
		MOV BX, CX 				 	 ;  n->BX
		SUB BX , 2  		 		 ;  n-2
		PUSH BX
		CALL DNUM 					 
		POP AX						 ;  D(n-2)
		SUB CX, AX 					 ;  n-D(n-2)
		DEC CX						 ;  n-1-D(n-2)
		PUSH CX
		CALL DNUM
		POP DX  					 ;  DX = D(n-D(n-2))
		INC BX			 			 ;  n-1->BX
		PUSH BX
		CALL DNUM  			   		 ;  (D(n-1))
		POP AX
		PUSH AX
		CALL DNUM 					 ;  D(D(n-1))
		POP AX						 ;  AX -> D(D(n-1))
		ADD AX, DX					 ;  D(D(n-1))+D(n-1-D(n-2))
		MOV [BP+8], AX 				 ;  AX'teki sonuc degerı kaydolur
		POP DX
		POP BX
		POP AX
		POP CX
		POP BP
		RETF
DNUM ENDP

PRINTINT PROC NEAR 			
		PUSH BX
		PUSH BP
		PUSH DX
		MOV BP, SP
		MOV AX, [BP+8] 		
		MOV BX, 1
		PUSH BX
		XOR DX, DX 		
		MOV BX, 0AH			
MR:		
		DIV BX
		ADD DX, '0'
		PUSH DX
		XOR DX, DX
		CMP AX, 0
		JNZ MR
PRINT:	
		POP AX
		CMP AX, 1
		JZ ENDA
		MOV DL, AL
		MOV AH, 2
		INT 21H				; interrupt
		JMP PRINT
ENDA:		
		POP DX
		POP BP
		POP BX
		RET 2
PRINTINT	ENDP


MAIN PROC FAR				;  MAIN FONKS	
	PUSH DS
	XOR AX, AX
	PUSH AX
	MOV AX, myds
	MOV DS, AX
	PUSH BP
	MOV BP, SP
	
	MOV AX, SPACE
	PUSH AX
	CALL FAR PTR DNUM
	
	CALL PRINTINT
	
	MOV SP, BP
	POP BP
	RETF
		
MAIN ENDP

mycs ENDS
	 END MAIN
