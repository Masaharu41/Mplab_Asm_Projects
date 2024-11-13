;***************************************************************************
;
;	    Filename: AN12.inc
;	    Date: 09/24/2024
;	    File Version: 1
;	    Author: Owen Fujii
;	    Company: Idaho State University
;	    Description: A Sub routine for saving status and working 
;
;*************************************************************************
	
;*************************************************************************
; 
;	    Revision History:
;   
;	    Modified as listed
;	    Started 09/25/2024 - Finished 09/25/2024
;	    Modified 09/26/24
;		CHANGED ORDER OF MOVWF FOR CORRECT STORAGE
;
;*************************************************************************

AN10_CODE CODE	
	
AN10

	BCF STATUS,RP0
	CLRF ADCON0		; CONFIGURE ANALOG TO DIGITAL REGISTER
	MOVLW H'A8'		; USE FOSC/8 AND AN12 FOR INPUT
	MOVWF ADCON0
	BANKSEL ADCON1
	CLRF ADCON1
	BSF PIE1,6              ; ENABLE ADC INTERRUPT
	BANKSEL ADCON0
	CLRF PIR1
	BSF ADCON0,0            ; ENABLE ADC
	BSF ADCON0,1
	RETURN