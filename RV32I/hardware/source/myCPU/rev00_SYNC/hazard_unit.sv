// Detects and resolves data/control hazards via forwarding, stall, and flush signals.
// Forwarding encoding: 2'b00=no forward, 2'b01=from WB, 2'b10=from MEM
module hazard_unit(
    input       [4:0]   RA1D,
    input       [4:0]   RA2D,
    input       [4:0]   WAE,
    input       [1:0]   ResultSrcE,
    input               RegWriteW,
    input               RegWriteE,
    input       [1:0]   PCSrcE,

    input       [4:0]   RA1E,
    input       [4:0]   RA2E,
    input       [4:0]   WAM,
    input               RegWriteM,

    input       [4:0]   WAW,
    output  reg [1:0]   ForwardAD,
    output  reg [1:0]   ForwardBD,
    output  reg [1:0]   ForwardAE,
    output  reg [1:0]   ForwardBE,
    output  reg         Stall,
    output  reg         Flush_IF_ID,
    output  reg         Flush_ID_EX
);

    // ID-stage forwarding: resolve RAW hazards for branch operands in ID
    always @(*) begin
        if (((RA1D == WAM) && RegWriteM) && (RA1D != 5'd0)) begin
            ForwardAD = 2'b10;  // MEM -> ID
        end else if (((RA1D == WAW) && RegWriteW) && (RA1D != 5'd0)) begin
            ForwardAD = 2'b01;  // WB -> ID
        end else begin
            ForwardAD = 2'b00;
        end
    end

    always @(*) begin
        if (((RA2D == WAM) && RegWriteM) && (RA2D != 5'd0)) begin
            ForwardBD = 2'b10;  // MEM -> ID
        end else if (((RA2D == WAW) && RegWriteW) && (RA2D != 5'd0)) begin
            ForwardBD = 2'b01;  // WB -> ID
        end else begin
            ForwardBD = 2'b00;
        end
    end

    // EX-stage forwarding: resolve RAW hazards for ALU source operands
    always @(*) begin
        if (((RA1E == WAM) && RegWriteM) && (RA1E != 5'd0)) begin
            ForwardAE = 2'b10;
        end else if (((RA1E == WAW) && RegWriteW) && (RA1E != 5'd0)) begin
            ForwardAE = 2'b01;
        end else
            ForwardAE = 2'b00;
    end

    always @(*) begin
        if (((RA2E == WAM) && RegWriteM) && (RA2E != 5'd0)) begin
            ForwardBE = 2'b10;
        end else if (((RA2E == WAW) && RegWriteW) && (RA2E != 5'd0)) begin
            ForwardBE = 2'b01;
        end else
            ForwardBE = 2'b00;
    end

    // Load-use hazard: stall one cycle when EX is a load and ID needs the result
    always @(*) begin
        if (RegWriteE && ((RA1D == WAE) || (RA2D == WAE)) && (ResultSrcE == 2'b01) && (WAE != 5'd0)) begin
                Stall = 1;
        end else begin
                Stall = 0;
        end
    end

    // Flush IF/ID on taken branch or jump (2 instructions must be discarded)
    always @(*) begin
        if (PCSrcE == 2'b01 || PCSrcE == 2'b10) begin
            Flush_IF_ID = 1;
        end else begin
            Flush_IF_ID = 0;
        end
    end

    // Flush ID/EX on stall (insert bubble) or taken branch/jump
    always @(*) begin
        if (Stall || (PCSrcE == 2'b01) || (PCSrcE == 2'b10)) begin
            Flush_ID_EX = 1;
        end else begin
            Flush_ID_EX = 0;
        end
    end

endmodule
