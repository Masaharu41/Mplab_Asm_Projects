;***************************************************************************
;
;	    Filename: Setup.inc
;	    Date: 09/24/2024
;	    File Version: 1
;	    Author: Owen Fujii
;	    Company: Idaho State University
;	    Description: A collection of registry setups and subroutines
;
;*************************************************************************
	
;*************************************************************************
; 
;	    Revision History:
;   1: Inc file to contain generic registry setups 
;
;	2: Removed GPR setup and added code reference 
;	    Modified as listed
;	    Started 09/24/2024 -Current version implemented 10/7/2024
;
;*************************************************************************
	
	
START_CODE CODE

START


		
;*** SET OPTION_REG: ****
		BANKSEL OPTION_REG
		MOVLW H'F4'                             ; INITIALIZE SET OF RBPU INTEDG T0SE 
		MOVWF OPTION_REG
;*** SET INTCON REG: ****
		BANKSEL INTCON
		MOVLW H'00'
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
		MOVLW H'10'                            ; DISABLE ADC INPUTS BANK B
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
		RETURN
