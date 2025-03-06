   ;File Contains the sub routine to Set UP as Server/Peripheral and Read/Write Out I2C 
    
    ;Before an I2C_WRITE call Main Code Should:
    ;1. Load ADDRESS_W(R) Registers for Peripheral (Read and Write Registers)
    ;2. Load DATA_TX_1 Register with First Byte Data
    ;3. Load DATA_TX_2 Register with Second Byte Data (Optional)
    ;4. Set TWO_BYTES_F Bit 0.  0=Only One Byte  1=Two Bytes
    ;5. Call I2C_WRITE
    
    ;Before an I2C_READ call Main Code Should:
    ;1. Load ADDRESS_W(R) Registers for Peripheral (Read and Write Registers)
    ;2. Load DATA_TX_1 Register with the Desired Address To be Read
    ;3. Call I2C_READ
    ;4. Save DATA_RECEIVED to Desired Register
    
    ADDRESS_W			EQU	H'040'	    ;Temp register for storing the peripheral address write (I2C Server)
    ADDRESS_R			EQU	H'041'	    ;Temp register for storing the peripheral address read (I2C Server)
    DATA_TX_1			EQU	H'042'	    ;Temp register for storing the first data byte tranmitted (I2C Server)
    DATA_TX_2			EQU	H'043'	    ;Temp register for storing the second data byte transmitted (I2C Server)
    DATA_RECEIVED		EQU	H'044'	    ;Temporary Register for Reading (I2C Server)
    TWO_BYTES_F			EQU	H'045'	    ;Flag for Signalling more than one data byte transmission (I2C Server)
    I2C_RX_COUNTER		EQU	H'046'	    ;Register to track which data byte was las received (I2C Peripheral)
    I2C_RX_COMPLETE		EQU	H'047'	    ;Flag to Signal when full data packet has been received (I2C Peripheral)
		JOY1_UD		EQU	H'048'
		JOY1_LR		EQU	H'049'
		JOY2_UD		EQU	H'050'
		JOY2_LR		EQU	H'051'

    
    
    I2C_CODE    CODE
    
    I2C_SETUP_SERVER
    ;**************Peripheral Address Set***************

    ;**************Master SetUp************************
	BANKSEL	    TRISC
	BSF	    TRISC,3
	BSF	    TRISC,4 		;Set SCL and SDA as inputs
	BANKSEL	    SSPADD
	MOVLW	    H'27'
	MOVWF	    SSPADD		;Set BAUD Generator to 100Khz (16M Occilator)
	BANKSEL	    SSPCON
	MOVLW	    H'28'		
	MOVWF	    SSPCON		;Enable SDA and SLC Pins and Set as I2C Master Mode
	BANKSEL	    SSPCON2
	MOVLW	    H'00'
	MOVWF	    SSPCON2		;Disable General Call
	BANKSEL	    SSP1CON3
	MOVLW	    H'28'		;Min SDA Hold time 300ns
	MOVWF	    SSP1CON3
	BANKSEL	    SSPSTAT
	MOVLW	    H'A0'		
	MOVWF	    SSPSTAT		;Not in Tx mode, Slew Rate Control Disabled
	RETURN
	
    I2C_SETUP_PERIPHERAL
    ;**************Slave SetUp**************************
	BANKSEL	    TRISC
	BSF	    TRISC,3
	BSF	    TRISC,4		;Set SCL and SDA as inputs
	BANKSEL	    SSPADD
	MOVLW	    H'10'
	MOVWF	    SSPADD		;Peripheral Address Read=0x11; Write=0x10
	BANKSEL	    SSPCON
	MOVLW	    H'36'
	MOVWF	    SSPCON		;Enable SDA and SCL Pins, Enable Clock, and Set as 7 bit address Slave
	BANKSEL	    SSPCON2
	MOVLW	    H'09'
	MOVWF	    SSPCON2		;Disable General Call and Enable Receive and Clock Strechting
	BANKSEL	    SSP1CON3		
	MOVLW	    H'20'
	MOVWF	    SSP1CON3		;Disable Slave Interrupts, SDA Hold Time of 300nS, Auto Enable Address and Data Clock Stretching
	BANKSEL	    SSPSTAT
	MOVLW	    H'40'
	MOVWF	    SSPSTAT		;Disable Slew Rate Control and flags
	BANKSEL	    I2C_RX_COUNTER
	CLRF	    I2C_RX_COUNTER	;Begin at first Data Byte
	RETURN
	
    I2C_WRITE
	CALL	    I2C_IDLE		;Ensure the I2C BUS is idle
	BANKSEL	    SSPCON2
	BSF	    SSPCON2,0		;Generate Start Condition
    START_WRITE_DONE
	BTFSC	    SSPCON2,0
	GOTO	    START_WRITE_DONE	;Wait Until Start Condition Completes
	BANKSEL	    ADDRESS_W
	MOVFW	    ADDRESS_W
	BANKSEL	    SSPBUF
	MOVWF	    SSPBUF		;Send Peripheral Address (Write)
    ADDRESS_SENT_W
	BANKSEL	    SSPSTAT
	BTFSC	    SSPSTAT,0		
	GOTO	    ADDRESS_SENT_W	;Wait Until Buffer is Clear (Address is Sent)
	CALL	    I2C_IDLE		;Ensure the I2C BUS is idle
	BANKSEL	    SSPCON2
	BTFSC	    SSPCON2,6		;Was an Acknowledge Received?
	GOTO	    BAD_COND		;Acknowledge Not Received
	BANKSEL	    DATA_TX_1
	MOVFW	    DATA_TX_1
	BANKSEL	    SSPBUF
	MOVWF	    SSPBUF		;Send First Data Byte
    DATA_1_SENT_W
	BANKSEL	    SSPSTAT
	BTFSC	    SSPSTAT,0
	GOTO	    DATA_1_SENT_W	;Wait Until Buffer is Clear (Data is Sent)
	CALL	    I2C_IDLE		;Ensure the I2C BUS is idle
	BANKSEL	    SSPCON2
	BTFSC	    SSPCON2,6		;Was an Acknowledge Received?
	GOTO	    BAD_COND		;Acknowledge Not Received
	BANKSEL	    TWO_BYTES_F
	BTFSS	    TWO_BYTES_F,0	;If Two Bytes Flag is Set Send Second Byte
	GOTO	    GOOD_STOP		;Two Bytes Flag is 0 End Transmission
	BANKSEL	    DATA_TX_2
	MOVFW	    DATA_TX_2
	BANKSEL	    SSPBUF
	MOVWF	    SSPBUF		;Send Second Data Byte
    DATA_2_SENT
	BANKSEL	    SSPBUF
	BTFSC	    SSPBUF,0
	GOTO	    DATA_2_SENT		;Wait Unitl Buffer is Clear (Data is Sent)
	BANKSEL	    SSPCON2
	BTFSC	    SSPCON2,6		;Was an Acknowledge Received?
	GOTO	    BAD_COND		;Acknowledge not Received
    GOOD_STOP
	BANKSEL	    SSPCON2
	BSF	    SSPCON2,2		;Generate a Stop Condition
    GOOD_STOP_DONE
	BTFSC	    SSPCON2,2
	GOTO	    GOOD_STOP_DONE	;Wait Until Stop Condition Completes
	MOVLW	    H'00'
	RETURN				;Write Complete.  Return With 0x00 in Working Register
	
