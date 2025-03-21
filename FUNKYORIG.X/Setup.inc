;***************************************************************************
	;September 12, 2024
	;Owen Fujii
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
		ORG H'004'
		GOTO INTER

;******************************************
;SETUP ROUTINE
;******************************************
SETUP
;*** SFR SETUP **********
 
		
;*** SET OPTION_REG: ****
		BANKSEL OPTION_REG
		MOVLW H'F4'                             ; INITIALIZE SET OF RBPU INTEDG T0SE 
		MOVWF OPTION_REG
;*** SET INTCON REG: ****
		BANKSEL INTCON
		MOVLW H'C0'
		MOVWF INTCON   				; INIT PEIE
;*** SET PIE1 REG: *****
		BANKSEL PIE1
		MOVLW H'01'				; INIT PIE1 CLEAR
		MOVWF PIE1
;***** SET PIE2 REG: *****
		BANKSEL PIE2
		MOVLW H'00'				; INIT OSFIE CLEAR OTHERS
		MOVWF PIE2
;*** SET CCP1CON REG: **
		BANKSEL CCP1CON
		MOVLW	H'000'				;DISABLE PWM & CCP
		MOVWF	CCP1CON
		BANKSEL CCP2CON
		CLRF CCP2CON
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
		MOVLW	H'FE'				;SET PORT A INPUT EXEPT RA0
		MOVWF	TRISA
		
;*** PORT B SETUP **** PORT B RB0 IS USED AS EDGE TRIGGERED INPUT
		BANKSEL PORTB
		CLRF    PORTB				; CLEAR PORTB 
		BANKSEL	TRISB
		MOVLW	H'FF'				;SET PORT B AS INPUT
		MOVWF	TRISB
		BANKSEL ANSELH
		MOVLW H'000'                            ; DISABLE ADC INPUTS BANK B
		MOVWF ANSELH				
		BANKSEL WPUB				; DISABLE ALL WEAK PULL UPS PORT B
		MOVLW   H'00'
		MOVWF   WPUB
		

;*** PORT C SETUP **** PORT B RB0 IS USED AS EDGE TRIGGERED INPUT
		BANKSEL PORTC
		CLRF    PORTC				; CLEAR PORTC
		BANKSEL	TRISC
		MOVLW	H'000'				;SET PORT C AS OUTPUT
		MOVWF	TRISC
		GOTO	MAIN				;END OF SETUP ROUTINE
