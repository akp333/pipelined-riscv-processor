module instr_mem #(parameter DATA_WIDTH=32, ADDR_WIDTH=32, MEM_SIZE=512) (
    input [ADDR_WIDTH-1:0] instr_addr,
    output [DATA_WIDTH-1:0] instr
);

reg [DATA_WIDTH-1:0] instr_ram [0:MEM_SIZE-1];

integer i;

initial begin
    $readmemh("rv32i_sort.mem", instr_ram);
end

assign instr=instr_ram[instr_addr[31:2]];

endmodule