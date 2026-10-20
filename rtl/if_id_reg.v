module if_id_reg #(parameter WIDTH=32) (
    input clk,
    input en,
    input rst,
    input [WIDTH-1:0] instr_if, pc_if, pcplus4_if,
    output reg[WIDTH-1:0] InstrD, PCD, PCPlus4D
);

always @(posedge clk) begin
    if(rst) begin
        InstrD<=0;
        PCD<=0;
        PCPlus4D<=0;
    end
    else if(en) begin
        InstrD<=instr_if;
        PCD<=pc_if;
        PCPlus4D<=pcplus4_if;
    end
end

endmodule
