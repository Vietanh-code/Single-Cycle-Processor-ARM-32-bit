module datapath (
    input  logic        clk,
    input  logic        reset,
    input  logic [1:0]  RegSrc,
    input  logic        RegWrite,
    input  logic [1:0]  Immsrc,
    input  logic        ALUSrc,
    input  logic [2:0]  ALUControl,
    input  logic        MemtoReg,
    input  logic        PCSrc,
    output logic [3:0]  ALUFlags,
    output logic [31:0] PC,
    input  logic [31:0] Instr,
    output logic [31:0] ALUResult,
    output logic [31:0] WriteData,
    input  logic [31:0] ReadData
);
    logic [31:0] PCNext, PCPlus4, PCPlus8;
    logic [31:0] ExtImm, SrcA, SrcB, Result;
    logic [3:0]  RA1, RA2;

    // 1. Cụm cập nhật PC 
    mux2  #(32) pcmux  (.d0(PCPlus4), .d1(Result), .s(PCSrc), .y(PCNext)); // PC'
    flopr #(32) pcreg  (.clk(clk), .reset(reset), .d(PCNext), .q(PC));
    adder #(32) pcadd1 (.a(PC), .b(32'd4), .y(PCPlus4));
    adder #(32) pcadd2 (.a(PCPlus4), .b(32'd4), .y(PCPlus8));

    // 2. Cụm Register File
    mux2 #(4) ra1mux (.d0(Instr[19:16]), .d1(4'd15),         .s(RegSrc[0]), .y(RA1));
    mux2 #(4) ra2mux (.d0(Instr[3:0]),   .d1(Instr[15:12]), .s(RegSrc[1]), .y(RA2));

    register_file rf (
        .clk(clk),
        .we3(RegWrite),
        .ra1(RA1),
        .ra2(RA2),
        .wa3(Instr[15:12]), 
        .wd3(Result),       
        .r15(PCPlus8),      
        .rd1(SrcA),         
        .rd2(WriteData)     
    );

    // 3. Khối Extend 
    extend ext (
        .Instr(Instr[23:0]),
        .Immsrc(Immsrc),
        .ExtImm(ExtImm)
    );

    // 4. Cụm Mux chọn SrcB và khối ALU
    mux2 #(32) srcbmux (
        .d0(WriteData),
        .d1(ExtImm),
        .s(ALUSrc),
        .y(SrcB)
    );

    alu alu_inst (
        .SrcA(SrcA),
        .SrcB(SrcB),
        .ALUControl(ALUControl),
        .ALUResult(ALUResult),
        .ALUFlags(ALUFlags)
    );

    // 5. Bộ Mux chọn Result từ ALUResult (0) hoặc ReadData (1)
    mux2 #(32) resmux (
        .d0(ALUResult),
        .d1(ReadData),
        .s(MemtoReg),
        .y(Result)
    );
endmodule