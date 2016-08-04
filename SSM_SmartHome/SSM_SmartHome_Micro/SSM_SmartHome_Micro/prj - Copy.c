/*****************************************************
This program was produced by the
CodeWizardAVR V2.05.3 Standard
Automatic Program Generator
© Copyright 1998-2011 Pavel Haiduc, HP InfoTech s.r.l.
http://www.hpinfotech.com

Project : 
Version : 
Date    : 12/27/2015
Author  : Saleh
Company : GRCG
Comments: 


Chip type               : ATmega32A
Program type            : Application
AVR Core Clock frequency: 12.000000 MHz
Memory model            : Small
External RAM size       : 0
Data Stack size         : 512
*****************************************************/

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

// USART Receiver buffer
#define RX_BUFFER_SIZE 8
char rx_buffer[RX_BUFFER_SIZE];

#if RX_BUFFER_SIZE <= 256
	unsigned char rx_wr_index,rx_rd_index,rx_counter;
#else
	unsigned int rx_wr_index,rx_rd_index,rx_counter;
#endif

// This flag is set on USART Receiver buffer overflow
bit rx_buffer_overflow;

// USART Receiver interrupt service routine
interrupt [USART_RXC] void usart_rx_isr(void)
{
	char status,data;
	char str[16];
	lcd_clear();                              
	lcd_puts("USART Int");
	status=UCSRA;
	data=UDR;
	if ((status & (FRAMING_ERROR | PARITY_ERROR | DATA_OVERRUN))==0)
	{
		rx_buffer[rx_wr_index++]=data;
		#if RX_BUFFER_SIZE == 256
		// special case for receiver buffer size=256
		if (++rx_counter == 0) rx_buffer_overflow=1;
		#else
		if (rx_wr_index == RX_BUFFER_SIZE) rx_wr_index=0;
		if (++rx_counter == RX_BUFFER_SIZE)
		{
			rx_counter=0;
			rx_buffer_overflow=1;
		}
		#endif
	}
	delay_ms(500);
	sprintf(str,"%d,%d,%c",(int)status,(int)data,(char)data);       
	lcd_clear();                              
	lcd_puts(str);
	delay_ms(500);
	lcd_clear();                              
	lcd_puts(rx_buffer);
	delay_ms(500);
}

#ifndef _DEBUG_TERMINAL_IO_
// Get a character from the USART Receiver buffer
#define _ALTERNATE_GETCHAR_
#pragma used+
char getchar(void)
{
	char data;
	while (rx_counter==0);
	data=rx_buffer[rx_rd_index++];
	#if RX_BUFFER_SIZE != 256
		if (rx_rd_index == RX_BUFFER_SIZE) rx_rd_index=0;
	#endif
	#asm("cli")
	--rx_counter;
	#asm("sei")
	return data;
}
#pragma used-
#endif

// USART Transmitter buffer
#define TX_BUFFER_SIZE 8
char tx_buffer[TX_BUFFER_SIZE];

#if TX_BUFFER_SIZE <= 256
	unsigned char tx_wr_index,tx_rd_index,tx_counter;
#else
	unsigned int tx_wr_index,tx_rd_index,tx_counter;
#endif

// USART Transmitter interrupt service routine
interrupt [USART_TXC] void usart_tx_isr(void)
{
	if (tx_counter)
	{
		--tx_counter;
		UDR=tx_buffer[tx_rd_index++];
		#if TX_BUFFER_SIZE != 256
			if (tx_rd_index == TX_BUFFER_SIZE) tx_rd_index=0;
		#endif
	}
}

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
void USART_putstring(char* StringPtr){
	while(*StringPtr != 0x00){
		USART_send(*StringPtr);
	StringPtr++;}
}

