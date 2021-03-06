/**
 *
 * @authors Saleh Khazaei, Shiva Zamani, Mohammad Bagheri
 * @email saleh.khazaei@gmail.com
  * Copyright:

 Copyright (C) Saleh Khazaei

 This code is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 3, or (at your option)
 any later version.

 This code is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this code; see the file COPYING.  If not, write to
 the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.

 *EndCopyright:
*/

#include <mega32a.h>

#include <alcd_ks0073.h>

#include <delay.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifndef RXB8
	#define RXB8 1
#endif

#ifndef TXB8
	#define TXB8 0
#endif

#ifndef UPE
	#define UPE 2
#endif

#ifndef DOR
	#define DOR 3
#endif

#ifndef FE
	#define FE 4
#endif

#ifndef UDRE
	#define UDRE 5
#endif

#ifndef RXC
	#define RXC 7
#endif

#define FRAMING_ERROR (1<<FE)
#define PARITY_ERROR (1<<UPE)
#define DATA_OVERRUN (1<<DOR)
#define DATA_REGISTER_EMPTY (1<<UDRE)
#define RX_COMPLETE (1<<RXC)

#define F_CPU 16000000
#define BAUDRATE 9600
#define BAUD_PRESCALLER (((F_CPU / (BAUDRATE * 16UL))) - 1)

#define FIRST_ADC_INPUT 0
#define LAST_ADC_INPUT 7
#define ADC_VREF_TYPE 0x20

unsigned char adc_data[8];
char output[12];
char buf;           
int state;
int lcd_backlight;  

unsigned char USART_receive(void){
	while(!(UCSRA & (1<<RXC)));
	return UDR;
}

/* Function to send byte/char */
void USART_send( unsigned char data){
	while(!(UCSRA & (1<<UDRE)));
	UDR = data;
}

/* Send string */
/*
void USART_putstring(char* StringPtr){
	while(*StringPtr != 0x00){
		USART_send(*StringPtr);
	StringPtr++;}
}
*/
// ADC interrupt service routine
// with auto input scanning
interrupt [ADC_INT] void adc_isr(void)
{
	static unsigned char input_index=0;
	// Read the 8 most significant bits
	// of the AD conversion result
	adc_data[input_index]=ADCH;
	// Select next ADC input
	if (++input_index > (LAST_ADC_INPUT-FIRST_ADC_INPUT))
	   input_index=0;
	ADMUX=(FIRST_ADC_INPUT | (ADC_VREF_TYPE & 0xff))+input_index;
	// Delay needed for the stabilization of the ADC input voltage
	delay_us(10);
	// Start the AD conversion
	ADCSRA|=0x40;
}

// External Interrupt 0 service routine
interrupt [EXT_INT0] void ext_int0_isr(void)
{
	// Place your code here
    lcd_backlight = 10;
}
    
// Timer 0 overflow interrupt service routine
void update(void)
{
/*
    // Place your code here
	char str[16];            
    // 8 sensor, 12 output (8 220V, 4 5V)
    // 16 chars
    switch ( state )
    {          
        case 0:
//            sprintf(str,"SSM Smart Home %c",computer_state);       
            break ;
        case 1:
            sprintf(str,"S1:%d,S2:%d,C%c",adc_data[0],adc_data[1],buf);       
            break ;
        case 2:
            sprintf(str,"S3:%d,S4:%d,C%c",adc_data[2],adc_data[3],buf);       
            break ;
        case 3:
            sprintf(str,"S5:%d,S6:%d,C%c",adc_data[4],adc_data[5],buf);       
            break ;
        case 4:
            sprintf(str,"S7:%d,S8:%d,C%c",adc_data[6],adc_data[7],buf);       
            break ;
        case 5:
            sprintf(str,"O0:%d,O1:%d,C%c",output[0],output[1],buf);       
            break ;
        case 6:
            sprintf(str,"O2:%d,O3:%d,C%c",output[2],output[3],buf);       
            break ;
        case 7:
            sprintf(str,"O4:%d,O5:%d,C%c",output[4],output[5],buf);       
            break ;
        case 8:
            sprintf(str,"O6:%d,O7:%d,C%c",output[6],output[7],buf);       
            break ;
    }         
    lcd_clear();                              
    lcd_puts(str);         

    lcd_backlight --;
    if ( lcd_backlight > 0 )
    {
        PORTB.3 = 1;
    }
    else 
    {
        PORTB.3 = 0;       
    }
    */                      
    PORTC.0 = output[0];
    PORTC.1 = output[1];
    PORTC.2 = output[2];
    PORTC.3 = output[3];
    PORTC.4 = output[4];
    PORTC.5 = output[5];
    PORTC.6 = output[6];
    PORTC.7 = output[7];
}                    

