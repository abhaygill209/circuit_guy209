// mux4.v - logic for 4-to-1 multiplexer

module mux6 #(parameter WIDTH = 8) (
    input       [WIDTH-1:0] d0, d1, d2, d3, d4,
    input       [2:0] sel,
    output reg  [WIDTH-1:0] y
);

always @(*) begin
    case(sel)
        3'b000: y = d0;  // Select data[0]
        3'b001: y = d1;  // Select data[1]
        3'b010: y = d2;  // Select data[2]
        3'b011: y = d3;  // Select data[3]
        3'b100: y = d4;  // Select data[4]
        default: y= d0;  // Default case
    endcase
end

endmodule