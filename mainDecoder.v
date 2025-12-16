module mainDecoder (
    input[6:0]op,
    output reg RegWrite,
    output reg MemWrite,
    output reg [1:0] ResultSrc,

    output reg ALUSrc,
    output reg [1:0] ALUOp,

    output reg Branch,
    output reg Jump,

    output reg [1:0] ImmSrc //format for the Immediate generator to read
);
    always @(*) begin
        RegWrite    =     0;
        MemWrite    =     0;
        ResultSrc   = 2'b00;
        ALUSrc      =  1'b0;
        ALUOp       = 2'b00;
        Branch      =     0;
        Jump        =     0;
        ImmSrc      = 2'b00;
        
        
        case(op)
            // 1. R-Type (ADD, SUB, XOR...)
            7'b0110011: begin
                RegWrite = 1;
                ALUSrc   = 0;     // Use Register B
                ALUOp    = 2'b10; // "Look at funct3 or 7"
                ResultSrc= 2'b00; // Save ALU Result
            end

            // 2. I-Type Math (ADDI, ANDI...)
            7'b0010011: begin
                RegWrite = 1;
                ALUSrc   = 1;     // Use Immediate
                ImmSrc   = 2'b00; // I-Type Immediate
                ALUOp    = 2'b10; // "Look at funct3" (treat like R-type)
                ResultSrc= 2'b00; // Save ALU Result
            end

            // 3. Load Word (LW)
            7'b0000011: begin
                RegWrite = 1;
                ALUSrc   = 1;     // Use Immediate (Offset)
                ImmSrc   = 2'b00; // I-Type Immediate
                ALUOp    = 2'b00; // Force ADD (Base + Offset)
                ResultSrc= 2'b01; // Save Memory Result
                // MemRead would be 1 here
            end

            // 4. Store Word (SW)
            7'b0100011: begin
                MemWrite = 1;
                ALUSrc   = 1;     // Use Immediate (Offset)
                ImmSrc   = 2'b01; // S-Type Immediate
                ALUOp    = 2'b00; // Force ADD (Base + Offset)
            end

            // 5. Branch (BEQ)
            7'b1100011: begin
                Branch   = 1;
                ALUSrc   = 0;     // Compare two registers
                ImmSrc   = 2'b10; // B-Type Immediate
                ALUOp    = 2'b01; // Force SUB (to compare)
            end

            // 6. Jump (JAL)
            7'b1101111: begin
                Jump     = 1;
                RegWrite = 1;     // Save Return Address
                ImmSrc   = 2'b11; // J-Type Immediate
                ALUOp    = 2'b00; // ADD (PC + Imm) - usually handled in PC logic
                ResultSrc= 2'b10; // Save PC+4
            end

            default: begin
                // Optional: Flag an "Illegal Instruction" error here
                RegWrite = 0;
            end
        endcase
    end 
    
endmodule