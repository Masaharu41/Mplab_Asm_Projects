;883Keypad.asm
	;SEPTEMBER 8, 2024
	;OWEN FUJII
	;Basic Setup File for the PIC16F883

		#INCLUDE <p16f883.inc>        		; processor specific variable definitions
		LIST      p=16f883		  	; list directive to define processor
		errorlevel -302,-207,-305,-206,-203	;suppress "not in bank 0" message,  Found label after column 1,
							;Using default destination of 1 (file),  Found call to macro in column 1

		#include "p16f883.inc"

; CONFIG1
; __config 0xF8E7
 __CONFIG _CONFIG1, _FOSC_XT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF
; CONFIG2
; __config 0xFFFF
 __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
;******************************************		
;Define Constants
;******************************************

#Define 	BAUD		D'100'				;Desired Baud Rate in Kbps for I2C
#Define		FOSC		D'16000'			;Oscillator Clock in KHz This must be filled

;******************************************		
;Define Variable Registers
;******************************************

 	COUNT1	EQU	0x20
	COUNT2	EQU	0x21
	COUNT3	EQU	0x22
	COUNT4	EQU	0x23
	COUNT5	EQU	0x24
	STEP	EQU	0x25
	LEG_1	EQU	0x26
		
;******************************************		
;Interupt Vectors
;******************************************
		ORG H'000'					
		GOTO SETUP					;RESET CONDITION GOTO SETUP

;******************************************
;SETUP ROUTINE
;******************************************
SETUP
;*** SFR SETUP **********
 
		
;*** SET OPTION_REG: ****
		BANKSEL OPTION_REG
		BCF		OPTION_REG, PS0		;\\
		BCF		OPTION_REG, PS1		; >>PRESCALER RATIO SET 1:1
		BCF		OPTION_REG, PS2		;//
		BCF		OPTION_REG, PSA		;PRESCALER ASSIGNED TO WDT 
		BSF		OPTION_REG, T0SE	;TMR0 EDGE SET RISING
		BCF		OPTION_REG, T0CS	;TMR0 CLOCK SOURCE SET TO INTERNAL
		BSF		OPTION_REG, INTEDG	;RB0/INT SET TO RISING EDGE
		BSF		OPTION_REG, 7		;PORTB PULLUP DISABLED
;*** SET INTCON REG: ****
		BANKSEL INTCON
		BCF		INTCON, RBIE		;DISABLE PORT B CHANGE INTERUPT 
		BCF		INTCON, INTE		;DISABLE RB0/INT EXTERNAL INTERUPT
		BCF		INTCON, TMR0IE		;DISABLE TMR0 INTERUPT (ENABLED IN MAIN PROGRAM)
		BSF		INTCON, PEIE		;ENABLE PERIPHERAL INTERUPTS
		BCF		INTCON, GIE		;ENABLE ALL UNMASKED INTERUPTS
;*** SET PIE1 REG: *****
		BANKSEL PIE1
		BCF		PIE1, TMR1IE		;DISABLE TMR1 INTERUPT
		BCF		PIE1, TMR2IE		;DISABLE TMR2 INTERUPT POR PWM
		BCF		PIE1, CCP1IE		;DISABLE CCP1 INTERUPT
		BCF		PIE1, SSPIE		;DISABLE SSP INTERUPT
		BCF		PIE1, TXIE		;DISABLE USART TRANSMIT INTERUPT
		BCF		PIE1, RCIE		;DISABLE USART RECIEVE INTERUPT
		BCF		PIE1, ADIE		;DISABLE A/D INTERUPT
		BCF		PIE1, 7			;DISABLE PSP INTERUPT
;***** SET PIE2 REG: *****
		BANKSEL PIE2
		BCF		PIE2, OSFIE              ; SET OSCILLATOR PANIC
		BCF		PIE2, C2IE		 ; DISABLE COMPARATOR 2 INTERRUPT
		BCF		PIE2, C1IE		 ; DISABLE COMPARATRO 1 INTERRUPT
		BCF		PIE2, EEIE		 ; DISABLE EEPROM WRITE INTERRUPT
		BCF		PIE2, BCLIE		 ; DISABLE BUS COLLISION INTERRUPT
		BCF		PIE2, ULPWUIE		 ; DISABLE ULTRA LOW POWER INTERRUPT
		BCF		PIE2, 1			 ; NOT IMPLEMENTED
		BCF		PIE2, CCP2IE		 ; DISABLE CCP2 INTERRUPT
