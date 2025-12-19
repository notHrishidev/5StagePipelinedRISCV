`timescale 1ns/1ps

`include "ALU.v"
`include "ALUDecoder.v"
`include "ForwardingUnit.v"
`include "HazardDetectionUnit.v"
`include "imem.v"
`include "dmem.v"
`include "extend.v"
`include "mainDecoder.v"
`include "regfile.v"

module RISCV_top (
    input clk,
    input reset
);
    //IF Stage Signals (Always end with _F)
    wire [31:0] PC_F, PCNext_F, PCPlus4_F;
    wire [31:0] Instr_F;
    wire PCWrite;

    //ID Stage signals (Always end with _D)
    wire [31:0] Instr_D, PC_D, PCPlus4_D;
    wire [31:0] RD1_D, RD2_D, ImmSrc_D;
    wire [4:0] Raddr1_D, Raddr2_D, Waddr_D;

    //Control Signals (I/D Stage)
    wire RegWrite_D, MemWrite_D, ALUSrc_D, Branch_D, Jump_D;
    wire [1:0] ResultSrc_D, ALUOp_D, ImmSrc_D;

    //Hazard unit signals:
    wire StallBubble, IF_ID_Write;

    //EX Stage signals (Always end with _e)
    reg [31:0] RD1_E, RD2_E, ImmExt_E, PC_E, PCPlus4_E;
    reg [4:0] Raddr1_E, Raddr2_E, Waddr_E;
    reg RegWrite_E, MemWrite_E, ALUSrc_E, Branch_E, Jump_E;
    reg [1:0] ResultSrc_E, ALUOp_E;

    //Function signals for the ALUDecoder:
    reg [2:0] Funct3_E;
    reg Funct7b5_E;

    // EX Calculation Signals
    wire [31:0] SrcA_E, SrcB_E, ALUResult_E, WriteData_E;
    wire [31:0] PCTarget_E;
    wire [2:0]  ALUControl_E;
    wire        Zero_E;
    wire [1:0]  ForwardA_E, ForwardB_E;

    //MEM Stage Signals
    reg [31:0] ALUResult_M, WriteData_M, PCPlus4_M;
    reg [4:0]  Waddr_M;
    reg        RegWrite_M, MemWrite_M;
    reg [1:0]  ResultSrc_M;
    wire [31:0] ReadData_M;

    //WB Stage Signals
    reg [31:0] ALUResult_W, ReadData_W, PCPlus4_W;
    reg [4:0]  Waddr_W;
    reg        RegWrite_W;
    reg [1:0]  ResultSrc_W;
    wire [31:0] Result_W;

    //_______FETCH STAGE_______

    //Logic for Branch/Jump:
    wire PCSrc_E;
    assign PCSrc_E = (Branch_E & Zero_E) | Jump_E;
    assign PCNext_F = PCSrc_E ? PCTarget_E : PCPlus4_F;
    assign PCPlus4_F = PC_F + 4;

    //PC Register:
    reg [31:0] PC_r;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            PC_r <= 0;
        end
        else if(PCWrite) begin
            PC_r <= PCNext_F;
        end
    end
    assign PC_F = PC_r;

    //instruction Memory:
    imem InstructionMemory(
        .addr(PC_F),
        .inst(Instr_F)
    );

    //_______IF/ID PIPELINE REGISTER_______
    reg [31:0] Instr_D_r, PC_D_r, PCPlus4_D_r;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            Instr_D_r <=0;
            PC_D_r <= 0;
            PCPlus4_D_r <=0;
        end
        else if (IF_ID_Write) begin //No stall signal from the HDU
            if (PCSrc_E) begin
                Instr_D_r <=0;
                PC_D_r <= 0;
                PCPlus4_D_r <=0; //Flush on branch taken
            end
            else begin
                Instr_D_r <= Instr_F;
                PC_D_r <= PC_F;
                PCPlus4_D_r <= PCPlus4_F; //Carry over the values for the next clock cycle
            end
        end
    end
    assign Instr_D = Instr_D_r;
    assign PC_D = PC_D_r;
    assign PCPlus4_D = PCPlus4_D_r;

    //_______DECODE STAGE_______

    assign RD1_D = Instr_D[19:15];
    assign RD2_D = Instr_D[24:20];
    assign Waddr_D = Instr_D[11:7]; //Standard format for RISC V

    mainDecoder MainDecoder (
        .op(Instr_D[6:0]),
        .regWrite(RegWrite_D),
        .MemWrite(MemWrite_D),
        .ResultSrc(ResultSrc_D),
        .ALUSrc(ALUSrc_D),
        .ALUOp(ALUOp_D),
        .Branch(Branch_D),
        .Jump(Jump_D),
        .ImmSrc(ImmSrc_D)
    );

    regfile RegFile(
        .clk(clk),
        .writeEn(RegWrite_E),
        .Raddr1(Raddr1_D),
        .Raddr2(Raddr2_D),
        .Waddr(Waddr_D),
        .writeData(Result_W),
        .rd1(RD1_D),
        .rd2(RD2_D)
    );

    extend SignExtender(
        .Instruction(Instr_D[31:7]),
        .ImmSrc(ImmSrc_D),
        .ImmOut(ImmExt_D)
    );
    
    HazardDetectionUnit HDU(
        .Raddr1_D(Raddr1_D),
        .Raddr2_D(Raddr2_D),
        .Waddr_E(Waddr_E),
        .ResultSrcb0(ResultSrc_E[0]),
        .PCWrite(PCWrite),
        .IF_ID_Write(IF_ID_Write),
        .StallBubble(StallBubble)
    );

    //_______ID/EX PIPELINE REGISTER_______
    
    always @(posedge clk or posedge reset) begin
        Funct3_E <= Instr_D[14:12];
        Funct7b5_E <= Instr_D[30];
        if (reset) begin
            RD1_E <= 32'b0;
            RD2_E <= 32'b0;
            ImmExt_E <= 32'b0;
            PC_E <= 32'b0;
            PCPlus4_E <= 32'b0;

            Raddr1_E <= 5'b0;
            Raddr2_E <= 5'b0;
            Waddr_E <= 5'b0;

            RegWrite_E <= 1'b0;
            MemWrite_E <= 1'b0;
            ALUSrc_E <= 1'b0;
            Branch_E <= 1'b0;
            Jump_E <= 1'b0;

            ResultSrc_E <= 2'b0;
            ALUOp_E <= 2'b0;
        end
        else begin
            if (StallBubble || PCSrc_E) begin
                RegWrite_E <= 1'b0;
                MemWrite_E <= 1'b0;
                ALUSrc_E <= 1'b0;
                Branch_E <= 1'b0;
                Jump_E <= 1'b0;
            end
            else begin
                RegWrite_E <= RegWrite_D;
                MemWrite_E <= MemWrite_D;
                ResultSrc_E<= ResultSrc_D;
                ALUSrc_E   <= ALUSrc_D;
                ALUOp_E    <= ALUOp_D;
                Branch_E   <= Branch_D;
                Jump_E     <= Jump_D;
                
                RD1_E      <= RD1_D;
                RD2_E      <= RD2_D;
                Raddr1_E   <= Raddr1_D;
                Raddr2_E   <= Raddr2_D;
                Waddr_E    <= Waddr_D;
                ImmExt_E   <= ImmExt_D;
                PC_E       <= PC_D;
                PCPlus4_E  <= PCPlus4_D;
            end
        end
    end

    //______EXECUTE STAGE______

    assign SrcA_E = (ForwardA_E == 2'b10) ? ALUResult_M :
                    (ForwardA_E == 2'b01) ? Result_W :
                    RD1_E;
    wire [31:0] WriteData_temp;
    assign WriteData_temp = (ForwardB_E == 2'b10) ? ALUResult_M :
                            (ForwardB_E == 2'b01) ? Result_W :
                            RD2_E;
    assign SrcB_E = ALUSrc_E ? ImmExt_E : WriteData_temp;

    assign WriteData_E = WriteData_temp;

    ALUDecoder ALUDec(
        .opb5(ALUOp_E[1]),
        .funct3(Funct3_E),
        .funct7b5(Funct7b5_E),
        .ALUOp(ALUOp_E),
        .ALUControl(ALUControl_E)
    );

    ALU alu(
        .A(SrcA_E),
        .B(SrcB_E),
        .ALUControl(ALUControl_E),
        .Result(ALUResult_E),
        .Zero(Zero_E)
    );

    assign PCTarget_E = PC_E + ImmExt_E; //Used for jump with offset

    ForwardingUnit FU(
        .Raddr1_E(Raddr1_E),
        .Raddr2_E(Raddr2_E),
        .Waddr_M(Waddr_M),
        .RegWrite_M(RegWrite_M),
        .Waddr_W(Waddr_W),
        .RegWrite_W(RegWrite_W),
        .forwardA(ForwardA_E),
        .forwardB(ForwardB_E)
    );

    //_______EX/MEM PIPELINE REGISTER_______

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            ALUResult_M <= 0;
            WriteData_M <= 0;
            PCPlus4_M <= 0;

            Waddr_M <= 0;

            RegWrite_M <= 0;
            MemWrite_M <= 0;

            ResultSrc_M <= 0;

        end
        else begin //just copy over everything from Execute stage to Memory stage.
            ALUResult_M <= ALUResult_E;
            WriteData_M <= WriteData_E;
            PCPlus4_M <= PCPlus4_E;

            Waddr_M <= Waddr_E;

            RegWrite_M <= RegWrite_E;
            MemWrite_M <= MemWrite_E;

            ResultSrc_M <= ResultSrc_E;

        end
    end

    //_______MEM STAGE_______

    dmem DataMemory (
        .clk(clk),
        .writeEn(MemWrite_M),
        .a(ALUResult_M),
        .writeData(WriteData_M),
        .rd(ReadData_M)
    );

    //_______MEM/WB PIPELINE REGISTER_______

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            ALUResult_W <= 0;
            ReadData_W <= 0;
            PCPlus4_W <= 0;

            Waddr_W <= 0;
            RegWrite_W <= 0;
            ResultSrc_W <= 0;
        end
        else begin
            ALUResult_W <= ALUResult_M;
            ReadData_W <= ReadData_M;
            PCPlus4_W <= PCPlus4_M;

            Waddr_W <= Waddr_M;
            RegWrite_W <= RegWrite_M;
            ResultSrc_W <= ResultSrc_M;
        end
    end

    //_______WRITE BACK STAGE_______

    assign Result_W = (ResultSrc_W == 2'b00) ? ALUResult_W:
                      (ResultSrc_W == 2'b01) ? ReadData_W :
                                               PCPlus4_W;

endmodule