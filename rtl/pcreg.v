module pc_reg #(parameter WIDTH = 32) (
    input clk,
    input rst,
    input [WIDTH-1:0] PCF_,
    input en,
    output reg [WIDTH-1:0] PCF
);

always @(posedge clk) begin
    if(rst) PCF<=0;
    else if(en) PCF<=PCF_;
end

endmodule