;**** SET PIR2 BITS *****
		BANKSEL PIR2
		BCF		PIR2, OSFIF             ; DISABLE INTERNAL FAILSAFE CLOCK
		BCF		PIR2, C2IF		; DISABLE C2 INTERRUPT FLAG
		BCF		PIR2, C1IF		; DISBLE C1 INTERRUPT FLAG
		BCF		PIR2, EEIF		; DISABLE EE WRITE INTERRUPT FLAG
		BCF		PIR2, BCLIF		; DISABLE BUS COLLISION INTERRUPT FLAG
		BCF		PIR2, ULPWUIF		; ULTRA LOW POWER WAKEUP INTERRUPT DIABLE
		BCF		PIR2, 1			; BIT NOT USED
		BCF		PIR2, CCP2IF		; CCP2 INTERUPT FLAD DISABLED
;*** SET CCP1CON REG: **
		BANKSEL CCP1CON
		MOVLW	H'000'				;DISABLE PWM & CCP
		MOVWF	CCP1CON
		BANKSEL CM2CON1
		MOVLW   H'000'
		MOVWF   CM2CON1

;*** TIMER 1 SETUP *****
		BANKSEL T1CON
		MOVLW	H'000'				;
		MOVWF	T1CON				;DISABLE TIMER 1

;*** TIMER 2 SETUP *****

		BANKSEL T2CON
		CLRF	T2CON				;DISABLE TIMER 2, 1:1 POST SCALE, PRESCALER 1
		MOVLW	H'000'				;SET PR2 FOR FULL COUNT 
		BANKSEL	PR2				;
		MOVWF	PR2				;PR2 IS SETS OUTPUT OF PWM HIGH WHEN = TMR2
 
;*** PORT A SETUP **** PORT B RB0 IS USED AS EDGE TRIGGERED INPUT

		BANKSEL	ADCON1
		BCF	ADCON1,7
		BSF	ADCON1,5
		BSF	ADCON1,6
		BANKSEL PORTA
		CLRF    PORTA                           ; CLEAR PORTA
		BANKSEL	TRISA
		MOVLW	H'FF'				;SET PORT A AS INPUT
		MOVWF	TRISA
		
;*** PORT B SETUP **** PORT B RB0 IS USED AS EDGE TRIGGERED INPUT
		BANKSEL PORTB
		CLRF    PORTB				; CLEAR PORTB 
		BANKSEL	TRISB
		MOVLW	H'F0'				;SET PORTB RB7-RB4 AS INPUT AND RB3-RB0 AS OUTPUT
		MOVWF	TRISB
		BANKSEL ANSELH
		MOVLW H'000'                            ; DISABLE ADC INPUTS BANK B
		MOVWF ANSELH				
		BANKSEL WPUB				; DISABLE ALL WEAK PULL UPS PORT B
		MOVLW   H'000'
		MOVWF   WPUB
		

;*** PORT C SETUP **** PORT B RB0 IS USED AS EDGE TRIGGERED INPUT
		BANKSEL PORTC
		CLRF    PORTC				; CLEAR PORTC
		BANKSEL	TRISC
		MOVLW	H'000'				;SET PORT C AS OUTPUT
		MOVWF	TRISC
		GOTO	MAIN				;END OF SETUP ROUTINE

;******************************************
;Main Code
;******************************************
MAIN	
		NOP
		BANKSEL PORTC 
		MOVLW H'23'                              ; MOVE LITERAL 'O' FOR DISPLAY IN HEX TO W
		MOVWF PORTC                              ; MOVE W TO PORTC WITH 0 ADDRESS BIT 
		CLRW	                                 ; CLEAR W
		GOTO RUN
