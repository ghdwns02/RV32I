
module hazard_unit(
    // input ports
    input       [4:0]   RA1D,           // Decode reg 1
    input       [4:0]   RA2D,           // Decode reg 2
    input       [4:0]   WAE,            // Excute destin
    input       [1:0]   ResultSrcE,
    input               RegWriteW,
    input               RegWriteE,
    input       [1:0]   PCSrcE,

    input       [4:0]   RA1E,           // Excute reg 1
    input       [4:0]   RA2E,           // Excute reg 2
    input       [4:0]   WAM,            // Memory destin
    input               RegWriteM,

    input       [4:0]   WAW,            // Write back destin
    // output ports
    output  reg [1:0]   ForwardAD,
    output  reg [1:0]   ForwardBD,
    output  reg [1:0]   ForwardAE,
    output  reg [1:0]   ForwardBE,
    output  reg         Stall,          // IF_ID에서 한번만 해줘도 될듯?
    output  reg         Flush_IF_ID,
    output  reg         Flush_ID_EX
);

    //  레지스터 전방전달 Hazard Test 1, 2, 3, 4
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

    always @(*) begin
        if (RegWriteE && ((RA1D == WAE) || (RA2D == WAE)) && (ResultSrcE == 2'b01) && (WAE != 5'd0)) begin
                Stall = 1;
        end else begin
                Stall = 0;                  // 아님 말고
        end
    end

    always @(*) begin
        if (PCSrcE == 2'b01 || PCSrcE == 2'b10) begin
            Flush_IF_ID = 1;
        end else begin
            Flush_IF_ID = 0;
        end
    end

    always @(*) begin
        if (Stall || (PCSrcE == 2'b01) || (PCSrcE == 2'b10)) begin
            Flush_ID_EX = 1;
        end else begin
            Flush_ID_EX = 0;
        end
    end

endmodule