I2C_READ
	CALL	    I2C_IDLE		;Ensure the I2C BUS is idle
	BANKSEL	    SSPCON2
	BSF	    SSPCON2,0		;Generate Start Condition
    START_READ_DONE_1
	BTFSC	    SSPCON2,0
	GOTO	    START_READ_DONE_1	;Wait Until Start Condition Completes
	BANKSEL	    ADDRESS_W
	MOVFW	    ADDRESS_W
	BANKSEL	    SSPBUF
	MOVWF	    SSPBUF		;Send Peripheral Address (Write)
    ADDRESS_SENT_R_1
	BANKSEL	    SSPSTAT
	BTFSC	    SSPSTAT,0		
	GOTO	    ADDRESS_SENT_R_1	;Wait Until Buffer is Clear (Address is Sent)
	CALL	    I2C_IDLE		;Ensure the I2C BUS is idle
	BANKSEL	    SSPCON2
	BTFSC	    SSPCON2,6		;Was an Acknowledge Received?
	GOTO	    BAD_COND		;Acknowledge Not Received
	BANKSEL	    PIR1
	BCF	    PIR1,3		;Clear SSP interrupt Flag
	BANKSEL	    DATA_TX_1
	MOVFW	    DATA_TX_1
	BANKSEL	    SSPBUF
	MOVWF	    SSPBUF		;Send First Data Byte
    DATA_1_SENT_R
	BANKSEL	    SSPSTAT
	BTFSC	    SSPSTAT,0
	GOTO	    DATA_1_SENT_R	;Wait Until Buffer is Clear (Data is Sent)
	CALL	    I2C_IDLE		;Ensure the I2C BUS is idle
	BANKSEL	    SSPCON2
	BTFSC	    SSPCON2,6		;Was an Acknowledge Received?
	GOTO	    BAD_COND		;Acknowledge Not Received
	CALL	    I2C_IDLE		;Ensure the I2C BUS is idle
	BANKSEL	    SSPCON2
	BSF	    SSPCON2,0		;Generate Repeated Start Condition
    START_READ_DONE_2
	BTFSC	    SSPCON2,0
	GOTO	    START_READ_DONE_2	;Wait Until Repeated Start Condition Completes
	BANKSEL	    PIR1
	BCF	    PIR1,3		;Clear SSP interrupt Flag
	BANKSEL	    ADDRESS_R
	MOVFW	    ADDRESS_R
	BANKSEL	    SSPBUF
	MOVWF	    SSPBUF		;Send Peripheral Address (Read)
    ADDRESS_SENT_R_2
	BANKSEL	    SSPSTAT
	BTFSC	    SSPSTAT,0		
	GOTO	    ADDRESS_SENT_R_2	;Wait Until Buffer is Clear (Address is Sent)
	CALL	    I2C_IDLE		;Ensure the I2C BUS is idle
	BANKSEL	    SSPCON2
	BTFSC	    SSPCON2,6		;Was an Acknowledge Received?
	GOTO	    BAD_COND		;Acknowledge Not Received
	BANKSEL	    SSPCON2
	BSF	    SSPCON2,3		;Enable Receive Mode
	BANKSEL	    PIR1
	BCF	    PIR1,3		;Clear SSP interrupt Flag
	BANKSEL	    SSPBUF
	MOVFW	    SSPBUF		;Clear SSPBUF Buffer
	CALL	    I2C_IDLE		;Ensure the I2C BUS is idle
	BANKSEL	    SSPCON2
	BSF	    SSPCON2,5		;Set Acknowledge Data to NACK
	BSF	    SSPCON2,4		;Send NACK (Stop Data Receive)
    NACK_DONE
	BTFSC	    SSPCON2,4
	GOTO	    NACK_DONE		;Wait Until NACK Completes
	BANKSEL	    SSPCON2
	BCF	    SSPCON2,3		;Disable Receive Mode
	BANKSEL	    SSPCON2
	BSF	    SSPCON2,2		;Generate Stop Condition
    READ_STOP_DONE_2
	BTFSC	    SSPCON2,2
	GOTO	    READ_STOP_DONE_2	;Wait Until Stop Condition Completes
	BANKSEL	    SSPBUF
	MOVFW	    SSPBUF
	BANKSEL	    DATA_RECEIVED
	MOVWF	    DATA_RECEIVED	;Save Data Sent By the Peripheral
	RETURN
	
	
    BAD_COND
	BANKSEL	    SSPCON2
	BSF	    SSPCON2,2		;Generate Stop Condition
    BAD_STOP_DONE
	BTFSC	    SSPCON2,2
	GOTO	    BAD_STOP_DONE	;Wait Until Stop Condition Completes
	MOVLW	    H'FF'
	RETURN				;Write Failed.  Return Wif 0xFF in Working Register
	
    I2C_IDLE
	BANKSEL	    SSPCON2
	MOVLW	    H'1F'
	ANDWF	    SSPCON2		;Compare to 0x1F to Test for 5 Busy Conditions
	BANKSEL	    STATUS
	BTFSS	    STATUS,2
	GOTO	    I2C_IDLE		;If any Conditions Still Busy Wait
    CHECK_R_W
	BANKSEL	   SSPSTAT
	BTFSC	   SSPSTAT,2
	GOTO	   CHECK_R_W		;Wait Until  a Transmission is Not in Process
	RETURN				;I2C BUS is Idle Exit Routine
	
	
