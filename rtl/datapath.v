module datapath (
    input wire clk,
    input wire rst,
    output wire [31:0] PCF,
    input wire [31:0] InstrF,
    output wire MemWriteM,
    output wire [31:0] ALUResultM, WriteDataM,
    input wire [31:0] ReadDataM
);

// hazard unit

wire StallF, StallD, FlushD, FlushE;
wire [1:0] ForwardAE, ForwardBE;
wire [2:0] funct3E;

/* hazard_unit hu (
    .StallF(StallF),
    .Rs1D(InstrD[19:15]),
    .Rs2D(InstrD[24:20]),
    .StallD(StallD),
    .FlushD(FlushD),
    .Rs1E(Rs1E),
    .Rs2E(Rs2E),
    .RdE(RdE),
    .PCSrcE(PCSrcE),
    .ResultSrcE(ResultSrcE),
    .ForwardAE(ForwardAE),
    .ForwardBE(ForwardBE),
    .FlushE(FlushE),
    .RdM(RdM),
    .RegWriteM(RegWriteW_M),
    .RdW(RdW),
    .RegWriteW(RegWriteW)
); */

// fetch

wire [31:0] PCPlus4F, PCNextF;
wire PCSrcE;
wire [31:0] PCTargetE;

mux2 #(32) pcmux (
    .sel(PCSrcE),
    .a(PCPlus4F),
    .b(PCTargetE),
    .out(PCNextF)
);

pc_reg reg_pc (
    .clk(clk),
    .rst(rst),
    .en(~StallF),
    .PCF_(PCNextF),
    .PCF(PCF)
);

assign PCPlus4F=PCF+32'd4;

wire [31:0] InstrD, PCD, PCPlus4D;

if_id_reg reg_if_id (
    .clk(clk),
    .rst(rst|FlushD),
    .en(~StallD),
    .instr_if(InstrF),
    .pc_if(PCF),
    .pcplus4_if(PCPlus4F),
    .InstrD(InstrD),
    .PCD(PCD),
    .PCPlus4D(PCPlus4D)
);

// decode

wire RegWriteD, MemWriteD, JumpD, BranchD, ALUSrcD;
wire [1:0] ResultSrcD, ImmSrcD;
wire [3:0] ALUControlD;

control_unit ctrl (
    .op(InstrD[6:0]),
    .funct3(InstrD[14:12]),
    .funct7b5(InstrD[30]),
    .RegWrite(RegWriteD),
    .ResultSrc(ResultSrcD),
    .MemWrite(MemWriteD),
    .Jump(JumpD),
    .Branch(BranchD),
    .ALUControl(ALUControlD),
    .ALUSrc(ALUSrcD),
    .ImmSrc(ImmSrcD)
);

wire [31:0] RD1D, RD2D, ExtImmD;
wire RegWriteW;
wire [4:0] RdW;
wire [31:0] ResultW;

reg_file rf (
    .clk(clk),
    .wr_en(RegWriteW),
    .rd_addr1(InstrD[19:15]),
    .rd_addr2(InstrD[24:20]),
    .wr_addr(RdW),
    .wr_data(ResultW),
    .rd_data1(RD1D),
    .rd_data2(RD2D)
);

imm_extend ext_imm (
    .instr(InstrD[31:7]), 
    .immsrc(ImmSrcD), 
    .immext(ExtImmD)
);

wire [31:0] PCE, PCPlus4E, ExtImmE, RD1E, RD2E;
wire [4:0] Rs1E, Rs2E, RdE;
wire RegWriteE, MemWriteE, JumpE, BranchE, ALUSrcE;
wire [1:0] ResultSrcE;
wire [3:0] ALUControlE;

id_ex_reg reg_id_ex (
    .clk(clk),
    .clr(rst|FlushE),

    .PCD(PCD),
    .PCPlus4D(PCPlus4D),
    .ExtImmD(ExtImmD),
    .Rs1D(InstrD[19:15]),
    .Rs2D(InstrD[24:20]),
    .RdD(InstrD[11:7]),
    .RD1D(RD1D),
    .RD2D(RD2D),
    .ResultSrcD(ResultSrcD),
    .RegWriteD(RegWriteD),
    .MemWriteD(MemWriteD),
    .JumpD(JumpD),
    .BranchD(BranchD),
    .ALUSrcD(ALUSrcD),
    .ALUControlD(ALUControlD),
    .funct3D(InstrD[14:12]),

    .PCE(PCE),
    .PCPlus4E(PCPlus4E),
    .ExtImmE(ExtImmE),
    .Rs1E(Rs1E),
    .Rs2E(Rs2E),
    .RdE(RdE),
    .RD1E(RD1E),
    .RD2E(RD2E),
    
    .ResultSrcE(ResultSrcE),
    .RegWriteE(RegWriteE),
    .MemWriteE(MemWriteE),
    .JumpE(JumpE),
    .BranchE(BranchE),
    .ALUSrcE(ALUSrcE),
    .ALUControlE(ALUControlE),
    .funct3E(funct3E)
);

