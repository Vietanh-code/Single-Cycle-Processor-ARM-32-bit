module instruction_memory (
input logic [31:0] a,
output logic [31:0] rd
);
logic [31:0] RAM[63:0];

initial begin
RAM[0]  = 32'hE2800000; // 0x00: ADD R0, R0, #0   (Khởi tạo R0 = 0 nếu regfile reset = 0)
RAM[1]  = 32'hE2802005; // 0x04: ADD R2, R0, #5   (R2 = 5)
RAM[2]  = 32'hE280300C; // 0x08: ADD R3, R0, #12  (R3 = 12)
RAM[3]  = 32'hE2437009; // 0x0C: SUB R7, R3, #9   (R7 = 12 - 9 = 3)
RAM[4]  = 32'hE1874002; // 0x10: ORR R4, R7, R2   (R4 = 3 | 5 = 7)
RAM[5]  = 32'hE0035004; // 0x14: AND R5, R3, R4   (R5 = 12 & 7 = 4)
RAM[6]  = 32'hE0855004; // 0x18: ADD R5, R5, R4   (R5 = 4 + 7 = 11)
RAM[7]  = 32'hE3A26002; // 0x1C: LSL R6, R2, #2   (SHIFT: R6 = R2 << 2 = 5 << 2 = 20)
RAM[8]  = 32'hE0855006; // 0x20: ADD R5, R5, R6   (R5 = 11 + 20 = 31)
RAM[9]  = 32'hE5805060; // 0x24: STR R5, [R0, #96]  (Mem[96] = 31)
RAM[10] = 32'hE5908060; // 0x28: LDR R8, [R0, #96]  (R8 = Mem[96] = 31)
RAM[11] = 32'hEA000000; // 0x2C: B end            (Nhảy qua 0x30 tới 0x34)
RAM[12] = 32'hE2808063; // 0x30: ADD R8, R0, #99  (Bị bỏ qua)
RAM[13] = 32'hE2888001; // 0x34: ADD R8, R8, #1   (R8 = 31 + 1 = 32)
RAM[14] = 32'hE5808064; // 0x38: STR R8, [R0, #100] (Mem[100] = 32)

end
assign rd = RAM[a[31:2]];

endmodule

