module HazardDetectionUnit (
    input [4:0] Raddr1_D,
    input [4:0] Raddr2_D,

    input [4:0] Waddr_E,
    input ResultSrcb0, //0 bit of ResultSrc; 1=LoadInstruction, 0=DwondWorry

    output reg PCWrite, //Control the PC; stop when required
    output reg IF_ID_Write, // Freeze Decode reg override
    output reg StallBubble // Insert stall bubble or not
);
    wire is_load_instruction = ResultSrcb0; 

    always @(*) begin
        // Default: EVERYTHING RUNS NORMALLY
        PCWrite     = 1'b1;  // Keep updating PC
        IF_ID_Write  = 1'b1;  // Keep updating IF/ID Reg
        StallBubble = 1'b0;  // Don't insert bubble

        // THE STALL CONDITION:
        // 1. The instruction in Execute is a LOAD (is_load_instruction)
        // 2. The instruction in Decode needs the Load's destination register (rs1 or rs2 matches rd)
        // 3. The destination is not x0 (writing to x0 doesn't count)
        if (is_load_instruction && (Waddr_E != 0) && ((Waddr_E == Raddr1_D) || (Waddr_E == Raddr2_D))) begin
            
            // EMERGENCY STOP
            PCWrite     = 1'b0; // Freeze the PC (Fetch same instr again)
            IF_ID_Write  = 1'b0; // Freeze the IF/ID Reg (Decode same instr again)
            StallBubble = 1'b1; // Send 0s to ID/EX (Turn next stage into NOP)
        end
    end
    
endmodule