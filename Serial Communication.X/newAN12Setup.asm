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

AN12_CODE CODE
 
ADCSTART
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
	RETURN
	

	
END	
	
	