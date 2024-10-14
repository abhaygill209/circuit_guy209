
// alu.v - ALU module

// module alu #(parameter WIDTH = 32) (
//     input       [WIDTH-1:0] a, b,       // operands
//     input       [3:0] alu_ctrl,         // ALU control
//     input       [2:0] funct3,          // for B-type instr
//     output reg  [WIDTH-1:0] alu_out,    // ALU output   
//     output reg  zero                    // zero flag
// );
// wire [4:0] b5 = b[4:0];

// always @(a, b, alu_ctrl) begin
//     case (alu_ctrl)
//         4'b0000:  alu_out <= a + b;       // ADD
//         4'b0001:  alu_out <= a + ~b + 1;  // SUB
//         4'b0010:  alu_out <= a & b;       // AND
//         4'b0011:  alu_out <= a | b;       // OR
//         4'b0100:  alu_out <= a ^ b;       // XOR
//         4'b0110:  alu_out <= a <<  b[4:0];      //sll,srli
//         4'b0111:  alu_out <= (a >> b5) | ({32{a[WIDTH-1]}} << (32 - b5));      //sra, srai
//         4'b1000:  alu_out <= a >>  b[4:0];      //srl,srli
//         4'b1001:  alu_out <= (a<b)?1:0;   //sltu   
//         4'b0101:  begin                   //SLT
//                      if (a[31] != b[31]) alu_out <= a[31] ? 1 : 0;
//                      else alu_out <= a < b ? 1 : 0;
//                  end
//         default: alu_out = 0;
//     endcase
// end
// always @(*) begin
//     case(funct3)
//         3'b000: zero = (alu_out==32'd0)? 1:0; //beq
//         3'b001: zero = (alu_out!=32'd0)? 1:0; //bne 
//         3'b100: zero = (alu_out==32'd1)? 1:0; //blt
//         3'b101: zero = (alu_out==32'd0)? 1:0; //bge 
//         3'b110: zero = (alu_out==32'd1)? 1:0; //bltu
//         3'b111: zero = (alu_out==32'd0)? 1:0; //bgen
//         default: zero = 0;
//     endcase
// end

// endmodule

module alu #(parameter WIDTH = 32) (
    input       [WIDTH-1:0] a, b,       // operands
    input       [3:0] alu_ctrl,         // ALU control
    input       [2:0] funct3,          // for B-type instr
    output reg  [WIDTH-1:0] alu_out,    // ALU output   
    output reg  zero                    // zero flag
);
wire [4:0] b5 = b[4:0];

always @(*) begin
    case (alu_ctrl)
        4'b0000:  alu_out = a + b;          // ADD
        4'b0001:  alu_out = a + ~b + 1;     // SUB
        4'b0010:  alu_out = a & b;          // AND
        4'b0011:  alu_out = a | b;          // OR
        4'b0100:  alu_out = a ^ b;          // XOR
        4'b0110:  alu_out = a << b5;        // SLL
        4'b0111:  alu_out = ($signed(a) >>> b5);     // SRA (arithmetic right shift)
        4'b1000:  alu_out = a >> b5;        // SRL (logical right shift)
        4'b1001:  alu_out = (a < b) ? 1 : 0; // SLTU
        4'b0101:  begin                     // SLT
                     if (a[31] != b[31]) alu_out = a[31] ? 1 : 0;
                     else alu_out = (a < b) ? 1 : 0;
                 end
        default: alu_out = 0;
    endcase
end

always @(*) begin
    case(funct3)
        3'b000: zero = (alu_out == 32'd0) ? 1 : 0;  // BEQ
        3'b001: zero = (alu_out != 32'd0) ? 1 : 0;  // BNE
        3'b100: zero = (alu_out == 32'd1) ? 1 : 0;  // BLT
        3'b101: zero = (alu_out == 32'd0) ? 1 : 0;  // BGE
        3'b110: zero = (alu_out == 32'd1) ? 1 : 0;  // BLTU
        3'b111: zero = (alu_out == 32'd0) ? 1 : 0;  // BGEU
        default: zero = 0;
    endcase
end

endmodule