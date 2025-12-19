`timescale 1ns / 1ps

module RISCV_top_tb;

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
        // 1. Initialize & Reset
        $display("-------------------------------------------------------------");
        $display("RISC-V Pipelined Processor Testbench Initiated");
        $display("-------------------------------------------------------------");
        
        reset = 1;
        #20; // Hold reset for 2 cycles
        reset = 0;
        $display("[Time %0t] Reset released. Processor starting...", $time);

        // 2. Run Simulation
        // Depending on your program length, adjust the delay.
        // We will run for 100ns (approx 10 cycles).
        #200;

        $display("-------------------------------------------------------------");
        $display("Simulation Finished.");
        $display("-------------------------------------------------------------");
        $finish;
    end

    // 3. Monitor / Debug Block
    // This block triggers every time the clock rises to print status
    always @(posedge clk) begin
        if (!reset) begin
            $display("Time: %0t | PC: %h | Instr: %h", $time, uut.PC_F, uut.Instr_F);
            
            // Check for a write-back event to verify results
            if (uut.RegWrite_W && uut.Waddr_W != 0) begin
                $display("\t[WB] Writing %h to Register x%0d", uut.Result_W, uut.Waddr_W);
            end

            // Optional: Check for specific success criteria (Example)
            // If we expect x3 to become 30 (0x1E)
            if (uut.RegWrite_W && uut.Waddr_W == 3 && uut.Result_W == 32'h1E) begin
                $display("\t[SUCCESS] Result 30 found in x3!");
            end
        end
    end

endmodule