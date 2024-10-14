// EcoMender Bot : Task 1A : Frequency Scaling
/*
Instructions
-------------------
Students are not allowed to make any changes in the Module declaration.
This file is used to design a module which will scale down the 50MHz Clock Frequency to 1MHz.

Recommended Quartus Version : 20.1
The submitted project file must be 20.1 compatible as the evaluation will be done on Quartus Prime Lite 20.1.

Warning: The error due to compatibility will not be entertained.
-------------------
*/

//Frequency Scaling
//Inputs : clk_50MHz
//Output : clk_1MHz


module frequency_scaler (
    input clk_50MHz,
    output reg clk_1MHz
);

initial begin
    clk_1MHz = 1;
end

reg [5:0] counter = 6'b111111;

always @(posedge clk_50MHz) begin 
	
	//when counter value reaches 24 value gets toggled  
	if (counter == 6'd24) begin
		clk_1MHz <= ~clk_1MHz;	//toggles value of clock 
		counter  <= 6'd0;			//sets counter value to 0
	end 
	else counter <= counter + 6'd1;  //Counter 
	
end

endmodule
