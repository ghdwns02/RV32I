module aludec(
    // input ports
    input       [6:0]   opcode,
    input       [2:0]   funct3,
    input       [1:0]   ALUop,
    input               funct7,
    // output ports
    output  reg [4:0]   ALUControl
);

    always @(*) begin
        if (ALUop == 2'b00) begin
            ALUControl = 5'b00000; // for load/store
        end 
        else if (ALUop == 2'b01) begin
            ALUControl = 5'b00001; // for branch
        end 
        else if (ALUop == 2'b10) begin // R-type
            case (funct3)
                3'b000 : ALUControl = (funct7) ? 5'b00001 : 5'b00000;   // SUB or ADD
                3'b001 : ALUControl = 5'b00110;                         // SLL
                3'b010 : ALUControl = 5'b00101;                         // SLT
                3'b011 : ALUControl = 5'b10000;                         // SLTU
                3'b100 : ALUControl = 5'b00100;                         // XOR
                3'b101 : ALUControl = (funct7) ? 5'b01000 : 5'b00111;   // SRA or SRL
                3'b110 : ALUControl = 5'b00011;                         // OR
                3'b111 : ALUControl = 5'b00010;                         // AND
                default : ALUControl = 5'hx;
            endcase
        end 
        else if (ALUop == 2'b11) begin // I-type, JALR
            case (funct3)
                3'b000 : ALUControl = (opcode == 7'b1100111) ? 5'b01001 : 5'b01101;     // JALR or ADDI
                3'b001 : ALUControl = 5'b01100;                                         // SLLI
                3'b010 : ALUControl = 5'b01110;                                         // SLTI
                3'b011 : ALUControl = 5'b01111;                                         // SLTIU
                3'b100 : ALUControl = 5'b10011;                                         // XORI
                3'b101 : ALUControl = (funct7) ? 5'b01010 : 5'b01011;                   // SRAI or SRLI
                3'b110 : ALUControl = 5'b10010;                                         // ORI
                3'b111 : ALUControl = 5'b10001;                                         // ANDI
                default : ALUControl = 5'hx;
            endcase
        end
        else begin
            ALUControl = 5'hx;
        end
    end

endmodule