I2C_RECEIVE
	BANKSEL	    SSPCON1
	BCF	    SSPCON1,4		;Hold Clock
	BANKSEL	    SSPSTAT
	BTFSC	    SSPSTAT,5
	GOTO	    I2C_DATA_RX		;Check if last receive was data or address
ADDRESS_RX
	BANKSEL	    SSPBUF
	MOVFW	    SSPBUF		;Clear Address out of Buffer
	BANKSEL	    I2C_RX_COUNTER
	CLRF	    I2C_RX_COUNTER	;Clear Data Received Counter
	GOTO	    I2C_RECEIVE_END
I2C_DATA_RX
	BANKSEL	    I2C_RX_COUNTER
	MOVLW	    H'00'
	SUBWF	    I2C_RX_COUNTER,0	;Subtract W from F (F-W).  Store in W
	BANKSEL	    STATUS
	BTFSC	    STATUS,2
	GOTO	    FIRST_DATA_BYTE	;Subtraction = 0.  Counter = 0
	BANKSEL	    I2C_RX_COUNTER
	MOVLW	    H'01'
	SUBWF	    I2C_RX_COUNTER,0	;Subtract W from F (F-W).  Store in W
	BANKSEL	    STATUS
	BTFSC	    STATUS,2
	GOTO	    SECOND_DATA_BYTE	;Subtraction = 0.  Counter = 1
	BANKSEL	    I2C_RX_COUNTER
	MOVLW	    H'02'
	SUBWF	    I2C_RX_COUNTER,0	;Subtract W from F (F-W).  Store in W
	BANKSEL	    STATUS
	BTFSC	    STATUS,2
	GOTO	    THIRD_DATA_BYTE	;Subtraction = 0.  Counter = 2
	BANKSEL	    I2C_RX_COUNTER
	MOVLW	    H'03'
	SUBWF	    I2C_RX_COUNTER,0	;Subtract W from F (F-W).  Store in W
	BANKSEL	    STATUS
	BTFSC	    STATUS,2
	GOTO	    FOURTH_DATA_BYTE	;Subtraction = 0.  Counter = 3
	GOTO	    I2C_RECEIVE_END	;Not Data 1,2,3, or 4 Exit Routine
