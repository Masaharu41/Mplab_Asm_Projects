	;BassyBass.asm
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
		MOVLW H'40'
		MOVWF INTCON   				; INIT PEIE
;*** SET PIE1 REG: *****
		BANKSEL PIE1
		MOVLW H'00'				; INIT PIE1 CLEAR
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

;******************************************
;Main Code
;******************************************
MAIN	
	BANKSEL PORTC 
	    CLRF PORTC
	    
KEYPAD
		BSF PORTC, 4
		BTFSC PORTB,RB4                          ; CHECK INPUTS KEYPRESS OF FIRST ROW
		GOTO CTHREE
		BTFSC PORTB,RB5
		GOTO DTHREE
		BTFSC PORTB,RB6
		GOTO ETHREE
		BTFSC PORTB,RB7
		GOTO FTHREE                               ; FINISH CHECK OF M ASSOCIATED BITS
		BCF PORTC, 4
		
		
		
		BSF PORTC, 5                         
		BTFSC PORTB,RB4                          
		GOTO GTHREE
		BTFSC PORTB,RB5
		GOTO ATHREE
		BTFSC PORTB,RB6
		GOTO BTHREE
		BTFSC PORTB,RB7
		GOTO CFOUR                               
		BCF PORTC, 5
		
		BSF PORTC, 6                      
		GOTO DFOUR
		BTFSC PORTB,RB5
		GOTO EFOUR
		BTFSC PORTB,RB6
		GOTO FFOUR
		BTFSC PORTB,RB7
		GOTO GFOUR                          
		
		
		
		BSF PORTC, 7
		BTFSC PORTB,RB4				
		GOTO AFOUR	
		BTFSC PORTB,RB5
		GOTO BFOUR
		BTFSC PORTB,RB6
		GOTO CFIVE
		BTFSC PORTB,RB7
		GOTO DFIVE                           
		BCF PORTC, 7
		GOTO KEYPAD
		
CTHREE
		CLRF H'21'
		MOVLW H'00'
		MOVWF H'21'
		CALL ONETONE
		
DTHREE
		CLRF H'21'
		MOVLW H'01'
		MOVWF H'21'
		CALL ONETONE
		
ETHREE
		CLRF H'21'
		MOVLW H'02'
		MOVWF H'21'
		CALL ONETONE

FTHREE
		CLRF H'21'
		MOVLW H'03'
		MOVWF H'21'
		CALL ONETONE
		
GTHREE
		CLRF H'21'
		MOVLW H'04'
		MOVWF H'21'
		CALL ONETONE

ATHREE
		CLRF H'21'
		MOVLW H'05'
		MOVWF H'21'
		CALL ONETONE
		
BTHREE
		CLRF H'21'
		MOVLW H'06'
		MOVWF H'21'
		CALL ONETONE    
		
CFOUR
		CLRF H'21'
		MOVLW H'07'
		MOVWF H'21'
		CALL ONETONE	 
		
DFOUR
		CLRF H'21'
		MOVLW H'08'
		MOVWF H'21'
		CALL ONETONE
		
EFOUR
		CLRF H'21'
		MOVLW H'09'
		MOVWF H'21'
		CALL ONETONE
		
FFOUR
		CLRF H'21'
		MOVLW H'0A'
		MOVWF H'21'
		CALL ONETONE
		
GFOUR
		CLRF H'21'
		MOVLW H'0B'
		MOVWF H'21'
		CALL ONETONE
		
AFOUR
		CLRF H'21'
		MOVLW H'0C'
		MOVWF H'21'
		CALL ONETONE
		
BFOUR
		CLRF H'21'
		MOVLW H'0D'
		MOVWF H'21'
		CALL ONETONE
		
CFIVE
		CLRF H'21'
		MOVLW H'0E'
		MOVWF H'21'
		CALL ONETONE
		
DFIVE
		CLRF H'21'
		MOVLW H'0F'
		MOVWF H'21'
		CALL ONETONE
	    
ONETONE
	    MOVLW H'01'
	    MOVWF PORTC
	    CALL DELAY    
	    MOVLW H'01'
	    XORWF PORTB,0
	    MOVWF PORTC
	    MOVWF PORTA
	    CALL DELAY    
	    MOVLW H'01'
	    XORWF PORTB,0
	    MOVWF PORTC
	    MOVWF PORTA
	    GOTO KEYPAD	    
	    
	   
DELAY
	    MOVF H'21',0
	    CALL TABLE
	    MOVWF TMR2
LOOP2
	    CLRF TMR0
LOOP1
	    NOP
	    NOP
	    NOP
	    DECFSZ TMR0
	    GOTO LOOP1
	    DECFSZ TMR2
	    GOTO LOOP2
	    MOVF H'21',0
	    CALL TABLETWO
	    MOVWF TMR0
LOOP3
	    NOP
	    NOP
	    NOP
	    DECFSZ TMR0
	    GOTO LOOP3
	    RETURN
	    
	   
TABLE
	    ADDWF PCL,1
	    RETLW H'07'	;E1
	    RETLW H'07'	;F1
	    RETLW H'07'	;F#1
	    RETLW H'06'	;G1
	    RETLW H'06'	;G#1
	    RETLW H'05'	;A1
	    RETLW H'05'	;A#1
	    RETLW H'05'	;B1
	    RETLW H'04'	;C2
	    RETLW H'04'	;C#2
	    RETLW H'04'	;D2
	    RETLW H'04'	;D#2
	    RETLW H'03'	;A4
	    RETLW H'01'	;B4
	    RETLW H'01' ;C5
	    RETLW H'01' ;D5
	    
TABLETWO
	    ADDWF PCL,1
	    RETLW H'E7'	;E1 0
	    RETLW H'A5'	;F1 1
	    RETLW H'0A'	;F#1 2
	    RETLW H'A5'	;G1 3
	    RETLW H'45'	;G#1 4
	    RETLW H'EB'	;A1 5
	    RETLW H'8A'	;A#1 6
	    RETLW H'46'	;B1 7
	    RETLW H'FA'	;C2 8
	    RETLW H'B2'	;C#2 9
	    RETLW H'6F'	;D2 A
	    RETLW H'2F'	;D#2 B
	    RETLW H'F2'	;E2 C
	    RETLW H'42'	; D 
	    RETLW H'2E' ;C5 E
	    RETLW H'0B' ;D5 F
	    
	    
	    
	    
	    
END