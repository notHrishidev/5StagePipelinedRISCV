module ALUDecoder (
    input            opb5, //Bit 5 of Op, 1=Rtype, 0=Itype
    input      [2:0] funct3, //bits 14,13,12 from instruction
    input            funct7b5, //bit30 from instruction for 1=SUB/SRA, 0=ADD/SRL
    input      [1:0] ALUOp, //From main decoder for ALU control
    output reg [2:0] ALUControl
);
    always @(*) begin
        case(ALUOp)
            // 00: LW/SW -> Force ADD
            2'b00: ALUControl = 3'b000; 

            // 01: BEQ -> Force SUB (to compare)
            2'b01: ALUControl = 3'b001; 

            // 10: R-Type or I-Type (Look at funct bits)
            2'b10: begin
                case(funct3)
                    // ADD or SUB
                    3'b000: begin
                        // True R-Type SUB? (Op[5]=1 AND Funct7[5]=1)
                        if (opb5 && funct7b5) 
                            ALUControl = 3'b001; // SUB
                        else 
                            ALUControl = 3'b000; // ADD (or ADDI)
                    end

                    // SLT (Set Less Than)
                    3'b010: ALUControl = 3'b101; 
                    
                    // OR
                    3'b110: ALUControl = 3'b011; 

                    // AND
                    3'b111: ALUControl = 3'b010; 

                    // XOR (Optional, mapped to 100 if your ALU supports it)
                    3'b100: ALUControl = 3'b100;

                    default: ALUControl = 3'b000; // Default to ADD
                endcase
            end

            default: ALUControl = 3'b000;
        endcase
    end
endmodule