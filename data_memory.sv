module data_memory (
input logic clk,
input logic we,
input logic [31:0] a,
input logic [31:0] wd, // Dữ liệu 32 bit cần ghi vào RAM
output logic [31:0] rd  // Dữ liệu 32 bit đọc ra từ RAM gửi về CPU
);
logic [31:0] RAM[63:0];

assign rd = RAM[a[31:2]];

always_ff @(posedge clk) 
if(we) 
RAM[a[31:2]] <= wd;

endmodule
