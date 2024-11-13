;***************************************************************************
;
;	    Filename: AN12.inc
;	    Date: 10/14/2024
;	    File Version: 1
;	    Author: Owen Fujii
;	    Company: Idaho State University
;	    Description: A Sub routine for enabling an12   
;
;*************************************************************************
	
;*************************************************************************
; 
;	    Revision History:
;   
;	    Modified as listed
;	    Started 10/14/2024 - Finished 10/20/2024
;	  
;*************************************************************************

AN12_CODE CODE	
	
AN12
	BCF STATUS,RP0
	CLRF ADCON0		; CONFIGURE ANALOG TO DIGITAL REGISTER
	MOVLW H'B0'		; USE FOSC/8 AND AN12 FOR INPUT
	MOVWF ADCON0
	BANKSEL ADCON1
	CLRF ADCON1
	BSF ADCON1,4          ; ENABLE ADC INTERRUPT
	BANKSEL ADCON0
	CLRF PIR1
	BSF ADCON0,0            ; ENABLE ADC
	BSF ADCON0,1
	RETURN