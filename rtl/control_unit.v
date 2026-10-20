module control_unit (
    input wire [6:0] op, // opcode
    input wire [2:0] funct3, 
    input wire funct7b5,
    output wire RegWrite, 
    output wire [1:0] ResultSrc, // choose from ALU, Mem, PC+4
    output wire MemWrite,
    output wire Jump,
    output wire Branch,
    output wire [3:0] ALUControl, // control operation performed by ALU
    output wire ALUSrc, // I vs R in ALU
    output wire [1:0] ImmSrc // pick from different immidiate formats
);

wire [1:0] ALUOp; // type of instruction 

main_decoder md ( // connect
    .op(op),
    .ResultSrc(ResultSrc),
    .MemWrite(MemWrite),
    .Branch(Branch),
    .ALUSrc(ALUSrc),
    .RegWrite(RegWrite),
    .Jump(Jump),
    .ImmSrc(ImmSrc),
    .ALUOp(ALUOp)
);

alu_decoder ad ( // connect
    .ALUOp(ALUOp),
    .funct3(funct3),
    .opb5(op[5]), // R-type vs I-type
    .funct7b5(funct7b5), // ADD vs SUB and SRL vs SRA
    .ALUControl(ALUControl) 
);

endmodule