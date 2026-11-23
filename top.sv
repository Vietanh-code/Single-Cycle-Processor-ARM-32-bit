module top (
    input  logic        clk,
    input  logic        reset,
    output logic [31:0] WriteData,
    output logic [31:0] ALUResult,
    output logic        MemWrite
);
    // Toàn bộ các dây tín hiệu 
    logic [31:0] PCNext, PC, Instr, PCPlus4, PCPlus8;
    logic [31:0] ExtImm, SrcA, SrcB, ReadData, Result;
    logic [3:0]  RA1, RA2, ALUFlags;
    logic        RegWrite, ALUSrc, MemtoReg, PCSrc;
    logic [1:0]  RegSrc, ImmSrc;
    logic [2:0]  ALUControl;

	     // 1. Cụm PC và Instruction Memory 
    mux2  #(32) pcmux  (.d0(PCPlus4), .d1(Result), .s(PCSrc), .y(PCNext));
    flopr #(32) pcreg  (.clk(clk), .reset(reset), .d(PCNext), .q(PC));
    adder #(32) pcadd1 (.a(PC), .b(32'd4), .y(PCPlus4));
    adder #(32) pcadd2 (.a(PCPlus4), .b(32'd4), .y(PCPlus8));

    instruction_memory imem_inst (
        .a(PC),
        .rd(Instr)
    );
	 
	 // 2. Cụm Mux RA1, RA2, Register File và Extend 
    mux2 #(4) ra1mux (.d0(Instr[19:16]), .d1(4'd15),         .s(RegSrc[0]), .y(RA1));
    mux2 #(4) ra2mux (.d0(Instr[3:0]),   .d1(Instr[15:12]), .s(RegSrc[1]), .y(RA2));

    register_file Register_File (
        .clk(clk),
        .reset(reset),
        .we3(RegWrite),
        .ra1(RA1),
        .ra2(RA2),
        .wa3(Instr[15:12]),
        .wd3(Result),
        .r15(PCPlus8),
        .rd1(SrcA),
        .rd2(WriteData)
    );

    extend Extend_Unit (
        .Instr(Instr[23:0]),
        .ImmSrc(ImmSrc),
        .ExtImm(ExtImm)
    );
	 
	 
    // 3. Khối Control Unit 
    controller Control_Unit (
        .clk(clk),
        .reset(reset),
        .Instr(Instr[31:12]),
        .ALUFlags(ALUFlags),
        .RegSrc(RegSrc),
        .RegWrite(RegWrite),
        .ImmSrc(ImmSrc),
        .ALUSrc(ALUSrc),
        .ALUControl(ALUControl),
        .MemWrite(MemWrite),
        .MemtoReg(MemtoReg),
        .PCSrc(PCSrc)
    );



    // 4. Cụm Mux SrcB và ALU
    mux2 #(32) srcbmux (
        .d0(WriteData),
        .d1(ExtImm),
        .s(ALUSrc),
        .y(SrcB)
    );

    alu ALU_Unit (
        .SrcA(SrcA),
        .SrcB(SrcB),
        .ALUControl(ALUControl),
        .ALUResult(ALUResult),
        .ALUFlags(ALUFlags)
    );

    // 5. Cụm Data Memory và Mux Result 
    data_memory dmem_inst (
        .clk(clk),
        .we(MemWrite),
        .a(ALUResult),
        .wd(WriteData),
        .rd(ReadData)
    );

    mux2 #(32) resmux (
        .d0(ALUResult),
        .d1(ReadData),
        .s(MemtoReg),
        .y(Result)
    );

endmodule