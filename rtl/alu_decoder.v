module alu_decoder (
    input wire [1:0] ALUOp, // type of instruction
    input wire opb5, // bit 5 opcode I vs R
    input wire funct7b5, // bit 5 funct 7 ADD vs SUB and SRL vs SRA
    input wire [2:0] funct3, // final peice of info for setting ALUControl
    output reg [3:0] ALUControl // determines operation of ALU
);

always @(*) begin
    case(ALUOp)
        2'b00: ALUControl=4'b0000; // lw/sw or jump(does not matter) use ADD
        2'b01: ALUControl=4'b0001; // branch: subtract to check for Zero
        2'b10: begin // R-type or I-type
            case(funct3)
                3'b000: begin
                    if(opb5 && funct7b5) ALUControl=4'b0001; //SUB
                    else ALUControl=4'b0000; //ADD
                end
                3'b010: ALUControl=4'b0100; //SLT, SLTI
                3'b110: ALUControl=4'b0011; //OR, ORI
                3'b111: ALUControl=4'b0010; //AND, ANDI
                3'b011: ALUControl=4'b0101; //SLTU, SLTIU
                3'b001: ALUControl=4'b0111; //SLL, SLLI
                3'b101: begin
                    if(funct7b5) ALUControl=4'b1001; //SRA, SRAI
                    else ALUControl=4'b1000; //SRL, SRLI
                end
                default: ALUControl=4'b0000; // Default to ADD
            endcase
        end
        default: ALUControl=4'b0000;
    endcase
end

endmodule
        
    