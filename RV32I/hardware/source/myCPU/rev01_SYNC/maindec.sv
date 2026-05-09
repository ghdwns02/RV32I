// Main decoder: maps opcode to datapath control signals.
// ALUSrcA: 2'b00=rs1, 2'b01=PCE, 2'b10=zero
// ResultSrc: 2'b00=ALU, 2'b01=mem, 2'b10=PC+4
module maindec(
    input               Z_flag,
    input       [6:0]   opcode,
    output  reg         MemWrite,
    output  reg         ALUSrcB,
    output  reg         RegWrite,
    output  reg         Branch,
    output  reg [1:0]   ALUSrcA,
    output  reg [1:0]   ResultSrc,
    output  reg [2:0]   ImmSrc,
    output  reg [1:0]   ALUop,
    output              jal,
    output              jalr
);

    assign jal  = (opcode == 7'b110_1111) ? 1'b1 : 1'b0;
    assign jalr = (opcode == 7'b110_0111) ? 1'b1 : 1'b0;

    always@(*) begin
        case(opcode)
            7'b000_0011 : {RegWrite, ImmSrc, ALUSrcA, ALUSrcB, MemWrite, ResultSrc, Branch, ALUop} = 13'b1_000_00_1001_000; // lw
            7'b010_0011 : {RegWrite, ImmSrc, ALUSrcA, ALUSrcB, MemWrite, ResultSrc, Branch, ALUop} = 13'b0_001_00_1100_000; // sw
            7'b011_0011 : {RegWrite, ImmSrc, ALUSrcA, ALUSrcB, MemWrite, ResultSrc, Branch, ALUop} = 13'b1_000_00_0000_010; // R-type
            7'b110_0011 : {RegWrite, ImmSrc, ALUSrcA, ALUSrcB, MemWrite, ResultSrc, Branch, ALUop} = 13'b0_010_00_0000_101; // B-type
            7'b001_0011 : {RegWrite, ImmSrc, ALUSrcA, ALUSrcB, MemWrite, ResultSrc, Branch, ALUop} = 13'b1_000_00_1000_011; // I-type ALU
            7'b110_1111 : {RegWrite, ImmSrc, ALUSrcA, ALUSrcB, MemWrite, ResultSrc, Branch, ALUop} = 13'b1_011_00_0010_000; // jal
            7'b011_0111 : {RegWrite, ImmSrc, ALUSrcA, ALUSrcB, MemWrite, ResultSrc, Branch, ALUop} = 13'b1_100_10_1000_000; // LUI
            7'b001_0111 : {RegWrite, ImmSrc, ALUSrcA, ALUSrcB, MemWrite, ResultSrc, Branch, ALUop} = 13'b1_100_01_1000_000; // AUIPC
            7'b110_0111 : {RegWrite, ImmSrc, ALUSrcA, ALUSrcB, MemWrite, ResultSrc, Branch, ALUop} = 13'b1_000_00_1010_011; // jalr
            7'b111_0011 : {RegWrite, ImmSrc, ALUSrcA, ALUSrcB, MemWrite, ResultSrc, Branch, ALUop} = 13'b0_101_00_0000_000; // CSR
            default     : {RegWrite, ImmSrc, ALUSrcA, ALUSrcB, MemWrite, ResultSrc, Branch, ALUop} = 13'hx;
        endcase
    end

endmodule
