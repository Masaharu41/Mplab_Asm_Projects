/************************************************
 * File:   Template.c
 * Author: jackel
 *************************************************
 * Created on November 8, 2024, 9:28 AM
 * version: 1.0
 */
// PIC16F1788 Configuration Bit Settings

// 'C' source line config statements

// CONFIG1
#pragma config FOSC = INTOSC    // Oscillator Selection (INTOSC oscillator: I/O function on CLKIN pin)
#pragma config WDTE = ON        // Watchdog Timer Enable (WDT enabled)
#pragma config PWRTE = OFF      // Power-up Timer Enable (PWRT disabled)
#pragma config MCLRE = ON       // MCLR Pin Function Select (MCLR/VPP pin function is MCLR)
#pragma config CP = OFF         // Flash Program Memory Code Protection (Program memory code protection is disabled)
#pragma config CPD = OFF        // Data Memory Code Protection (Data memory code protection is disabled)
#pragma config BOREN = OFF      // Brown-out Reset Enable (Brown-out Reset disabled)
#pragma config CLKOUTEN = OFF   // Clock Out Enable (CLKOUT function is disabled. I/O or oscillator function on the CLKOUT pin)
#pragma config IESO = OFF       // Internal/External Switchover (Internal/External Switchover mode is disabled)
#pragma config FCMEN = ON       // Fail-Safe Clock Monitor Enable (Fail-Safe Clock Monitor is enabled)

// CONFIG2
#pragma config WRT = OFF        // Flash Memory Self-Write Protection (Write protection off)
#pragma config VCAPEN = OFF     // Voltage Regulator Capacitor Enable bit (Vcap functionality is disabled on RA6.)
#pragma config PLLEN = ON       // PLL Enable (4x PLL enabled)
#pragma config STVREN = ON      // Stack Overflow/Underflow Reset Enable (Stack Overflow or Underflow will cause a Reset)
#pragma config BORV = LO        // Brown-out Reset Voltage Selection (Brown-out Reset Voltage (Vbor), low trip point selected.)
#pragma config LPBOR = OFF      // Low Power Brown-Out Reset Enable Bit (Low power brown-out is disabled)
#pragma config LVP = OFF        // Low-Voltage Programming Enable (High-voltage on MCLR/VPP must be used for programming)

// #pragma config statements should precede project file includes.
// Use project enums instead of #define for ON and OFF.

#include <xc.h>
#include <stdbool.h>
#include <stdlib.h>



/*
 * 
 */
short int button; // Define global integer variable

void Setup()
{
    // OSCILATOR SETUP
    OSCCONbits.SPLLEN   = 1; // ENABLE PLL
    OSCCONbits.IRCF3    = 1; //   
    OSCCONbits.IRCF2    = 1; // INTERNAL OSCILLATOR TO 4MHZ
    OSCCONbits.IRCF1    = 0; //
    OSCCONbits.IRCF0    = 1; //
    OSCCONbits.SCS1     = 1; // set internal oscillator

/* I-O Port ***************************
PORTA SETUP*/
    LATA    = 0x00;
    TRISA   = 0xF0; // SET PORTA AS <RA7:RA4> IN AND <RA3:RA0> OUT 
    PORTA   = 0x00; 
    ANSELA  = 0x00; 
// PORTC SETUP
    ANSELC  = 0x00;
    TRISC   = 0x00; // SET PORTC AS OUTPUT
    PORTC   = 0x23; // SET DEFAULT OUT TO 0
// GENERAL REGISTERS
    PIE1    = 0x00;
    PIE2    = 0x00;
    CCP1CON = 0x00;
    CCP2CON = 0x00;
    T1CON   = 0x00;
    T2CON   = 0x00;
}

void Keypad_Check()
{

    /*Test the keypad on PORTA with testing each row
     when a valid statement is found an integer is placed
     into the global variable for the key's int value
     infinite while loop until the code is broken*/

    asm("CLRF PORTA");
    RA0 = 1;
    if (PORTAbits.RA4 == 1)
    {
        button = 48;
        return;
    }
    else if (PORTAbits.RA5 == 1)
    {
        button = 49;
        return;
    }
    else if (PORTAbits.RA6 == 1)
    {
        button = 50;
        return;
    }
    else if (PORTAbits.RA7 == 1)
    {
        button = 51;
        return;
    }
    else 
    {
        button = 35;
    }
 
    /*Returns a dummy case unless a valid case has been found*/
    asm("CLRF PORTA");
    RA1 = 1;
    // if a value was found the function is bailed out otherwise test again
    // test row 2
    if (PORTAbits.RA4  == 1)
    {
        button = 52;
        return;
    }
    else if (PORTAbits.RA5 == 1)
    {
        button = 53;
        return;
    }
    else if (PORTAbits.RA6 == 1)
    {
        button = 54;
        return;
    }
    else if (PORTAbits.RA7 == 1)
    {
        button = 55;
        return;
    }
    else 
    {
        button = 35;
    }
    //
    asm("CLRF PORTA");
    RA2 = 1;
     // test row 3
    if (PORTAbits.RA4  == 1)
    {
        button = 56;
        return;
    }
    else if (PORTAbits.RA5 == 1)
    {
        button = 57;
        return;
    }
    else if (PORTAbits.RA6 == 1)
    {
        button = 65;
        return;
    }
    else if (PORTAbits.RA7 == 1)
    {
        button = 66;
        return;
    }
    else 
    {
        button = 35;
    }
    //
    asm("CLRF PORTA");
    RA3 = 1;
     // test row 4
    if (PORTAbits.RA4  == 1)
    {
        button = 67;
        return;
    }
    else if (PORTAbits.RA5 == 1)
    {
        button = 68;
        return;
    }
    else if (PORTAbits.RA6 == 1)
    {
        button = 69;
        return;
    }
    else if (PORTAbits.RA7 == 1)
    {
        button = 70;
        return;
    }
    else 
    {
        button = 35;
        asm("CLRF PORTA");
        return;
    }
//
    
}

char Convert_To_Chr(int temp)
/*return the value that is the ascii character of the integer
 that is brought in. this then returns the value within the function*/
{
    char Key;
        Key = (char)temp;
        return Key;   
}

void Write_To_Port(char write)
{
    PORTC = write;
}

int main(int argc, char** argv) {
    Setup();
    while (1 == 1)
    {   
        Keypad_Check();
        Write_To_Port(Convert_To_Chr(button));
    }
   
            
    return (EXIT_SUCCESS);
}

