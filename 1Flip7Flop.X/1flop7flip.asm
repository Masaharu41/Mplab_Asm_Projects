;***************************************************************************
;
;	    Filename: PortB Interrupt.asm
;	    Date: 09/24/2024
;	    File Version: 1
;	    Author: Owen Fujii
;	    Company: Idaho State University
;	    Description: A program utilizing Portb interrupt 
;
;*************************************************************************
	
;*************************************************************************
; 
;	    Revision History:
;   
;	    Modified as listed
;	    Started 09/24/2024 - Finished 09/24/2024
;
;*************************************************************************

    	;Basic Setup File for the PIC16F883

		#INCLUDE <p16f883.inc>        		; processor specific variable definitions
		#INCLUDE <BSetup.inc.inc>
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
	CALL START                ; CALL SETUP CODE FROM INCLUDE FILE
	GOTO RUN
RUN
	BANKSEL PORTC	  
	    MOVLW H'31'           ; CONTINOUS LOOP THAT WRITES 1 TO THE DISPLAY
	    MOVWF PORTC
	    GOTO RUN
	
SEVEN
	BANKSEL PORTC	     
	    MOVLW H'37'		; WRITES A SEVEN TO THE OUTPUT
	    MOVWF PORTC
	    MOVLW H'DF'
	    MOVWF TMR2		; NESTED LOOP WITH A SIMPLE LOOP FOR 2 SECOND DELAY
LOOP2
	    CLRF TMR0
LOOP
	    NOP
	    NOP
	    NOP
	    NOP
	    NOP
	    NOP
	    NOP
	    NOP
	    NOP
	    NOP
	    NOP
	    NOP
	    NOP
	    NOP
	    NOP
	    NOP
	    NOP
	    NOP
	    NOP
	    NOP
	    NOP
	    NOP
	    NOP
	    NOP
	    NOP
	    NOP
	    NOP
	    NOP
	    NOP
	    NOP
	    NOP
	    NOP
	    NOP
	    DECFSZ TMR0
	    GOTO LOOP
	    DECFSZ TMR2
	    GOTO LOOP2
	    MOVLW H'FC'
	    MOVWF TMR0
LOOP3
	    NOP
	    NOP
	    NOP
	    NOP
	    NOP
	    NOP
	    DECFSZ TMR0
	    GOTO LOOP3
	    BCF INTCON,0
	    RETFIE
	    
	
INTER
	BANKSEL INTCON
	    BTFSC INTCON, 0
	    GOTO SEVEN
	    RETFIE
	
END
