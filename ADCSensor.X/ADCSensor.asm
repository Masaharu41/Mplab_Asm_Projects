;***************************************************************************
;
;	    Filename: ADCSensor.asm
;	    Date: 09/30/2024
;	    File Version: 1
;	    Author: Owen Fujii
;	    Company: Idaho State University
;	    Description: A program that uses Adc to read a temperature sensor
;
;*************************************************************************
	
;*************************************************************************
; 
;	    Revision History:
;   
;	    Modified as listed
;	    Started 10/5/2024 - Finished 10/5/2024
;
;*************************************************************************

    	;Basic Setup File for the PIC16F883

		#INCLUDE <p16f883.inc>        		; processor specific variable definitions
		#INCLUDE <Setup.inc>
		#INCLUDE <POPout.inc>
		#INCLUDE <PUSHin.inc>
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
 
	    COMPARECNT EQU H'22'
	    STORAGECNT EQU H'23'
	    QUEUE      EQU H'24'
	    BOTH       EQU H'25'
	    HOLDDELAY  EQU H'26'
	    
 
 ; GPR 20 and 21 are used for interrupt save
 
		ORG H'000'					
		GOTO SETUP					;RESET CONDITION GOTO SETUP
		ORG H'004'
		GOTO INTER
 
 SETUP
	CALL START
	BCF STATUS,RP0
	CLRF ADCON0		; CONFIGURE ANALOG TO DIGITAL REGISTER
	MOVLW H'70'		; USE FOSC/8 AND AN12 FOR INPUT
	MOVWF ADCON0
	BANKSEL ADCON1
	CLRF ADCON1
	BSF PIE1,6              ; ENABLE ADC INTERRUPT
	BANKSEL ADCON0
	CLRF PIR1
	BSF ADCON0,0            ; ENABLE ADC
	BSF ADCON0,1
	BSF INTCON,GIE
	BSF INTCON,PEIE
	GOTO MAIN
	
MAIN
	NOP
	BANKSEL PORTA
	BCF PORTA,0
	GOTO MAIN
	
INTER
	CALL PUSHIN
	BANKSEL PIR1
	BTFSC PIR1,6
	CALL ADCRESULT
	BCF PIR1,6
	CALL POPOUT
	RETFIE
	
ADCRESULT
	BANKSEL ADCON0
	BTFSC ADCON0,1
	RETURN
	MOVF ADRESH,0
	MOVWF PORTC
	BSF PORTA,0
	BSF ADCON0,1
	RETURN
	
END	
	
	