module sys_wrap (
    input clk,
    input rst
);

wire [31:0] PCF, InstrF;
wire [31:0] ALUResultM, WriteDataM, ReadDataM;
wire MemWriteM;

datapath cpu_core (
    .clk(clk),
    .rst(rst),
    .PCF(PCF),
    .InstrF(InstrF),
    .MemWriteM(MemWriteM),
    .ALUResultM(ALUResultM),
    .WriteDataM(WriteDataM),
    .ReadDataM(ReadDataM)
);

instr_mem imem (
    .instr_addr(PCF),
    .instr(InstrF)
);

data_mem dmem (
    .clk(clk),
    .wr_en(MemWriteM),
    .wr_addr(ALUResultM),
    .wr_data(WriteDataM),
    .rd_data_mem(ReadDataM)
); 

endmodule