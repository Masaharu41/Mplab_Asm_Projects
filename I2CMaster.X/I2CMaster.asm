;***************************************************************************
;
;	    Filename: I2CMaster.asm
;	    Date: 10/28/2024
;	    File Version: 1
;	    Author: Owen Fujii
;	    Company: Idaho State University
;	    Description: A program for the master of an I2C communication network
;			    that tests multiple ADC inputs and sends that data to the slave
;*************************************************************************
	
;*************************************************************************
; 
;	    Revision History:
;   
;	    Modified as listed
;	    Started 10/28/2024-10/31/2024
;
;*************************************************************************

    	;Basic Setup File for the PIC16F883

		#INCLUDE <p16f883.inc>        		; processor specific variable definitions
		#INCLUDE <MasterSetup.inc>
		#INCLUDE <MasterPOPout.inc>
		#INCLUDE <MasterPUSHin.inc>
		#INCLUDE <AN0ADC.inc>
		#INCLUDE <AN1ADC.inc>
		#INCLUDE <I2CWRITE.inc>
		#INCLUDE <AN4ADC.inc>
		
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
 
	    AN0LAST     EQU H'22'
	    AN1LAST     EQU H'23'
	    AN4LAST	EQU H'24'
	    MAX		EQU H'25'
	    
	  ;  PWM        EQU H'25'
; **************************************
;	    RESERVED MEMORY I2C address H'30'	
;			    I2C byte out H'31'
	    ADDRESS EQU H'30'
	    I2CDAT  EQU H'31'
  
	    
       
	    
 
 ; GPR 20 and 21 are used for interrupt save
 
		ORG H'000'					
		GOTO SETUP					;RESET CONDITION GOTO SETUP
		ORG H'004'
		

 SETUP
	CALL START
	BANKSEL ANSEL	; ENABLE AN0,AN1,AN4
	MOVLW H'013'
	MOVWF ANSEL
	BANKSEL SSPCON
	MOVLW H'028'
	MOVWF SSPCON
	BANKSEL SSPADD
	MOVLW H'009'	; SET BAUD FOR 100KHZ
	MOVWF SSPADD
	BANKSEL PORTB
	MOVLW H'040'	; MOVE ADDRESS CHARACTER INTO GPR
	MOVWF ADDRESS
	MOVLW H'014'	; SET MAXIMUM VALUE OF 20
	MOVWF MAX
	GOTO MAIN
	
MAIN
	CALL AN0	; CALL INCLUDE FILE TO ENABLE AN0
	BTFSC ADCON0,GO	; WAIT FOR ADC TO FINISH
	GOTO $-1
	RRF ADRESH,1	; SHIFT UPPER REGISTER RIGHT 3 TIMES
	RRF ADRESH,1
	RRF ADRESH,1
	BCF ADRESH,7	; BLANK OUT UPPER BITS 7-5
	BCF ADRESH,6
	BCF ADRESH,5
	MOVF ADRESH,0	
	BCF STATUS,Z
	SUBWF AN0LAST,0	; COMPARE TO LAST RESULT
	BTFSS STATUS,Z
	CALL SENDAN0	; IF RESULTS ARE DIFFERENT SEND DATA
	CLRF PORTB
	; PROCESS IS REPEATED FOR AN1 AND AN4
	CALL AN1
	BTFSC ADCON0,GO
	GOTO $-1
	RRF ADRESH,1
	RRF ADRESH,1
	RRF ADRESH,1
	BCF ADRESH,7
	BCF ADRESH,6
	BCF ADRESH,5
	MOVF ADRESH,0
	BCF STATUS,Z
	SUBWF AN1LAST,0
	BTFSS STATUS,Z
	CALL SENDAN1
	;
	CALL AN4
	BTFSC ADCON0,GO
	GOTO $-1
	RRF ADRESH,1
	RRF ADRESH,1
	RRF ADRESH,1
	BCF ADRESH,7
	BCF ADRESH,6
	BCF ADRESH,5
	MOVF ADRESH,0
	BCF STATUS,Z
	SUBWF AN4LAST,0
	BTFSS STATUS,Z
	CALL SENDAN4
	GOTO MAIN

SENDAN0
	MOVF ADRESH,0
	SUBWF MAX,0	; COMPARE RESULT TO THE MAXIMUM VALUE ALLOWED TO SEND
	BTFSS STATUS,C
	RETURN		; IF GREATER THAN // LEAVE
	MOVF ADRESH,0
	MOVWF AN0LAST	; MOVE RESULT INTO STORAGE
	RLF ADRESH,1	; SHIFT LEFT THREE TIMES
	RLF ADRESH,1
	RLF ADRESH,1
	BSF ADRESH,0	; ENABLE SERVO 1
	BCF ADRESH,1
	BCF ADRESH,2
	MOVF ADRESH,0
	MOVWF I2CDAT	; MOVE TO DATA GPR
	CALL I2CWRITE	; CALL WRITE INCLUDE FILE FOR I2C
	RETURN
	
SENDAN1
	MOVF ADRESH,0
	SUBWF MAX,0
	BTFSS STATUS,C
	RETURN
	MOVF ADRESH,0
	MOVWF AN1LAST
	RLF ADRESH,1
	RLF ADRESH,1
	RLF ADRESH,1
	BCF ADRESH,0
	BSF ADRESH,1
	BCF ADRESH,2
	MOVF ADRESH,0
	MOVWF I2CDAT
	CALL I2CWRITE
	RETURN
	
SENDAN4
	MOVF ADRESH,0
	SUBWF MAX,0
	BTFSS STATUS,C
	RETURN
	MOVF ADRESH,0
	MOVWF AN4LAST
	RLF ADRESH,1
	RLF ADRESH,1
	RLF ADRESH,1
	BCF ADRESH,0
	BCF ADRESH,1
	BSF ADRESH,2
	MOVF ADRESH,0
	MOVWF I2CDAT
	CALL I2CWRITE
	RETURN
	
	
END


