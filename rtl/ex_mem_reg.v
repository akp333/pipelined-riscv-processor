module ex_mem_reg #(parameter WIDTH=32) (
    input clk, rst,
    input [WIDTH-1:0] alu_res_in, WriteDataE, PCPlus4E,
    input [4:0] RdE,
    input RegWriteE, MemWriteE,
    input [1:0] ResultSrcE,
    output reg [WIDTH-1:0] ALUResultM, WriteDataM, PCPlus4M,
    output reg [4:0] RdM,
    output reg RegWriteM, MemWriteM,
    output reg [1:0] ResultSrcM
);

always @(posedge clk) begin
    if(rst) begin
        ALUResultM<=0;
        WriteDataM<=0;
        PCPlus4M<=0;
        RdM<=0;
        RegWriteM<=0;
        MemWriteM<=0;
        ResultSrcM<=0;
    end
    else begin
        ALUResultM<=alu_res_in;
        WriteDataM<=WriteDataE;
        PCPlus4M<=PCPlus4E;
        RdM<=RdE;
        RegWriteM<=RegWriteE;
        MemWriteM<=MemWriteE;
        ResultSrcM<=ResultSrcE;
    end
end

endmodule