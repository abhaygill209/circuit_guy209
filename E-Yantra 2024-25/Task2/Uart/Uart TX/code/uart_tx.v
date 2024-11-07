module uart_tx(
    input clk_3125,
    input parity_type, 
    input tx_start,
    input [7:0] data,
    output reg tx, 
    output reg tx_done
);

//////////////////DO NOT MAKE ANY CHANGES ABOVE THIS LINE//////////////////

parameter IDLE = 1'b1;  
parameter START_BIT = 1'b0; 
parameter STOP_BIT = 1'b1;  
parameter DATA_BITS = 8;    
parameter CLK_CYCLES_PER_BIT = 13; 

reg [3:0] bit_count = 0;  // To track bit (0-7) 
reg [3:0] clk_count = 0;  // To count clock cycles for each bit
reg parity_bit;           // Parity bit to be calculated
reg transmitting;         // Flag to indicate transmission in progress


initial begin
 
    tx = IDLE;        
    tx_done = 0;      
    transmitting = 0; 
end


always @(posedge clk_3125) begin
        tx_done<=0;
    if ( !transmitting) begin
	      tx = START_BIT;        
        
        transmitting <= 1;
        bit_count <= 0;         
        clk_count <= 0;                  
        parity_bit <= parity_type ? ~^data : ^data; // Compute parity bit
        tx_done <= 0;
    end
    else if (transmitting) begin
        if (clk_count < CLK_CYCLES_PER_BIT) begin
            // Increment clock cycle count
				
            clk_count <= clk_count + 1;
			if(bit_count==4'd10 && clk_count==12) begin
				tx_done <= 1;   end       // Set done flag	      
				
				if(bit_count==4'd11) begin
				tx <=IDLE;
			   transmitting <= 0;     // Transmission complete            
				clk_count<= 14; end
        end
        else begin

            
            clk_count <= 0;
           
            
            case (bit_count)
                4'd0: tx <= data[7]; 
                4'd1: tx <= data[6]; 
                4'd2: tx <= data[5]; 
                4'd3: tx <= data[4]; 
                4'd4: tx <= data[3]; 
                4'd5: tx <= data[2]; 
                4'd6: tx <= data[1]; 
                4'd7: tx <= data[0]; 
                4'd8: tx <= parity_bit;
                4'd9: tx <= STOP_BIT;  
                
            endcase
				  
				 bit_count <= bit_count + 1;
        end
    end
end

//////////////////DO NOT MAKE ANY CHANGES BELOW THIS LINE//////////////////
endmodule
