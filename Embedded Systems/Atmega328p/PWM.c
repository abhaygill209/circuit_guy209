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

volatile uint16_t pwm = 0 ; //setting up a variable for duty cycle. 

//Interrupt for increasing duty cycle 
ISR(INT0_vect){
	if (pwm >= 0xFA)
		pwm = 0xFF;
	else
		pwm = pwm + 10;
}

//Interrupt fro decreasing Duty Cycle
ISR(INT1_vect){
	if (pwm <= 0x05)
	pwm = 0x00;
	else
	pwm = pwm - 10;
}


int main(void)
{
	//configuring the ports 
	DDRD  |= (1 << DDD6) ;
	
	//configuring interrupts for INT0 and INT1
	EICRA = 0x0A;
	EIMSK = 0x03;
	
	//configuring registers for pwm timer
	TCCR0A |= (1<<WGM00)|(1<<WGM01)|(1<<COM0A1);
	TCCR0B |= (0<<WGM10)|(1<<CS00);
	
	sei();  //enabling global interrupts 
	
	while(1)
	{ 
		OCR0A = pwm;
	}
  
}


