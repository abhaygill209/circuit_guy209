`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.03.2025 15:00:24
// Design Name: 
// Module Name: lineBuffer
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module lineBuffer #(
    parameter PIXEL_WIDTH = 8,
    parameter LINE_WIDTH = 512
)(
    input                              i_clk,
    input                              i_rst,
    input      [PIXEL_WIDTH-1:0]       i_data,
    input                              i_data_valid,
    output reg [(3*PIXEL_WIDTH)-1:0]   o_data,
    input                              i_rd_data
);
    // Local parameters
    localparam ADDR_WIDTH = $clog2(LINE_WIDTH);
    
    // Memory and control signals
    reg [PIXEL_WIDTH-1:0] line_memory [LINE_WIDTH-1:0];
    reg [ADDR_WIDTH-1:0] wr_addr;
    reg [ADDR_WIDTH-1:0] rd_addr;
    
    // Write address control
    always @(posedge i_clk) begin
        if (i_rst)
            wr_addr <= 0;
        else if (i_data_valid)
            wr_addr <= (wr_addr == LINE_WIDTH-1) ? 0 : wr_addr + 1;
    end
    
    // Write data to memory
    always @(posedge i_clk) begin
        if (i_data_valid)
            line_memory[wr_addr] <= i_data;
    end
    
    // Read address control
    always @(posedge i_clk) begin
        if (i_rst)
            rd_addr <= 0;
        else if (i_rd_data)
            rd_addr <= (rd_addr == LINE_WIDTH-1) ? 0 : rd_addr + 1;
    end
    
    // Output data (3 consecutive pixels)
    always @(posedge i_clk) begin
        if (i_rst)
            o_data <= 0;
        else if (i_rd_data) begin
            o_data <= {
                line_memory[(rd_addr + 2) % LINE_WIDTH],
                line_memory[(rd_addr + 1) % LINE_WIDTH],
                line_memory[rd_addr]
            };
        end
    end
    
endmodule
