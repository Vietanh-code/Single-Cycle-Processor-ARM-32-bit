`timescale 1ns/1ps
module top_tb;
    logic clk, reset;
    logic [31:0] WriteData, ALUResult;
    logic MemWrite;

    top dut (
        .clk(clk), 
        .reset(reset), 
        .WriteData(WriteData), 
        .ALUResult(ALUResult), 
        .MemWrite(MemWrite)
    );

    always begin
        clk = 1'b1; #5;
        clk = 1'b0; #5;
    end

    initial begin
        reset = 1'b1; #22;
        reset = 1'b0; 
    end

    always @(negedge clk) begin
        if (!reset) begin
            if (dut.PC === 32'h0000_002C) begin
                assert (ALUResult === 32'h0000_0034);
            end

            assert (dut.PC !== 32'h0000_0030);

            if (MemWrite) begin
                if (dut.PC === 32'h0000_0024) begin
                    assert (ALUResult === 32'd96 && WriteData === 32'd31);
                end
                else if (dut.PC === 32'h0000_0038) begin
                    assert (ALUResult === 32'd100 && WriteData === 32'd32);
                    $stop;
                end
            end
        end
    end
endmodule