// execute

wire [31:0] SrcAE, WriteDataE, SrcBE, ALUResultE;
wire ZeroE;

mux3 #(32) fa_mux ( // select ALU input A
    .sel(ForwardAE),
    .a(RD1E),
    .b(ResultW),
    .c(ALUResultM),
    .out(SrcAE)
);


mux3 #(32) fb_mux ( // rs2 correct value
    .sel(ForwardBE),
    .a(RD2E),
    .b(ResultW),
    .c(ALUResultM),
    .out(WriteDataE)
);

mux2 #(32) srcbmux ( // select ALU input B
    .sel(ALUSrcE),
    .a(WriteDataE),
    .b(ExtImmE),
    .out(SrcBE)
);

alu alu_inst (
    .a(SrcAE),
    .b(SrcBE),
    .alu_ctrl(ALUControlE),
    .alu_out(ALUResultE),
    .Zero(ZeroE)
);

assign PCTargetE=PCE+ExtImmE;

wire BranchTake;

assign BranchTake=
    (funct3E==3'b000) ? ZeroE: // BEQ
    (funct3E==3'b001) ? ~ZeroE: // BNE
    (funct3E==3'b100) ? ALUResultE[31]: // BLT
    (funct3E==3'b101) ? ~ALUResultE[31]: // BGE
    1'b0;

assign PCSrcE=(BranchE & ZeroE) | JumpE;

wire [31:0] PCPlus4M;
wire [4:0] RdM;
wire [1:0] ResultSrcM;
wire RegWriteM;

ex_mem_reg reg_ex_mem (
    .clk(clk), .rst(rst),
    .RegWriteE(RegWriteE),
    .MemWriteE(MemWriteE),
    .ResultSrcE(ResultSrcE),
    .alu_res_in(ALUResultE),
    .WriteDataE(WriteDataE),
    .PCPlus4E(PCPlus4E),
    .RdE(RdE),

    .RegWriteM(RegWriteM),
    .MemWriteM(MemWriteM),
    .ResultSrcM(ResultSrcM),
    .ALUResultM(ALUResultM),
    .WriteDataM(WriteDataM),
    .PCPlus4M(PCPlus4M),
    .RdM(RdM)
);

wire RegWriteW_M;
wire [31:0] ALUResultW, ReadDataW, PCPlus4W;
wire [1:0] ResultSrcW;

mem_wb_reg reg_wb_mem (
    .clk(clk), .rst(rst),
    .RegWriteM(RegWriteM),
    .ResultSrcM(ResultSrcM),
    .ALUResultM(ALUResultM),
    .ReadDataM(ReadDataM),
    .PCPlus4M(PCPlus4M),
    .RdM(RdM),

    .RegWriteW(RegWriteW),
    .ResultSrcW(ResultSrcW),
    .ALUResultW(ALUResultW),
    .ReadDataW(ReadDataW),
    .PCPlus4W(PCPlus4W),
    .RdW(RdW)
);

mux3 #(32) resultmux (
    .sel(ResultSrcW),
    .a(ALUResultW),
    .b(ReadDataW),
    .c(PCPlus4W),
    .out(ResultW)
);

hazard_unit hu (
    .StallF(StallF),
    .Rs1D(InstrD[19:15]),
    .Rs2D(InstrD[24:20]),
    .StallD(StallD),
    .FlushD(FlushD),
    .Rs1E(Rs1E),
    .Rs2E(Rs2E),
    .RdE(RdE),
    .PCSrcE(PCSrcE),
    .ResultSrcE(ResultSrcE),
    .ForwardAE(ForwardAE),
    .ForwardBE(ForwardBE),
    .FlushE(FlushE),
    .RdM(RdM),
    .RegWriteM(RegWriteM),
    .RdW(RdW),
    .RegWriteW(RegWriteW)
);

endmodule