#define FIRST_ADC_INPUT 0
#define LAST_ADC_INPUT 7
unsigned char adc_data[LAST_ADC_INPUT-FIRST_ADC_INPUT+1];
#define ADC_VREF_TYPE 0x20

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

    
int state;
char computer_state;
int lcd_backlight;  
char output[12];
// Timer 0 overflow interrupt service routine
interrupt [TIM0_OVF] void timer0_ovf_isr(void)
{
    // Place your code here
	char str[16];            
    // 8 sensor, 12 output (8 220V, 4 5V)
    // 16 chars
    switch ( state )
    {          
        case 0:
            sprintf(str,"SSM Smart Home %c",computer_state);       
            break ;
        case 1:
            sprintf(str,"S1:%d,S2:%d,C%c",adc_data[0],adc_data[1],computer_state);       
            break ;
        case 2:
            sprintf(str,"S3:%d,S4:%d,C%c",adc_data[2],adc_data[3],computer_state);       
            break ;
        case 3:
            sprintf(str,"S5:%d,S6:%d,C%c",adc_data[4],adc_data[5],computer_state);       
            break ;
        case 4:
            sprintf(str,"S7:%d,S8:%d,C%c",adc_data[6],adc_data[7],computer_state);       
            break ;
        case 5:
            sprintf(str,"O0:%d,O1:%d,C%c",output[0],output[1],computer_state);       
            break ;
        case 6:
            sprintf(str,"O2:%d,O3:%d,C%c",output[2],output[3],computer_state);       
            break ;
        case 7:
            sprintf(str,"O4:%d,O5:%d,C%c",output[4],output[5],computer_state);       
            break ;
        case 8:
            sprintf(str,"O6:%d,O7:%d,C%c",output[6],output[7],computer_state);       
            break ;
        case 9:
            sprintf(str,"O8:%d,O9:%d,C%c",output[8],output[9],computer_state);       
            break ;
        case 10:
            sprintf(str,"OA:%d,OB:%d,C%c",output[10],output[11],computer_state);       
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
    
    PORTC.0 = output[0];
    PORTC.1 = output[1];
    PORTC.2 = output[2];
    PORTC.3 = output[3];
    PORTC.4 = output[4];
    PORTC.5 = output[5];
    PORTC.6 = output[6];
    PORTC.7 = output[7];
    PORTD.3 = output[8];
    PORTD.4 = output[9];
    PORTD.5 = output[10];
    PORTD.6 = output[11];
}                    

// External Interrupt 0 service routine
interrupt [EXT_INT0] void ext_int0_isr(void)
{
	// Place your code here
    lcd_backlight = 10;
}

void handshake(void)
{
    int i,idx,j;
    char buf[13];
          
    for (i=0;i<13;i++)
        buf[i] = 0;
        
    i = -1;    
    j = 0;
    
    while ( 1 ) // first shake
    {
        buf[j] = USART_receive();
        j = (j + 1) % 13;
        idx = -1;
        for (i=0;i<7;i++)
        {
            if ( buf[i] == '<' )
            {
                idx = i;
                break; 
            } 
        }        
        if ( idx >= 0 )
        { 
            if ( buf[idx] == '<' &&
                 buf[idx+1] == '?' &&
                 buf[idx+2] == 'S' &&
                 buf[idx+3] == 'H' &&
                 buf[idx+4] == 'L' &&
                 buf[idx+5] == '?' &&
                 buf[idx+6] == '>' )
            {
                break;
            }
        }
        USART_putstring("<?FHL?>");
    }                         
    
    USART_putstring("<?EHL?>");
}

// Declare your global variables here
void main(void)
{
	// Declare your local variables here
    int i,j,idx;
    char inv;
	char buf[13];           
	char bufo[7];           
    char temp[3];

    state = 0;       
    lcd_backlight = 10;
    inv = 0;
    i=j=0;
    for ( i = 0 ; i < 12 ; i ++ )
    {
        output[i] = 0;
    }                          
    computer_state = '0';
    

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
	// Clock value: 11.719 kHz
	// Mode: Normal top=0xFF
	// OC0 output: Disconnected
	TCCR0=0x05;
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
    
	#asm("sei")
    
    computer_state = 'N';
	PORTD.7 = 1 ;
    computer_state = 'F';
	while(1)
	{    
        computer_state = 'R';
        buf[j] = USART_receive();
        j = (j + 1) % 13;

        idx = -1;
        for ( i = 0 ; i < 7 ; i ++ )
        {
            if ( buf[i] == '<' )
            {
                idx = i;
                break; 
            } 
        }        
        if ( idx >= 0 )
        { 
			computer_state = 'S';
			inv = 1;       
            bufo[0] = '<';
            bufo[1] = '?';
            bufo[5] = '?';
            bufo[6] = '>';
            
			if ( buf[idx] == '<' && buf[idx+1] == '?' && buf[idx+6] == '>' && buf[idx+5] == '?' )
			{
				if ( buf[idx+2] == 'S' ) // set output / pull sensor 
				{
					if ( buf[idx+3] == 'E' ) // pull sensor
					{                                      
						sprintf(temp,"%d",adc_data[ buf[idx+4] - '0' ]);

						bufo[2] = temp[0];
						bufo[3] = temp[1];
						bufo[4] = temp[2];
						
						inv = 0;                    
					}
					else if ( buf[idx+3] == 'O' ) // set output
					{            
						if ( buf[idx+4] == 'A' )
							output [ 10 ] = 1;                    
						else if ( buf[idx+4] == 'B' )
							output [ 11 ] = 1;                    
						else
							output [ buf[idx+4] - '0' ] = 1;       
						bufo[2] = 'O';             
						bufo[3] = 'O';             
						bufo[4] = 'K';             

						inv = 0;                    
					}
					else if ( buf[idx+3] == 'H' && buf[idx+3] == 'L' ) // handshake
					{    
						bufo[2] = 'E';             
						bufo[3] = 'H';             
						bufo[4] = 'L';             

						inv = 0;                    
					}
				}
				else if ( buf[idx+2] == 'P' && buf[idx+3] == 'O' ) // pull output
				{
					bufo[2] = 'O';
					bufo[3] = 'O';
					if ( buf[idx+4] == 'A' )
						bufo[4] = (output [ 10 ] == 1 ? 'N' : 'F');                    
					else if ( buf[idx+4] == 'B' )
						bufo[4] = (output [ 11 ] == 1 ? 'N' : 'F');                    
					else          
						bufo[4] = (output [ buf[4] - '0' ] == 1 ? 'N' : 'F');                    

					inv = 0;                    
				}
				else if ( buf[idx+2] == 'C' && buf[idx+3] == 'O' ) // clear output
				{
					if ( buf[idx+4] == 'A' )
					   output [ 10 ] = 0;                    
					else if ( buf[idx+4] == 'B' )
						output [ 11 ] = 0;                    
					else
						output [ buf[idx+4] - '0' ] = 0;                    
					bufo[2] = 'O';             
					bufo[3] = 'O';             
					bufo[4] = 'K';             

					inv = 0;                    
				}
			}
			
			if ( inv == 1 )
			{
				sprintf(bufo,"<?INV?>");                
			}
			
			USART_putstring(bufo);
        }

	}
}

