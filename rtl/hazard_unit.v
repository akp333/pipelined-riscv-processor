module hazard_unit(
    // Fetch Stage
    output reg StallF,
    // Decode Stage
    input wire [4:0] Rs1D,
    input wire [4:0] Rs2D,
    output reg StallD,
    output reg FlushD,
    // Execute Stage
    input wire [4:0] Rs1E,
    input wire [4:0] Rs2E,
    input wire [4:0] RdE,
    input wire PCSrcE, // 1 if Branch Taken or Jump
    input wire [1:0] ResultSrcE, // 2'b01 is Load Word
    output reg [1:0] ForwardAE,
    output reg [1:0] ForwardBE,
    output reg FlushE,
    // Memory Stage
    input wire [4:0] RdM,
    input wire RegWriteM,
    // Writeback Stage
    input wire [4:0] RdW,
    input wire RegWriteW
);

// for load hazard
wire lwStall;
// If the instruction in Execute is a Load (ResultSrcE == 01), 
// and its destination matches either source register currently in Decode
assign lwStall = (ResultSrcE == 2'b01) && ((Rs1D == RdE) || (Rs2D == RdE));

always @(*) begin
    // data forwarding
    // ForwardAE logic (ALU Input A)
    if ((RegWriteM) && (RdM != 0) && (RdM == Rs1E)) begin
        ForwardAE = 2'b10; // Forward from Memory Stage
    end else if ((RegWriteW) && (RdW != 0) && (RdW == Rs1E)) begin
        ForwardAE = 2'b01; // Forward from Writeback Stage
    end else begin
        ForwardAE = 2'b00; // No hazard, use normal Register File
    end
    // ForwardBE logic (ALU Input B)
    if ((RegWriteM) && (RdM != 0) && (RdM == Rs2E)) begin
        ForwardBE = 2'b10; // Forward from Memory Stage
    end else if ((RegWriteW) && (RdW != 0) && (RdW == Rs2E)) begin
        ForwardBE = 2'b01; // Forward from Writeback Stage
    end else begin
        ForwardBE = 2'b00; // No hazard, use normal Register File
    end
    // stalling & flushing
    // STALL: Freeze Fetch and Decode stages to let the Load instruction finish
    StallF = lwStall; 
    StallD = lwStall; 
    // FLUSH: Wipe instructions out of the pipeline
    // If a branch is taken, the instruction in Decode is wrong
    FlushD = PCSrcE; 
    // We must flush Execute if a branch is taken OR if we are stalling.
    // (Stalling Decode stops new data from entering Execute, so we insert a '0' bubble)
    FlushE = lwStall | PCSrcE; 
end
endmodule