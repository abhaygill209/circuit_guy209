`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.03.2025 18:55:58
// Design Name: 
// Module Name: imageControl
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

//contains buffer and control for the buffer 
module imageControl #(
    parameter PIXEL_WIDTH = 8,
    parameter LINE_WIDTH = 512,
    parameter BUFFER_COUNT = 4,
    parameter OUTPUT_LINES = 3
)(
    input                                       i_clk,
    input                                       i_rst,
    input [PIXEL_WIDTH-1:0]                     i_pixel_data,
    input                                       i_pixel_data_valid,
    output reg [(OUTPUT_LINES*3*PIXEL_WIDTH)-1:0] o_pixel_data,
    output                                      o_pixel_data_valid,
    output reg                                  o_intr
);

    // Calculate derived parameters
    localparam LINE_BUFFER_WIDTH = 3*PIXEL_WIDTH;
    localparam LINE_ADDR_WIDTH = $clog2(LINE_WIDTH);
    localparam BUFF_SEL_WIDTH = $clog2(BUFFER_COUNT);
    localparam PIXEL_THRESHOLD = OUTPUT_LINES * LINE_WIDTH;

    // State definitions
    localparam IDLE = 1'b0,
               RD_BUFFER = 1'b1;

    // Counters and control signals
    reg [LINE_ADDR_WIDTH-1:0] pixelCounter;
    reg [BUFF_SEL_WIDTH-1:0] currentWrLineBuffer;
    reg [BUFFER_COUNT-1:0] lineBuffDataValid;
    reg [BUFFER_COUNT-1:0] lineBuffRdData;
    reg [BUFF_SEL_WIDTH-1:0] currentRdLineBuffer;
    reg [LINE_ADDR_WIDTH-1:0] rdCounter;
    reg rd_line_buffer;
    reg [$clog2(BUFFER_COUNT*LINE_WIDTH)-1:0] totalPixelCounter;
    reg rdState;

    // Line buffer outputs
    wire [LINE_BUFFER_WIDTH-1:0] lbData [BUFFER_COUNT-1:0];

    // Output data valid assignment
    assign o_pixel_data_valid = rd_line_buffer;

    // Total pixel counter to track buffer fullness
    always @(posedge i_clk) begin
        if (i_rst)
            totalPixelCounter <= 0;
        else begin
            if (i_pixel_data_valid & !rd_line_buffer)
                totalPixelCounter <= totalPixelCounter + 1;
            else if (!i_pixel_data_valid & rd_line_buffer)
                totalPixelCounter <= totalPixelCounter - 1;
            else if (i_pixel_data_valid & rd_line_buffer)
                totalPixelCounter <= totalPixelCounter; // No change when both happening
        end
    end

    // FSM for read control
    always @(posedge i_clk) begin
        if (i_rst) begin
            rdState <= IDLE;
            rd_line_buffer <= 1'b0;
            o_intr <= 1'b0;
        end
        else begin
            case (rdState)
                IDLE: begin
                    o_intr <= 1'b0;
                    if (totalPixelCounter >= PIXEL_THRESHOLD) begin
                        rd_line_buffer <= 1'b1;
                        rdState <= RD_BUFFER;
                    end
                end
                RD_BUFFER: begin
                    if (rdCounter == LINE_WIDTH-1) begin
                        rdState <= IDLE;
                        rd_line_buffer <= 1'b0;
                        o_intr <= 1'b1;
                    end
                end
            endcase
        end
    end
    
    // Write counter for pixel position within line buffer
    always @(posedge i_clk) begin
        if (i_rst)
            pixelCounter <= 0;
        else begin
            if (i_pixel_data_valid)
                pixelCounter <= (pixelCounter == LINE_WIDTH-1) ? 0 : pixelCounter + 1;
        end
    end

    // Control for current write line buffer
    always @(posedge i_clk) begin
        if (i_rst)
            currentWrLineBuffer <= 0;
        else begin
            if (pixelCounter == LINE_WIDTH-1 && i_pixel_data_valid)
                currentWrLineBuffer <= (currentWrLineBuffer == BUFFER_COUNT-1) ? 0 : currentWrLineBuffer + 1;
        end
    end

    // Generate valid signals for line buffers
    always @(*) begin
        lineBuffDataValid = {BUFFER_COUNT{1'b0}};
        lineBuffDataValid[currentWrLineBuffer] = i_pixel_data_valid;
    end

    // Read counter for reading from line buffers
    always @(posedge i_clk) begin
        if (i_rst)
            rdCounter <= 0;
        else begin
            if (rd_line_buffer)
                rdCounter <= (rdCounter == LINE_WIDTH-1) ? 0 : rdCounter + 1;
        end
    end

    // Control for current read line buffer
    always @(posedge i_clk) begin
        if (i_rst)
            currentRdLineBuffer <= 0;
        else begin
            if (rdCounter == LINE_WIDTH-1 && rd_line_buffer)
                currentRdLineBuffer <= (currentRdLineBuffer == BUFFER_COUNT-1) ? 0 : currentRdLineBuffer + 1;
        end
    end

    // Output pixel data based on current read buffer
    always @(*) begin
        case (currentRdLineBuffer)
            0: o_pixel_data = {lbData[2], lbData[1], lbData[0]};
            1: o_pixel_data = {lbData[3], lbData[2], lbData[1]};
            2: o_pixel_data = {lbData[0], lbData[3], lbData[2]};
            3: o_pixel_data = {lbData[1], lbData[0], lbData[3]};
        endcase
    end

    // Read enable signals for line buffers
    always @(*) begin
        lineBuffRdData = {BUFFER_COUNT{1'b0}};
        case (currentRdLineBuffer)
            0: begin
                lineBuffRdData[0] = rd_line_buffer;
                lineBuffRdData[1] = rd_line_buffer;
                lineBuffRdData[2] = rd_line_buffer;
            end
            1: begin
                lineBuffRdData[1] = rd_line_buffer;
                lineBuffRdData[2] = rd_line_buffer;
                lineBuffRdData[3] = rd_line_buffer;
            end
            2: begin
                lineBuffRdData[0] = rd_line_buffer;
                lineBuffRdData[2] = rd_line_buffer;
                lineBuffRdData[3] = rd_line_buffer;
            end
            3: begin
                lineBuffRdData[0] = rd_line_buffer;
                lineBuffRdData[1] = rd_line_buffer;
                lineBuffRdData[3] = rd_line_buffer;
            end
        endcase
    end
    
    // Instantiate line buffers using generate
    genvar i;
    generate
        for (i = 0; i < BUFFER_COUNT; i = i + 1) begin : line_buffers
            lineBuffer #(
                .PIXEL_WIDTH(PIXEL_WIDTH),
                .LINE_WIDTH(LINE_WIDTH)
            ) lB (
                .i_clk(i_clk),
                .i_rst(i_rst),
                .i_data(i_pixel_data),
                .i_data_valid(lineBuffDataValid[i]),
                .o_data(lbData[i]),
                .i_rd_data(lineBuffRdData[i])
            );
        end
    endgenerate
    
endmodule
