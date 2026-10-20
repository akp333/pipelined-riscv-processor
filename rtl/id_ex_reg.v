module id_ex_reg #(parameter WIDTH=32) (
    input clk, clr, rst,
    input [WIDTH-1:0] PCD, PCPlus4D, ExtImmD,
    input [4:0] Rs1D, Rs2D, RdD,
    input [WIDTH-1:0] RD1D, RD2D,
    input [1:0] ResultSrcD,
    input RegWriteD, MemWriteD, JumpD, BranchD, ALUSrcD,
    input [3:0] ALUControlD,
    input [2:0] funct3D,
    output reg [2:0] funct3E,
    output reg [WIDTH-1:0] PCE, PCPlus4E, ExtImmE,
    output reg [4:0] Rs1E, Rs2E, RdE,
    output reg [WIDTH-1:0] RD1E, RD2E,
    output reg [1:0] ResultSrcE,
    output reg RegWriteE, MemWriteE, JumpE, BranchE, ALUSrcE,
    output reg [3:0] ALUControlE
);

always @(posedge clk) begin
    if(clr) begin
        PCE<=0; PCPlus4E<=0; ExtImmE<=0;
        Rs1E<=0; Rs2E<=0; RdE<=0; RD1E<=0; RD2E<=0;
        ResultSrcE<=0; RegWriteE<=0; MemWriteE<=0; JumpE<=0; BranchE<=0; ALUSrcE<=0;
        ALUControlE<=0; funct3E<=0;
    end
    else begin
        PCE<=PCD; PCPlus4E<=PCPlus4D; ExtImmE<=ExtImmD;
        Rs1E<=Rs1D; Rs2E<=Rs2D; RdE<=RdD; RD1E<=RD1D; RD2E<=RD2D;
        ResultSrcE<=ResultSrcD; RegWriteE<=RegWriteD; MemWriteE<=MemWriteD; JumpE<=JumpD; BranchE<=BranchD; ALUSrcE<=ALUSrcD;
        ALUControlE<=ALUControlD; funct3E<=funct3D;
    end
end 

endmodule