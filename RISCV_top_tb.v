`timescale 1ns / 1ps
`include "RISCV_top.v"
module RISCV_top_tb();

    // Inputs
    reg clk;
    reg reset;

    // Instantiate the Unit Under Test (UUT)
    RISCV_top uut (
        .clk(clk),
        .reset(reset)
    );

    // Clock Generation (10ns period = 100MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test Sequence
    initial begin
        reset = 1;
        #20; // Hold reset for 2 cycles
        reset = 0;
        $display("\n-------------------\n[Time %0t] Reset released. Processor starting...\n-------------------", $time);
    end

    // 3. Monitor / Debug Block
    // This block triggers every time the clock rises to print status
    always @(posedge clk) begin
        if (!reset) begin
            $display("PC: %h | Instr_D: %h |RD1_D= %h | RD2_D= %h | ImmExt_D= %h | Time: %0t ", uut.PC_F, uut.Instr_D, uut.RD1_D, uut.RD2_D, uut.ImmExt_D,  $time);
            
            // Check for a write-back event to verify results
            if (uut.RegWrite_W && uut.Waddr_W != 0) begin
                $display("[WB] Writing %h to Register x%0d | Time: %0t", uut.Result_W, uut.Waddr_W, $time);
            end

            // Optional: Check for specific success criteria (Example)
            // If we expect x3 to become 30 (0x1E)
            if (uut.RegWrite_W && uut.Waddr_W == 3 && uut.Result_W == 32'h1E) begin
                $display("[SUCCESS] Result 30 found in x3!");
                $finish;
            end
        end
        if (uut.PC_F >= 32'h20) begin
            $display("\n-------------------\nSimulation Finished\n-------------------");
            $finish;
        end
    end

endmodule