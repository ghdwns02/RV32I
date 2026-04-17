module ID_EX (
    // input ports
    input               clk,
    input               n_rst,
    input               Flush_ID_EX,

    input       [31:0]  RD1D,           // read data 1
    input       [31:0]  RD2D,           // read data 2
    input       [4:0]   WAD,            // write address

    input               BranchD,
    input               jalD,
    input               jalrD,
    input       [1:0]   ResultSrcD,
    input               MemWriteD,
    input       [4:0]   ALUControlD,
    input       [1:0]   ALUSrcAD,
    input               ALUSrcBD,
    input               RegWriteD,
    input       [31:0]  PCPlus4D,
    input       [31:0]  PCD,
    input       [31:0]  ImmExtD,
    input       [31:0]  InstrD,

    // output ports
    output  reg         BranchE,
    output  reg         jalE,
    output  reg         jalrE,
    output  reg [1:0]   ResultSrcE,
    output  reg         MemWriteE,
    output  reg [4:0]   ALUControlE,
    output  reg [1:0]   ALUSrcAE,
    output  reg         ALUSrcBE,
    output  reg         RegWriteE,
    output  reg [31:0]  InstrE,
    output  reg [31:0]  PCPlus4E,
    output  reg [31:0]  PCE,
    output  reg [31:0]  ImmExtE,

    output  reg [4:0]   RA1E,           // read address 1
    output  reg [31:0]  RD1E,           // read data 1
    output  reg [4:0]   RA2E,           // read address 2
    output  reg [31:0]  RD2E,           // read data 2
    output  reg [4:0]   WAE             // write address
);

    parameter RESET_PC = 32'h1000_0000;

    always @(posedge clk or negedge n_rst) begin
        if (!n_rst) begin
            BranchE <= 1'b0;
            jalE <= 1'b0;
            jalrE <= 1'b0;
            ResultSrcE <= 2'h0;
            MemWriteE <= 1'b0;
            ALUControlE <= 5'h0;
            ALUSrcAE <= 2'h0;
            ALUSrcBE <= 1'b0;
            RegWriteE <= 1'b0;
            InstrE <= 32'h00000013;
            PCPlus4E <= 32'h0;
            PCE <= RESET_PC;
            ImmExtE <= 32'h0;
            RA1E <= 5'h0;
            RD1E <= 32'h0;
            RA2E <= 5'h0;
            RD2E <= 32'h0;
            WAE <= 5'h0;
        end else begin
            if (Flush_ID_EX) begin
                BranchE <= 1'b0;
                jalE <= 1'b0;
                jalrE <= 1'b0;
                ResultSrcE <= 2'h0;
                MemWriteE <= 1'b0;
                ALUControlE <= 5'h0;
                ALUSrcAE <= 2'h0;
                ALUSrcBE <= 1'b0;
                RegWriteE <= 1'b0;
                InstrE <= 32'h00000013;
                WAE <= 5'h0;
            end else begin
                BranchE <= BranchD;
                jalE <= jalD;
                jalrE <= jalrD;
                ResultSrcE <= ResultSrcD;
                MemWriteE <= MemWriteD;
                ALUControlE <= ALUControlD;
                ALUSrcAE <= ALUSrcAD;
                ALUSrcBE <= ALUSrcBD;
                RegWriteE <= RegWriteD;
                InstrE <= InstrD;
                PCPlus4E <= PCPlus4D;
                PCE <= PCD;
                ImmExtE <= ImmExtD;
                RA1E <= InstrD[19:15];
                RD1E <= RD1D;
                RA2E <= InstrD[24:20];
                RD2E <= RD2D;
                WAE <= WAD;
            end
        end
    end

endmodule