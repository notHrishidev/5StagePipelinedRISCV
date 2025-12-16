module extend (
    input  [31:7] Instruction,  // The relevant bits of the Instructionuction
    input  [1:0]  ImmSrc, // Control signal from Main Decoder
    output reg [31:0] ImmOut // The 32-bit output constant
);

    always @(*) begin
        case(ImmSrc)
            // 00: I-Type (ADDI, LW)
            // - Take bits [31:20] (12 bits)
            // - Sign extend bit [31] for the top 20 bits
            2'b00: ImmOut = {{20{Instruction[31]}}, Instruction[31:20]};

            // 01: S-Type (SW)
            // - Top 7 bits come from [31:25]
            // - Bottom 5 bits come from [11:7]
            // - Sign extend bit [31]
            2'b01: ImmOut = {{20{Instruction[31]}}, Instruction[31:25], Instruction[11:7]};

            // 10: B-Type (BEQ) - The "Scrambled" One
            // - Bit 0 is ALWAYS 0 (implicit)
            // - Bit 11 is Instruction[7]
            // - Bits 4:1 are Instruction[11:8]
            // - Bits 10:5 are Instruction[30:25]
            // - Bit 12 is Instruction[31]
            2'b10: ImmOut = {{20{Instruction[31]}}, Instruction[7], Instruction[30:25], Instruction[11:8], 1'b0};

            // 11: J-Type (JAL) - The "Scrambled" Jump
            // - Bit 0 is ALWAYS 0
            // - Bits 10:1 are Instruction[30:21]
            // - Bit 11 is Instruction[20]
            // - Bits 19:12 are Instruction[19:12]
            // - Bit 20 is Instruction[31]
            2'b11: ImmOut = {{12{Instruction[31]}}, Instruction[19:12], Instruction[20], Instruction[30:21], 1'b0};

            default: ImmOut = 32'b0;
        endcase
    end
endmodule