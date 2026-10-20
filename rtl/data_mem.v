module data_mem #(parameter DATA_WIDTH=32, ADDR_WIDTH=32, MEM_SIZE=64) (
    input clk,
    input wr_en,
    input [ADDR_WIDTH-1:0] wr_addr,
    input [DATA_WIDTH-1:0] wr_data,
    output [DATA_WIDTH-1:0] rd_data_mem
);

reg [DATA_WIDTH-1:0] data_ram [0:MEM_SIZE-1];

wire [29:0] word_addr=(wr_addr[DATA_WIDTH-1:2]) % MEM_SIZE;

always @(posedge clk) begin
    if(wr_en) begin
        data_ram[word_addr]<=wr_data;
    end
end

assign rd_data_mem=data_ram[word_addr];

endmodule