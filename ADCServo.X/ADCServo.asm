;***************************************************************************
;
;	    Filename: ADCServo.asm
;	    Date: 09/30/2024
;	    File Version: 1
;	    Author: Owen Fujii
;	    Company: Idaho State University
;	    Description: A program that uses Adc to adjust a servo motor
;
;*************************************************************************
	
;*************************************************************************
; 
;	    Revision History:
;   
;	    Modified as listed
;	    Started 10/7/2024-
;
;*************************************************************************

    	;Basic Setup File for the PIC16F883

		#INCLUDE <p16f883.inc>        		; processor specific variable definitions
		#INCLUDE <ServoSetup.inc>
		#INCLUDE <ServoPOPout.inc>
		#INCLUDE <ServoPUSHin.inc>
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
 
	    STORE      EQU H'22'
	    SAVE       EQU H'23'
	    ROTATE     EQU H'24'
	    PWM        EQU H'25'
	    
       
	    
 
 ; GPR 20 and 21 are used for interrupt save
 
		ORG H'000'					
		GOTO SETUP					;RESET CONDITION GOTO SETUP
		ORG H'004'
		GOTO INTER
		
TABLE
	ADDWF PCL,1	    ; TABLE THAT CONTAINS EACH PW
	RETLW H'32'
	RETLW H'38'
	RETLW H'3F'
	RETLW H'45'
	RETLW H'4B'
	RETLW H'51'
	RETLW H'58'
	RETLW H'5E'
	RETLW H'64'
	RETLW H'6A'
	RETLW H'71'
	RETLW H'77'
	RETLW H'7D'
	RETLW H'84'
	RETLW H'8B'
	RETLW H'93'
 
 SETUP
	CALL START
	BCF STATUS,RP0
	CLRF ADCON0		; CONFIGURE ANALOG TO DIGITAL REGISTER
	MOVLW H'70'		; USE FOSC/8 AND AN12 FOR INPUT
	MOVWF ADCON0
	BANKSEL ADCON1
	CLRF ADCON1
	BSF ADCON1,4
	MOVLW H'43'
	MOVWF PIE1		; ENABLE ADC INTERRUPT, TMR1, TMR2
	BANKSEL ADCON0
	CLRF PIR1
	BSF ADCON0,0            ; ENABLE ADC
	BSF ADCON0,1
	BSF INTCON,GIE
	BSF INTCON,PEIE
	GOTO MAIN
	
MAIN
	NOP
	GOTO MAIN

INTER
	CALL PUSHIN
	BANKSEL PIR1
	BTFSC PIR1,6		; CHECK ADC
	CALL CONVERT
	BTFSC PIR1,1		; CHECK TMR2
	CALL PW
	BTFSC PIR1,0		; CHECK TMR1
	CALL RESTART
	CALL POPOUT
	RETFIE

CONVERT
	CLRF INTCON
	BCF PIR1,6
	BCF ADCON0,0		; DISABLE ADC
	BCF ADCON0,1
	MOVF ADRESH,0           ; MOVE UPPER BITS TO GPR
	MOVWF STORE
	SWAPF STORE,1
	BCF STORE,4		; CLEAR UPPER BITS IN REGISTER
	BCF STORE,5
	BCF STORE,6
	BCF STORE,7
	BCF STATUS,Z
	CLRF PWM
	GOTO CHECK


	
TMRSTART
	MOVF PWM,0	;MOVE OFFSET INTO WORKING
	CALL TABLE	; CALL TABLE WITH DELAY VALUES
	BANKSEL PR2
	MOVWF PR2	; MOVE DELAY VALUE INTO PR2
	BANKSEL TMR2
	CLRF TMR2	; CLEAR TMR2
	MOVLW H'02'     ; CONFIGURE TMR2
	MOVWF T2CON
	BSF T2CON,2	; ENABLE TMR2
	BSF INTCON,7	; ENABLE INTERRUPTS
	BSF INTCON,6
	BSF PORTC,0	; SET OUTPUT HIGH
	RETURN
	
CHECK
	MOVF PWM,0  
	SUBWF STORE,0	; SUBTRACT STORE FROM PWM
	BTFSC STATUS,Z	; CHECK IF OUTCOME IS EQUAL
	GOTO TMRSTART
	INCF PWM,1
	BCF STATUS,Z
	GOTO CHECK

	
PW
	BANKSEL T2CON
	CLRF INTCON
	BCF T2CON,2	    ; DISABLE TMR2  
	BCF PORTC,0
	BCF PIR1,1          
	CLRF T1CON          ; SET T1CON 
	MOVLW H'B1'	    ; OFFSET TMR1 FOR A COUNT OF 20K FOR ROLLOVER
	MOVWF TMR1H
	MOVLW H'E3'
	MOVWF TMR1L
	BSF T1CON,0         ; START TMR1
	BSF INTCON,7
	BSF INTCON,6
	RETURN
	
RESTART
	BANKSEL T1CON
	CLRF INTCON
	BCF T1CON,0	    ; DISABLE TMR1
	BCF PIR1,0	    ; CLEAR INT FLAG
	CLRF ADRESH	    ; CLEAR UPPER REGISTER ADC
	BSF STATUS,RP0
	CLRF ADRESL	    ; CLEAR LOWER REGISTER ADC
	BCF STATUS,RP0
	BSF ADCON0,0	    ; RE ENABLE ADC CONVERSION
	BSF ADCON0,1
	BSF INTCON,7
	BSF INTCON,6
	RETURN
	
	
END