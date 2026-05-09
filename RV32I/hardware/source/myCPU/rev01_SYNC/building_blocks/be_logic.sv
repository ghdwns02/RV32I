// Byte-enable logic for sub-word load and store operations.
// Generates ByteEnable mask and aligned write data (BE_WD) for stores,
// and sign/zero-extended read data (BE_RD) for loads.
module be_logic (
    input       [1:0]   AddrLast2M,  // address[1:0] in MEM stage (store)
    input       [2:0]   funct3M,     // funct3 in MEM stage (store type)
    input       [1:0]   AddrLast2W,  // address[1:0] in WB stage (load)
    input       [2:0]   funct3W,     // funct3 in WB stage (load type)
    input       [31:0]  WD,
    input       [31:0]  RD,
    output reg  [31:0]  BE_WD,
    output reg  [31:0]  BE_RD,
    output reg  [3:0]   ByteEnable
);

    // ByteEnable: one-hot byte mask for memory write
    always @(*) begin
        ByteEnable = 4'b0000;
        case (funct3M)
            3'b000 : begin  // SB
                case (AddrLast2M)
                    2'b00 : ByteEnable = 4'b0001;
                    2'b01 : ByteEnable = 4'b0010;
                    2'b10 : ByteEnable = 4'b0100;
                    2'b11 : ByteEnable = 4'b1000;
                endcase
            end
            3'b001 : begin  // SH
                case (AddrLast2M[1])
                    1'b0 : ByteEnable = 4'b0011;
                    1'b1 : ByteEnable = 4'b1100;
                endcase
            end
            3'b010 : ByteEnable = 4'b1111; // SW
            default: ByteEnable = 4'b0000;
        endcase
    end

    // BE_WD: shift write data to the correct byte lane
    always @(*) begin
        BE_WD = 32'b0;
        case (funct3M)
            3'b000 : begin  // SB
                case (AddrLast2M)
                    2'b00 : BE_WD = {24'b0, WD[7:0]};
                    2'b01 : BE_WD = {16'b0, WD[7:0], 8'b0};
                    2'b10 : BE_WD = {8'b0, WD[7:0], 16'b0};
                    2'b11 : BE_WD = {WD[7:0], 24'b0};
                endcase
            end
            3'b001 : begin  // SH
                case (AddrLast2M[1])
                    1'b0 : BE_WD = {16'b0, WD[15:0]};
                    1'b1 : BE_WD = {WD[15:0], 16'b0};
                endcase
            end
            3'b010 : BE_WD = WD; // SW
        endcase
    end

    // BE_RD: extract and sign/zero-extend the correct byte lane from memory read data
    always @(*) begin
        BE_RD = 32'b0;
        case (funct3W)
            3'b000 : begin  // LB (sign-extend)
                case (AddrLast2W)
                    2'b00 : BE_RD = {{24{RD[7]}},  RD[7:0]};
                    2'b01 : BE_RD = {{24{RD[15]}}, RD[15:8]};
                    2'b10 : BE_RD = {{24{RD[23]}}, RD[23:16]};
                    2'b11 : BE_RD = {{24{RD[31]}}, RD[31:24]};
                endcase
            end
            3'b100 : begin  // LBU (zero-extend)
                case (AddrLast2W)
                    2'b00 : BE_RD = {24'b0, RD[7:0]};
                    2'b01 : BE_RD = {24'b0, RD[15:8]};
                    2'b10 : BE_RD = {24'b0, RD[23:16]};
                    2'b11 : BE_RD = {24'b0, RD[31:24]};
                endcase
            end
            3'b001 : begin  // LH (sign-extend)
                case (AddrLast2W[1])
                    1'b0 : BE_RD = {{16{RD[15]}}, RD[15:0]};
                    1'b1 : BE_RD = {{16{RD[31]}}, RD[31:16]};
                endcase
            end
            3'b101 : begin  // LHU (zero-extend)
                case (AddrLast2W[1])
                    1'b0 : BE_RD = {16'b0, RD[15:0]};
                    1'b1 : BE_RD = {16'b0, RD[31:16]};
                endcase
            end
            3'b010 : BE_RD = RD; // LW
        endcase
    end

endmodule
