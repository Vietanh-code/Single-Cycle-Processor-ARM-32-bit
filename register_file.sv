module register_file (
input logic clk,
input logic reset,
input logic we3,  // RegWrite
input logic [3:0] ra1, ra2, wa3,  
input logic [31:0] wd3, r15,  // wd3 (Result), r15 (PCPlus8)
output logic [31:0] rd1, rd2
);
logic [31:0] rf[14:0];

always_ff @(posedge clk or posedge reset) begin
if (reset) begin
for (int i = 0; i < 15; i++)
rf[i] <= 32'b0;
end else if (we3 && (wa3 != 4'd15)) 
rf[wa3] <= wd3;
end

// Đọc bất đồng bộ, nếu địa chỉ là 15 thì trả về thanh ghi r15
assign rd1 = (ra1 == 4'd15) ? r15 : rf[ra1];
assign rd2 = (ra2 == 4'd15) ? r15 : rf[ra2];

endmodule
