
// main_decoder.v - logic for main decoder

module main_decoder (
    input  [6:0] op,
    input  [2:0] funct3,
    output [2:0] ResultSrc,
    output       MemWrite, Branch, ALUSrc,
    output       RegWrite, Jump, Jalr,
    output [1:0] ImmSrc,
    output [1:0] ALUOp
);

reg [12:0] controls;

always @(*) begin
    casez (op)
        // RegWrite_ImmSrc_ALUSrc_MemWrite_ResultSrc_Branch_ALUOp_Jump_Jalr
        7'b0000011: begin
            if (funct3 == 3'b101)
                controls = 13'b1_00_1_0_100_0_00_0_0; //special case for lhu
            else 
                controls = 13'b1_00_1_0_001_0_00_0_0; // lw
        end
        7'b0100011: controls = 13'b0_01_1_1_000_0_00_0_0; // sw
        7'b0110011: begin
            if((funct3 == 3'b101)||(funct3 == 3'b001)) 
                controls = 13'b1_00_1_0_000_0_10_0_0; // sll,sra,srl
            else
                controls = 13'b1_xx_0_0_000_0_10_0_0; // R–type
        end 
        7'b1100011: controls = 13'b0_10_0_0_000_1_11_0_0; // beq will change it for all the B-type instructions 
        7'b0010011: controls = 13'b1_00_1_0_000_0_10_0_0; // I–type ALU                 
        7'b1101111: controls = 13'b1_11_0_0_010_0_00_1_0; // jal
        7'b1100111: controls = 13'b1_00_1_0_010_0_00_0_1; // jalr
        7'b0?10111: controls = 13'b1_xx_x_0_011_0_xx_0_0; // lui and auipc 
        7'b0010011: controls = 13'b1_xx_x_0_101_0_xx_0_0; // srai
        default:    controls = 13'bx_xx_x_x_xxx_x_xx_x_x; // ???
    endcase
end

assign {RegWrite, ImmSrc, ALUSrc, MemWrite, ResultSrc, Branch, ALUOp, Jump, Jalr} = controls;

endmodule

