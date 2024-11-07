// EcoMender Bot : Task 2A - UART Receiver
/*
Instructions
-------------------
Students are not allowed to make any changes in the Module declaration.

This file is used to receive UART Rx datacount packet from receiver line and then update the rx_msg and rx_complete datacount lines.

Recommended Quartus Version : 20.1
The submitted project file must be 20.1 compatible as the evaluation will be done on Quartus Prime Lite 20.1.

Warning: The error due to compatibility will not be entertained.
-------------------
*/

/*
Module UART Receiver

Baudrate: 230400 

Input:  clk_3125 - 3125 KHz clock
        rx      - UART Receiver

Output: rx_msg - received input message of 8-bit width
        rx_parity - received parity bit
        rx_complete - successful uart packet processed signal
*/

// module declaration
module uart_rx(
    input clk_3125,
    input rx,
    output reg [7:0] rx_msg,
    output reg rx_parity,
    output reg rx_complete
    );

//////////////////DO NOT MAKE ANY CHANGES ABOVE THIS LINE//////////////////
/*
# Team ID:          eYRC##1781
# Theme:            EB
# Author List:      Arnav Pahuja
# Filename:         uart_rx.v
# File Description: Implementation of UART reciever module
# Global variables: count[3:0], datacount[3:0], result[8:0]
*/
reg [3:0] count;
reg [3:0] datacount;
reg [8:0] result;

initial begin
    rx_msg = 0;
	 rx_parity = 0;
    rx_complete = 0;
	 count = 4'b0000;
	 datacount = 4'b0000;
	 result = 8'b00000000;
end

always @ (posedge clk_3125) begin
/*
Purpose:
---
This block runs at internal operating frequency of reciever, ie, 3125kHz.
Looks for the bit sent by transmitter for approx 13 clk cycles, since buad rate is 230400.
count is used to count these clock cycles, datacount to keep track of which bit in the data packet we are reading,
result to temporarily store the bits interpreted and then pass them to output rx_msg in the end.
*/
if(datacount == 4'b0000 && !rx) begin

	rx_complete <= 0;//switch off complete signal
	count <= count + 4'b0001;
	
	if((count > 4) && (rx != 0) || (count == 13)) begin
//if the bit changes due to sync issue before finishing count, move to next bit, 4 taken to compare with stable value
		datacount <= datacount + 4'b0001;
		count <= 0;
	end

end
else if (datacount == 4'b0001) begin
	
	result[0] <= rx;
	count <= count + 4'b0001;
	if((count > 4) && (rx != result[0]) || (count == 13)) begin
		result[0] <= result[0];
		datacount <= datacount + 4'b0001;
		count <= 0;
	end

end
else if (datacount == 4'b0010) begin

	result[1] <= rx;
	count <= count + 4'b0001;
	if((count > 4) && (rx != result[1]) || (count == 13)) begin
		result[1] <= result[1];
		datacount <= datacount + 4'b0001;
		count <= 0;
	end
end
else if (datacount == 4'b0011) begin
	result[2] <= rx;
	count <= count + 4'b0001;
	if((count > 4) && (rx != result[2]) || (count == 13)) begin
		result[2] <= result[2];
		datacount <= datacount + 4'b0001;
		count <= 0;
	end

end
else if (datacount == 4'b0100) begin

	result[3] <= rx;
	count <= count + 4'b0001;
	if((count > 4) && (rx != result[3]) || (count == 13)) begin
		result[3] <= result[3];
		datacount <= datacount + 4'b0001;
		count <= 0;
	end

end
else if (datacount == 4'b0101) begin

	result[4] <= rx;
	count <= count + 4'b0001;
	if((count > 4) && (rx != result[4]) || (count == 13)) begin
		result[4] <= result[4];
		datacount <= datacount + 4'b0001;
		count <= 0;
	end

end
else if (datacount == 4'b0110) begin

	result[5] <= rx;
	count <= count + 4'b0001;
	if((count > 4) && (rx != result[5]) || (count == 13)) begin
		result[5] <= result[5];
		datacount <= datacount + 4'b0001;
		count <= 0;
	end

end
else if (datacount == 4'b0111) begin

	result[6] <= rx;
	count <= count + 4'b0001;
	if((count > 4) && (rx != result[6]) || (count == 13)) begin
		result[6] <= result[6];
		datacount <= datacount + 4'b0001;
		count <= 0;
	end

end
else if (datacount == 4'b1000) begin

	result[7] <= rx;
	count <= count + 4'b0001;
	if((count > 4) && (rx != result[7]) || (count == 13)) begin
		result[7] <= result[7];
		datacount <= datacount + 4'b0001;
		count <= 0;
	end

end
else if (datacount == 4'b1001) begin

	count <= count + 4'b0001;
	if (count > 0) result[8] <= rx;//not storing the first value of rx received because it records high of previous bit
	
	if((count > 4) && (rx != result[8]) || (count == 13)) begin
		datacount <= datacount + 4'b0001;
		count <= 0;
		//Parity check
		if((result[0] + result[1]+ result[2]+ result[3]+ result[4]+ result[5]+ result[6]+ result[7] + result[8])%3'b010==3'b001) begin
			result <= 9'b111111100;//ASCII of '?' with parity set to 1 randomly
			result[8] <= rx;//set parity back to original
		end
	end
	
end
else if (datacount == 4'b1010) begin

	count <= count + 4'b0001;
	if((count > 4) && (rx != 1) || count == 14) begin
		datacount <= 4'b0000;
		count <= 1;// Taking an extra clock cycle here(14), thus set count to one
		
		rx_parity <= result[8];
		rx_msg[0] <= result[7];
		rx_msg[1] <= result[6];
		rx_msg[2] <= result[5];
		rx_msg[3] <= result[4];
		rx_msg[4] <= result[3];
		rx_msg[5] <= result[2];
		rx_msg[6] <= result[1];
		rx_msg[7] <= result[0];
		rx_complete <= rx;

	end
end
else count = 0;
end
// Add your code here....

//////////////////DO NOT MAKE ANY CHANGES BELOW THIS LINE//////////////////


endmodule

