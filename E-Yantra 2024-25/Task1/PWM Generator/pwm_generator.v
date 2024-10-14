// EcoMender Bot : Task 1A : PWM Generator
/*
Instructions
-------------------
Students are not allowed to make any changes in the Module declaration.
This file is used to design a module which will scale down the 100KHz Clock Frequency to 500Hz and perform Pulse Width Modulation on it.

Recommended Quartus Version : 20.1
The submitted project file must be 20.1 compatible as the evaluation will be done on Quartus Prime Lite 20.1.

Warning: The error due to compatibility will not be entertained.
-------------------
*/

//PWM Generator
//Inputs : clk_1MHz, pulse_width
//Output : clk_500Hz, pwm_signal

module pwm_generator(
    input clk_1MHz,
    input [3:0] pulse_width,
    output reg clk_500Hz, pwm_signal
);

initial begin
    clk_500Hz = 1; pwm_signal = 1;
end

//////////////////DO NOT MAKE ANY CHANGES ABOVE THIS LINE//////////////////
reg [10:0] counter_pwm   = 11'd0;	//counter for pwm

always @(posedge clk_1MHz) begin 
	
	//500hz clock cycle   
	if (counter_pwm == 11'd0) begin
		clk_500Hz <= 1;			    //toggles value of clock 
	end 
	else if (counter_pwm == 11'd1000) clk_500Hz <= 0; 

   // PWM_Signals 
   if (counter_pwm < (11'd100 * pulse_width)) begin
			pwm_signal <= 1;      // PWM signal high
     end else begin
			pwm_signal <= 0;      // PWM signal low
     end

   // Increment the counter or reset when counter_pwm = 2000;
     if (counter_pwm == 11'd1999) begin
         counter_pwm <= 11'd0; 					 // Reset counter at the end of the period
     end else begin
         counter_pwm <= counter_pwm + 11'd1;  // Increment counter
     end
    
end

//////////////////DO NOT MAKE ANY CHANGES BELOW THIS LINE//////////////////

endmodule
