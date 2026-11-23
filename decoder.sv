module decoder (
input logic [1:0] Op,
input logic [5:0] Funct,
input logic [3:0] Rd,
output logic [1:0] FlagW,
output logic PCS,
output logic RegW,
output logic MemW,
output logic MemtoReg,
output logic ALUSrc,
output logic [1:0] ImmSrc,
output logic [1:0] RegSrc,
output logic [2:0] ALUControl
);

logic [9:0] controls;
logic Branch, ALUOp;

always_comb begin
case (Op)
2'b00: if (Funct[5]) controls = 10'b00_00_1_0_1_0_0_1; // Data Processing Immediate
       else          controls = 10'b00_00_0_0_1_0_0_1; // Data Processing Register
2'b01: if (Funct[0]) controls = 10'b00_01_1_1_1_0_0_0; // LDR
       else          controls = 10'b10_01_1_0_0_1_0_0; // STR (RegSrc[1] = 1)
2'b10:               controls = 10'b01_10_1_0_0_0_1_0; // B   (RegSrc[0] = 1)
default:             controls = 10'b00_00_0_0_0_0_0_0;
endcase
end

assign {RegSrc, ImmSrc, ALUSrc, MemtoReg, RegW, MemW, Branch, ALUOp} = controls;

always_comb begin
if (ALUOp) begin
case (Funct[4:1])
4'b0100: ALUControl = 3'b000; // ADD
4'b0010: ALUControl = 3'b001; // SUB
4'b0000: ALUControl = 3'b010; // AND
4'b1100: ALUControl = 3'b011; // ORR
4'b1101: ALUControl = 3'b100; // LSL (Shift Left)
4'b1110: ALUControl = 3'b101; // LSR (Shift Right)
default: ALUControl = 3'b000;
endcase

FlagW[1] = Funct[0];  // Cờ n và z
FlagW[0] = Funct[0] & (ALUControl == 3'b000 | ALUControl == 3'b001);  // Cờ c và o
end else begin
            ALUControl = 3'b000; // Cộng tính địa chỉ cho LDR, STR, B
            FlagW      = 2'b00;
        end
    end
assign PCS = ((Rd == 4'd15) & RegW) | Branch;
endmodule