module alu( 
input logic [31:0] SrcA,
input logic [31:0] SrcB,
input logic [2:0] ALUControl,
output logic [31:0] ALUResult,
output logic [3:0] ALUFlags
);
logic neg, zero, carry, overflow;
logic [31:0] condinvb;
logic [32:0] sum;

assign condinvb = ALUControl[0]  ? ~SrcB : SrcB;
assign sum = SrcA + condinvb + ALUControl[0];

always_comb begin 
case (ALUControl)
3'b000: ALUResult = sum[31:0];  // ADD
3'b001: ALUResult = sum[31:0];  // SUB
3'b010: ALUResult = SrcA & SrcB;  // AND
3'b011: ALUResult = SrcA | SrcB;  // OR
3'b100: ALUResult = SrcA << SrcB[4:0];  //LSL (Left shift 5 bit)
3'b101: ALUResult = SrcA >> SrcB[4:0];  //LSR (Right shift 5 bit)
default: ALUResult = 32'b0;
endcase 
end

assign neg = ALUResult[31];
assign zero = (ALUResult == 32'b00);
assign carry = ( (ALUControl[2:1] == 2'b00) & sum[32]); 
assign overflow = ((ALUControl[2:1] == 2'b00) & ~(SrcA[31] ^ SrcB[31]) & (SrcA[31] ^ sum[31])); 
assign ALUFlags = {neg, zero, carry, overflow};

endmodule
