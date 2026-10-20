module mem_wb_reg #(parameter WIDTH=32) (
    input clk, rst,
    input [WIDTH-1:0] ALUResultM, ReadDataM, PCPlus4M,
    input [4:0] RdM,
    input RegWriteM,
    input [1:0] ResultSrcM,
    output reg [1:0] ResultSrcW,
    output reg RegWriteW,
    output reg [WIDTH-1:0] ALUResultW, ReadDataW, PCPlus4W,
    output reg [4:0] RdW
);

always @(posedge clk) begin
    if(rst) begin
        ALUResultW<=0;
        ReadDataW<=0;
        PCPlus4W<=0;
        RdW<=0;
        RegWriteW<=0;
        ResultSrcW<=0;
    end
    else begin
        ALUResultW<=ALUResultM;
        ReadDataW<=ReadDataM;
        PCPlus4W<=PCPlus4M;
        RdW<=RdM;
        RegWriteW<=RegWriteM;
        ResultSrcW<=ResultSrcM;
    end
end

endmodule
