
// datapath.v
module datapath (
    input         clk, reset,
    input [2:0]   ResultSrc,
    input         PCSrc, ALUSrc,
    input         RegWrite,
    input [1:0]   ImmSrc,
    input [3:0]   ALUControl,
    input         Jalr,
    output        Zero,
    output [31:0] PC,
    input  [31:0] Instr,
    output [31:0] Mem_WrAddr, Mem_WrData,
    input  [31:0] ReadData,
    output [31:0] Result
);

wire [31:0] PCNext, PCPlus4, PCTarget, PCJalr;
wire [31:0] ImmExt, SrcA, SrcB, WriteData, ALUResult;
wire [31:0] UResult, auipc, ZeroExt; 

// next PC logic
reset_ff #(32) pcreg(clk, reset, PCJalr, PC);
adder          pcadd4(PC, 32'd4, PCPlus4);
adder          pcaddbranch(PC, ImmExt, PCTarget);
mux2 #(32)     pcmux(PCPlus4, PCTarget, PCSrc, PCNext);
mux2 #(32)     jalrmux(PCNext, ALUResult, Jalr, PCJalr);

// register file logic
reg_file       rf (clk, RegWrite, Instr[19:15], Instr[24:20], Instr[11:7], Result, SrcA, WriteData);
imm_extend     ext (Instr[31:7], ImmSrc, ImmExt);

// ALU logic
mux2 #(32)     srcbmux(WriteData, ImmExt, ALUSrc, SrcB);
alu            alu (SrcA, SrcB, ALUControl, Instr[14:12], ALUResult, Zero);
mux6 #(32)     resultmux(ALUResult, ReadData, PCPlus4, UResult, ZeroExt, ResultSrc, Result); //changed

//U-Type Instruction
adder          auipc_adder({Instr[31:12], 12'b0}, PC, auipc);
mux2 #(32)     Utype(auipc, {Instr[31:12], 12'b0}, Instr[5], UResult); 

assign ZeroExt    = {16'b0, ReadData[15:0]}; 
assign Mem_WrData = WriteData;
assign Mem_WrAddr = ALUResult;

endmodule

