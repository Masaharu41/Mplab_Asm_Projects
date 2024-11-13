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
;	    Started 09/24/2024 - Finished 09/26/2024
;
;*************************************************************************

    	;Basic Setup File for the PIC16F883

		#INCLUDE <p16f883.inc>        		; processor specific variable definitions
		#INCLUDE <BSetup.inc.inc>
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
	    CLRF H'25'
	    GOTO RUN
	    
INTER
	BANKSEL INTCON            
	    CALL PUSHIN
	    BTFSC INTCON, 0     ; CHECK RB INTERRUPT FLAG
	    GOTO CHECKOUT
	    BCF INTCON,0
	    RETFIE
	    
CHECKOUT
	   BANKSEL PORTB
		CLRF INTCON     ; CLEAR INTERRUPT ENABLE FOR CHECKING PORT
		BTFSC PORTB,0	; CHECK RB0
		GOTO SEVEN
		BTFSC PORTB,1   ; CHECK RB1
		GOTO SIX
		MOVLW H'88'
		MOVWF INTCON
		MOVF H'21'      ; ROUTINE FOR RESTORING WORKING AND STATUS
		MOVWF STATUS	
		MOVF H'20'
		RETFIE
		
SEVEN
	BTFSC H'25',0
	CALL SAVESIX
	MOVLW H'37'            ; SET WORKING TO DISPLAY A 7 WHEN MOVED TO PORTC
	GOTO DELAY
	
SAVESIX
	MOVF TMR0,0		; SAVE COUNTING REGISTERS FOR CURRENT COUNT OF 6
	MOVWF H'24'
	MOVF TMR2,0
	MOVWF H'23'
	MOVF COUNT3,0
	MOVWF H'26'
	MOVLW H'36'		; STORE LAST DISPLAY STATE IN SEPERATE REGISTER
	MOVWF H'27'
	RETURN
	
RECALLSIX
	CLRF INTCON
	BTFSS PORTC,0
	GOTO SKIP
	BANKSEL PORTC
	MOVF H'24',0
	MOVWF TMR0
	MOVF H'23',0
	MOVWF TMR2
	MOVF H'26',0
	MOVWF COUNT3
	MOVF H'27',0
	MOVWF PORTC
	RETURN
SKIP
	BANKSEL IOCB
	CLRF IOCB
	MOVLW H'03'
	MOVWF IOCB
	RETURN
	
SIX
	BANKSEL IOCB
	CLRF IOCB
	MOVLW H'01'
	MOVWF IOCB
	
	BANKSEL INTCON
	CLRF H'25'
	BSF H'25',0
	MOVLW H'88'         ; RE-ENABLE INTERRUPTS AND RESTORE
	MOVWF INTCON 
	MOVLW H'36'	       ; SET WORKING TO DISPLAY A 6 WHEN MOVED TO PORTC
	GOTO DELAY
	
	
DELAY
	BANKSEL PORTC	     
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
	    MOVWF COUNT3
LOOP3
	    NOP
	    NOP
	    NOP
	    NOP
	    NOP
	    NOP
	    DECFSZ COUNT3
	    GOTO LOOP3
	    BANKSEL INTCON
	    BTFSC H'25',0
	    CALL RECALLSIX
	    BANKSEL INTCON
	    MOVLW H'88'         ; RE-ENABLE INTERRUPTS AND RESTORE
	    MOVWF INTCON 
	    CALL POPOUT
	    RETFIE
	    
	
END