FIRST_DATA_BYTE
	BANKSEL	    SSPBUF
	MOVFW	    SSPBUF
	BANKSEL	    JOY1_UD
	MOVWF	    JOY1_UD		;Save First Data Byte as Joystick 1 Up and Down
	GOTO	    I2C_RECEIVE_DATA_END
SECOND_DATA_BYTE
	BANKSEL	    SSPBUF
	MOVFW	    SSPBUF
	BANKSEL	    JOY1_LR
	MOVWF	    JOY1_LR		;Save Second Data Byte as Joystick 1 Left and Right
	GOTO	    I2C_RECEIVE_DATA_END
THIRD_DATA_BYTE
	BANKSEL	    SSPBUF
	MOVFW	    SSPBUF
	BANKSEL	    JOY2_UD
	MOVWF	    JOY2_UD		;Save Third Data Byte as Joystick 2 Up and Down
	GOTO	    I2C_RECEIVE_DATA_END
FOURTH_DATA_BYTE
	BANKSEL	    SSPBUF
	MOVFW	    SSPBUF
	BANKSEL	    JOY2_LR
	MOVWF	    JOY2_LR			;Save Fourth Data Byte as Joystick 2 Left and Right
	BANKSEL	    I2C_RX_COMPLETE
	BSF	    I2C_RX_COMPLETE,0		;Set flag to indicate full data packet has been received
	BANKSEL	    TMR1H
	CLRF	    TMR1H
	CLRF	    TMR1L			;Clear Timer 1 Count For COM Timeout
	GOTO	    I2C_RECEIVE_DATA_END
I2C_RECEIVE_DATA_END
	BANKSEL	    I2C_RX_COUNTER
	INCF	    I2C_RX_COUNTER
I2C_RECEIVE_END
	BANKSEL	    SSPCON1
	BSF	    SSPCON1,4		;Re-enable Clock (stop clock strechting)
	BANKSEL	    PIR1
	BCF	    PIR1,3	    ;Clear MSSP Interrupt Flag
	RETURN
	
	