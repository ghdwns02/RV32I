// Immediate extension unit: sign-extends or zero-extends instruction immediates
// according to the instruction format selected by ImmSrc.
module extend(
    input       [2:0]   ImmSrc,
    input       [31:0]  in,
    output  reg [31:0]  out
);

    wire [2:0] funct3;

    assign opcode = in[6:0];
    assign funct3 = in[14:12];

    always@(*) begin
        if (ImmSrc == 3'b000) begin                                                         // I-type
            if ((opcode == 7'b0010011) & (funct3 == 3'b001 | funct3 == 3'b101))
                out = {{27{1'b0}}, in[24:20]};                                              // shift: zero-extend shamt
            else
                out = {{20{in[31]}}, in[31:20]};
        end
        else if (ImmSrc == 3'b001)                                                          // S-type
            out = {{20{in[31]}}, in[31:25], in[11:7]};
        else if (ImmSrc == 3'b010)                                                          // B-type
            out = {{20{in[31]}}, in[7], in[30:25], in[11:8], 1'b0};
        else if (ImmSrc == 3'b011)                                                          // J-type
            out = {{12{in[31]}}, in[19:12], in[20], in[30:21], 1'b0};
        else if (ImmSrc == 3'b100)                                                          // U-type
            out = in[31:12] << 12;
        else if (ImmSrc == 3'b101)                                                          // CSR (zero-extend rs1 as uimm)
            out = {{20{1'b0}}, in[19:15]};
        else
            out = 32'h0;
    end

endmodule
