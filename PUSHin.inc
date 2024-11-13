;***************************************************************************
;
;	    Filename: PUSHin.inc
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
;
;*************************************************************************
PUSHIN_CODE CODE
 PUSHIN
		MOVF H'21'      ; ROUTINE FOR RESTORING WORKING AND STATUS
		MOVWF STATUS	
		MOVF H'20'
		RETURN