LED EQU P2.6
MOTOR EQU P2.3
RS BIT P2.0
RW BIT P2.1
E  BIT P2.2
DATABUS EQU P1
ORG 0013H
JMP FAN_ON


ORG 0
;LCD INITIALIZATION
		MOV A, #38H	; INITIATE LCD
		ACALL COMMANDWRT
		ACALL DELAY

		MOV A, #0EH	; DISPLAY ON CURSOR ON
		ACALL COMMANDWRT
		ACALL DELAY
		
		MOV A, #01H	; CLEAR LCD
		ACALL COMMANDWRT
		ACALL DELAY
		
CLR LED

MOV TMOD, #00100000B	;Mode 2 for timer 1 (8 bit auto reload)
MOV TH1, #0FDH		;setting baud rate 9600
MOV SCON, #01010000B	;Serial Mode 1, REN Enabled

SETB TR1	;Run timer 1
Receive:JNB RI, $	;Waiting for receive interrupt flag
	ACALL LCD
	MOV A, SBUF	;Move received character to A
	CLR RI		;Clear receive interrupt flag
	MOV R4, A
	MOV R5, A
	MOV R6, A
	MOV R7, A
	
	Switch:	CLR C		;Clear carry flag befor using SUBB for comparing
		SUBB A, #'1'	;Compare A to 1
		JZ LEDON	;If A = 1 turn on LED	
		
		MOV A, R4;	
		CLR C		;Clear carry flag befor using SUBB for comparing
		SUBB A, #'0'	;Compare A to 0
		JZ LEDOFF	;If A = 0 turn off LED
		;ACALL FAN_OFF	
		
		MOV A, R5;
		CLR C		;Clear carry flag befor using SUBB for comparing
		SUBB A, #'2'	;Compare A to 0
		JZ FAN_ON	;If A = 0 turn off LED
		
		MOV A, R6;
		CLR C		;Clear carry flag befor using SUBB for comparing
		SUBB A, #'3'	;Compare A to 0
		JZ FAN_OFF	;If A = 0 turn off LED
		
		MOV A, R7;
		SUBB A, #'4'
		JZ CLOSE
		
		SJMP Receive	;Jump back to Receive
		
LEDON:	SETB LED
	JMP Receive
	;RET
LEDOff:	CLR LED
	JMP Receive
	;RET
FAN_ON:
      ;SETB P2.3; motor runs clockwise
      ;ACALL DELAY
      SETB P2.3;
      CLR P2.4
      ACALL DELAY
      JMP Receive
      ;RET

FAN_OFF :   CLR P2.3;
     	    CLR P2.4
            ACALL DELAY
            JMP Receive
            ;RET
CLOSE: CLR LED
       CLR P2.3
       MOV A, #01H	; CLEAR LCD
       ACALL COMMANDWRT
       ACALL DELAY
       JMP $
	

;DELAY SUBROUTINE
DELAY:
    	MOV R0, #10 ;DELAY. HIGHER VALUE FOR FASTER CPUS
Y:	MOV R1, #255
	DJNZ R1, $
	DJNZ R0, Y

RET

;COMMAND SUB-ROUTINE FOR LCD CONTROL
LCD:
;LCD INITIALIZATION
		MOV A, #38H	; INITIATE LCD
		ACALL COMMANDWRT

		MOV A, #0FH	; DISPLAY ON CURSOR ON
		ACALL COMMANDWRT
		
		MOV A, #01H	; CLEAR LCD
		ACALL COMMANDWRT
		

;PRINTING A CHARACTER
		;CALL SENDCHAR
		
		
;PRINTING A STRING
		;MOV DPTR, #STRINGDATA
		;CALL SENDSTRING

;PRINTING 2 LINE STRING

		MOV DPTR, #STRINGDATA
		CALL SENDSTRING
		
		MOV A, #0C0H	; GO TO 2nd LINE
		ACALL COMMANDWRT
		
		;MOV DPTR, #STRINGDATA2
		;CALL SENDSTRING
	
		
		
		RET
				

;SENDING A CHARACHTER SUBROUTINE

;SENDING A STRING SUBROUTINE
SENDSTRING:
		CLR A
		MOVC A, @A+DPTR
		ACALL DATAWRT
		ACALL DELAY
		INC DPTR
		JZ EXIT
		SJMP SENDSTRING
EXIT:		RET
	


;COMMAND SUB-ROUTINE FOR LCD CONTROL
COMMANDWRT:

    	MOV P1, A ;SEND DATA TO P1
	CLR RS	;RS=0 FOR COMMAND
	CLR RW	;R/W=0 FOR WRITE
	SETB E	;E=1 FOR HIGH PULSE
	ACALL DELAY
	CLR E	;E=0 FOR H-L PULSE
	
	RET

;SUBROUTINE FOR DATA LACTCHING TO LCD
DATAWRT:

	MOV DATABUS, A
    	SETB RS	;RS=1 FOR DATA
    	CLR RW
    	SETB E
    	ACALL DELAY
	CLR E

	RET

	
ORG 300H
STRINGDATA:	DB	"Welcome Home",0 ;STRING AND NULL

END