RUN 
		BANKSEL PORTB				 ; INITIALIZE PORTB
		CLRF PORTB				 ; CLEAR PORTB FOR KNOWN STATE
		BSF PORTB,RB0				 ; SET RB0 TO TO A OUTPUT HIGH
		BTFSC PORTB,RB4                          ; CHECK INPUTS KEYPRESS OF FIRST ROW
		GOTO SET0
		BTFSC PORTB,RB5
		GOTO SET1
		BTFSC PORTB,RB6
		GOTO SET2
		BTFSC PORTB,RB7
		GOTO SET3                                ; FINISH CHECK OF M ASSOCIATED BITS
		BCF PORTB,RB0	                         ; CLEAR RB0 AS A HIGH
		
		
		BSF PORTB,RB1                            ; SET RB1 TO A OUTPUT HIGH
		BTFSC PORTB,RB4                          ; CHECK INPUTS KEYPRESS OF SECOND ROW
		GOTO SET4
		BTFSC PORTB,RB5
		GOTO SET5
		BTFSC PORTB,RB6
		GOTO SET6
		BTFSC PORTB,RB7
		GOTO SET7                               ; FINISH CHECK OF L ASSOCIATED BITS   
		BCF PORTB,RB1                           ; CLEAR PIN RB1 AS AN OUTPUT HIGH
		
		BSF PORTB,RB2                           ; SET RB2 AS AN OUTPUT HIGH
		BTFSC PORTB,RB4                         ; CHECK INPUTS FOR KEYPRESS OF THIRD ROW
		GOTO SET8
		BTFSC PORTB,RB5
		GOTO SET9
		BTFSC PORTB,RB6
		GOTO SETA
		BTFSC PORTB,RB7
		GOTO SETB                               ; FINISH CHECK OF K ASSOCIATED BITS
		BCF PORTB,RB2				; CLEAR RB2 OF OUTPUT HIGH
		
		BSF PORTB, RB3				; SET RB3 AS AN OUTPUT HIGH 
		BTFSC PORTB,RB4				; CHECK INPUTS FOR A KEYPRESS OF THIRD ROW
		GOTO SET34	
		BTFSC PORTB,RB5
		GOTO SETD
		BTFSC PORTB,RB6
		GOTO SETE
		BTFSC PORTB,RB7
		GOTO SETF                              ; FINISH CHECK OF J ASSOCIATED BITS
		BCF PORTB, RB3
		GOTO MAIN			       ; IF NO BITS ARE SET RETURN TO MAIN TO SET #

		
		
SET0
		CLRW				       ; CLEAR WORKING REGISTER
 		MOVLW H'30'                            ; MOVE HEXCODE FOR DISPLAY NUMBER
		BANKSEL PORTC                          ; INIT PORTC
		MOVWF PORTC			       ; MOVE HEX INTO PORTC
		GOTO RUN                               ; RETURN BACK TO RUN PROGRAM
						       ; OTHER SUB PROGRAMS MAINTAIN SAME STRUCTURE
SET1
		CLRW
		MOVLW H'31'
		BANKSEL PORTC 
		MOVWF PORTC
		GOTO RUN
		
SET2
		CLRW
		MOVLW H'32'
		BANKSEL PORTC 
		MOVWF PORTC
		GOTO RUN
		
SET3
		CLRW
		MOVLW H'33'
		BANKSEL PORTC 
		MOVWF PORTC
		GOTO RUN

SET4
		CLRW
		MOVLW H'34'
		BANKSEL PORTC 
		MOVWF PORTC
		GOTO RUN

SET5
		CLRW
		MOVLW H'35'
		BANKSEL PORTC 
		MOVWF PORTC
		GOTO RUN
		
SET6
		CLRW
		MOVLW H'36'
		BANKSEL PORTC 
		MOVWF PORTC
		GOTO RUN
		
SET7
		CLRW
		MOVLW H'37'
		BANKSEL PORTC 
		MOVWF PORTC
		GOTO RUN
		
SET8
		CLRW
		MOVLW H'38'
		BANKSEL PORTC 
		MOVWF PORTC
		GOTO RUN
		
SET9
		CLRW
		MOVLW H'39'
		BANKSEL PORTC 
		MOVWF PORTC
		GOTO RUN
		
SETA
		CLRW
		MOVLW H'41'
		BANKSEL PORTC 
		MOVWF PORTC
		GOTO RUN
		
SETB
		CLRW
		MOVLW H'42'
		BANKSEL PORTC 
		MOVWF PORTC
		GOTO RUN
		
SET34
		CLRW
		MOVLW H'43'
		BANKSEL PORTC 
		MOVWF PORTC
		GOTO RUN
		
SETD
		CLRW
		MOVLW H'44'
		BANKSEL PORTC 
		MOVWF PORTC
		GOTO RUN

SETE
		CLRW
		MOVLW H'45'
		BANKSEL PORTC 
		MOVWF PORTC
		GOTO RUN

SETF
		CLRW
		MOVLW H'46'
		BANKSEL PORTC 
		MOVWF PORTC
		GOTO RUN
		
END