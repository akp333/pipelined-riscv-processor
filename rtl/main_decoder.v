module main_decoder(
    input wire [6:0] op,
    output reg [1:0] ResultSrc,
    output reg MemWrite,
    output reg Branch,
    output reg ALUSrc,
    output reg RegWrite,
    output reg Jump,
    output reg [1:0] ImmSrc,
    output reg [1:0] ALUOp
);

always @(*) begin
    RegWrite=1'b0;
    ImmSrc=2'b00;
    ALUSrc=1'b0;
    MemWrite=1'b0;
    ResultSrc=2'b00;
    Branch=1'b0;
    Jump=1'b0;
    ALUOp=2'b00;

    case(op) 
        // lw
        7'b0000011: begin
            RegWrite=1'b1;
            ALUSrc=1'b1;
            ResultSrc=2'b01;
        end
        // sw
        7'b0100011: begin
            MemWrite=1'b1;
            ALUSrc=1'b1;
            ImmSrc=2'b01;
        end
        // R-type
        7'b0110011: begin
            RegWrite=1'b1;
            ALUOp=2'b10;
        end
        // I-type
        7'b0010011: begin
            RegWrite=1'b1;
            ALUSrc=1'b1;
            ALUOp=2'b10;
        end
        // Branch
        7'b1100011: begin
            Branch=1'b1;
            ImmSrc=2'b10;
            ALUOp=2'b01;
        end
        // Jump
        7'b1101111: begin
            Jump=1'b1;
            RegWrite=1'b1;
            ImmSrc=2'b11;
            ResultSrc=2'b10;
        end
    endcase
end

endmodule



