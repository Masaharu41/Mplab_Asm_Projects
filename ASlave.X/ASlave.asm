;***************************************************************************
;
;	    Filename: FilenameHere.asm
;	    Date: mm/dd/yyyy
;	    File Version: x
;	    Author: Owen Fujii
;	    Company: Idaho State University
;	    Description: A Program for a slave I2C device that controls
;			 servo motors using PWM 
;**************************************************************************
	
;*************************************************************************
; 
;	    Revision History:
;   
;	    Modified as listed
;	    Started 
;
;*************************************************************************
    
    ; PIC16F1788 Configuration Bit Settings

; Assembly source line config statements

	

; CONFIG1
; __config 0xE9A4
 __CONFIG _CONFIG1, _FOSC_INTOSC & _WDTE_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _CPD_OFF & _BOREN_OFF & _CLKOUTEN_OFF & _IESO_OFF & _FCMEN_ON
; CONFIG2
; __config 0xDFFF
 __CONFIG _CONFIG2, _WRT_OFF & _VCAPEN_OFF & _PLLEN_ON & _STVREN_ON & _BORV_LO & _LPBOR_OFF & _LVP_OFF

 
 ;*********************
 ;Define Constants
 ;*********************
 

    ORG H'000'					
    GOTO SETUP					;RESET CONDITION GOTO SETUP
    ORG H'004'
    GOTO INTER
 
    
SETUP
    BANKSEL OSCCON
    MOVLW H'06B'	    ; SET 1MHZ INTERNAL OSSCILATOR
    MOVWF OSCCON
    BANKSEL OSCSTAT
    BTFSC OSCSTAT,OSTS	    ; WAIT FOR OSSCILATOR TO BE READY
    GOTO $-1
    CALL START		    ; CALL SETUP INCLUDE
 
END