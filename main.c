/*
 * test.c
 *
 * Created: 22-09-2024 16:39:41
 * Author : HP
 */ 

#define F_CPU 16000000 
#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>

volatile uint16_t pwm = 0 ;

ISR(INT0_vect){
	if (pwm >= 0xFA)
		pwm = 0xFF;
	else
		pwm = pwm + 10;
}
ISR(INT1_vect){
	if (pwm <= 0x05)
	pwm = 0x00;
	else
	pwm = pwm - 10;
}


int main(void)
{
	/* Replace with your application code */
	DDRB  = 0xFF;
	PORTB = 0x00;
	DDRD  = 0b01000000;
	PORTD = 0b01000000;
	
	//configuring interrupts for int0 and int1
	EICRA = 0x0A;
	EIMSK = 0x03;
	
	//configuring the timer
	TCCR0A = (1<<WGM00)|(1<<WGM01)|(1<<COM0A1);
	TCCR0B = (0<<WGM10)|(1<<CS00);
	

	
	sei();
	while(1)
	{ 
		//Giving a compare value
		OCR0A = pwm;
	}
}