// Declare your global variables here
void main(void)
{
    int i;
	// Declare your local variables here
    state = 0;       
    lcd_backlight = 10;         
    for ( i = 0 ; i < 12 ; i ++ )
    {
        output[i] = 0 ;
    }
    

	// Input/Output Ports initialization
	// Port A initialization
	// Func7=In Func6=In Func5=In Func4=In Func3=In Func2=In Func1=In Func0=In 
	// State7=T State6=T State5=T State4=T State3=T State2=T State1=T State0=T 
	PORTA=0x00;
	DDRA=0x00;

	// Port B initialization
	// Func7=Out Func6=Out Func5=Out Func4=Out Func3=Out Func2=Out Func1=Out Func0=Out 
	// State7=0 State6=0 State5=0 State4=0 State3=0 State2=0 State1=0 State0=0 
	PORTB=0x00;
	DDRB=0xFF;

	// Port C initialization
	// Func7=Out Func6=Out Func5=Out Func4=Out Func3=Out Func2=Out Func1=Out Func0=Out 
	// State7=0 State6=0 State5=0 State4=0 State3=0 State2=0 State1=0 State0=0 
	PORTC=0x00;
	DDRC=0xFF;

	// Port D initialization
	// Func7=Out Func6=Out Func5=Out Func4=Out Func3=Out Func2=In Func1=In Func0=In 
	// State7=0 State6=0 State5=0 State4=0 State3=0 State2=P State1=T State0=T 
	PORTD=0x04;
	DDRD=0xF8;

	// Timer/Counter 0 initialization
	// Clock source: System Clock
	// Clock value: 15.625 kHz
	// Mode: Normal top=0xFF
	// OC0 output: Disconnected
	TCCR0=0x00;
	TCNT0=0x00;
	OCR0=0x00;

	// Timer/Counter 1 initialization
	// Clock source: System Clock
	// Clock value: Timer1 Stopped
	// Mode: Normal top=0xFFFF
	// OC1A output: Discon.
	// OC1B output: Discon.
	// Noise Canceler: Off
	// Input Capture on Falling Edge
	// Timer1 Overflow Interrupt: Off
	// Input Capture Interrupt: Off
	// Compare A Match Interrupt: Off
	// Compare B Match Interrupt: Off
	TCCR1A=0x00;
	TCCR1B=0x00;
	TCNT1H=0x00;
	TCNT1L=0x00;
	ICR1H=0x00;
	ICR1L=0x00;
	OCR1AH=0x00;
	OCR1AL=0x00;
	OCR1BH=0x00;
	OCR1BL=0x00;

	// Timer/Counter 2 initialization
	// Clock source: System Clock
	// Clock value: Timer2 Stopped
	// Mode: Normal top=0xFF
	// OC2 output: Disconnected
	ASSR=0x00;
	TCCR2=0x00;
	TCNT2=0x00;
	OCR2=0x00;

	// External Interrupt(s) initialization
	// INT0: On
	// INT0 Mode: Low level
	// INT1: Off
	// INT2: Off
	GICR|=0x40;
	MCUCR=0x00;
	MCUCSR=0x00;
	GIFR=0x40;

	// Timer(s)/Counter(s) Interrupt(s) initialization
	TIMSK=0x00;

	// USART initialization
	// Communication Parameters: 8 Data, 1 Stop, No Parity
	// USART Receiver: On
	// USART Transmitter: On
	// USART Mode: Asynchronous
	// USART Baud Rate: 9600
	UCSRA=0x00;
	UBRRH = (BAUD_PRESCALLER>>8);
	UBRRL = (BAUD_PRESCALLER);
	UCSRB = (1<<RXEN)|(1<<TXEN);
	UCSRC = (1<<UCSZ0)|(1<<UCSZ1)|(1<<URSEL);  
    
	// Analog Comparator initialization
	// Analog Comparator: Off
	// Analog Comparator Input Capture by Timer/Counter 1: Off
	ACSR=0x80;
	SFIOR=0x00;

	// ADC initialization
	// ADC Clock frequency: 750.000 kHz
	// ADC Voltage Reference: AREF pin
	// Only the 8 most significant bits of
	// the AD conversion result are used
	ADMUX=FIRST_ADC_INPUT | (ADC_VREF_TYPE & 0xff);
	ADCSRA=0xCC;
	ADCSR |= (1 << ADSC);

	// SPI initialization
	// SPI disabled
	SPCR=0x00;

	// TWI initialization
	// TWI disabled
	TWCR=0x00;

	// Alphanumeric LCD initialization
	// Connections are specified in the
	// Project|Configure|C Compiler|Libraries|Alphanumeric LCD menu:
	// RS - PORTB Bit 0
	// RD - PORTB Bit 1
	// EN - PORTB Bit 2
	// D4 - PORTB Bit 4
	// D5 - PORTB Bit 5
	// D6 - PORTB Bit 6
	// D7 - PORTB Bit 7
	// Characters/line: 16

	lcd_init(16);
	lcd_puts("Welcome.");
    delay_ms(500);
    
	#asm("sei")
	PORTD.7 = 1 ;
    lcd_clear();
	lcd_puts("Starting System.");
    delay_ms(500);
	while(1)
	{    
        lcd_clear();
    	lcd_puts("Receiving");
        buf = USART_receive();        
        PORTD.7 = 1 - PORTD.7 ;

        // get sensor data 01234567
        if ( buf >= '0' && buf <= '7' )
        {                            
            lcd_clear();
        	lcd_puts("Send sensors data");
            #asm ("cli");                    
            delay_ms(20);    
            USART_send ( adc_data [ buf - '0' ] );
            #asm ("sei");
        }
        // clear output                   
        // abcdefgh
        else if ( buf >= 'a' && buf <= 'h' )
        {                      
            lcd_clear();
        	lcd_puts("Clear output");
            output [ buf - 'a' ] = 0; 
            USART_send( '1' );
        }
        // set output
        else if ( buf >= 'A' && buf <= 'H' )
        {                      
            lcd_clear();
        	lcd_puts("Set output");
            output [ buf - 'A' ] = 1; 
            USART_send( '0' );
        }
        // pull output
        else if ( buf >= '!' && buf <= ')' )
        {
            lcd_clear();
        	lcd_puts("Pull output");
            #asm ("cli");                    
            delay_ms(20);        
            USART_send ( (output[ buf - '!' ] == 0 ? 102 : 153 ) );
            #asm ("sei");
        }
        // ?
        else 
        {
            lcd_clear();
        	lcd_puts("Invalid req");
            USART_send ( '?' );            
        }    
        update();
	}
}

