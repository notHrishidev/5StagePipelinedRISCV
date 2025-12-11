`timescale 1ns / 1ps
`include "ALU.v"
module ALU_TB;

    // 1. Declare signals to connect to the ALU
    // Inputs (We drive these, so they are 'reg')
    reg [31:0] A;
    reg [31:0] B;
    reg [2:0]  ALUControl;

    // Outputs (The ALU drives these, so they are 'wire')
    wire [31:0] Result;
    wire        Zero;

    // 2. Instantiate the ALU (Device Under Test)
    ALU DUT(
        .A(A),
        .B(B),
        .ALUControl(ALUControl),
        .Result(Result),
        .Zero(Zero)
    );

    // 3. The Test Script
    initial begin
        // Set up "Monitor" - runs in background and prints whenever signals change
        $display("Time  | Op Code |     A    |     B    |  Result  | Zero");
        $display("------|---------|----------|----------|----------|------");
        
        // --- TEST 1: ADDITION ---
        A = 32'd10; B = 32'd20; ALUControl = 3'b000; // ADD
        #10; // Wait 10 nanoseconds for result to stabilize
        $display("%4t | %s     | %h | %h | %h |  %b", $time, "ADD", A, B, Result, Zero);

        // --- TEST 2: SUBTRACTION (Result Zero) ---
        A = 32'd15; B = 32'd15; ALUControl = 3'b001; // SUB
        #10;
        $display("%4t | %s     | %h | %h | %h |  %b", $time, "SUB", A, B, Result, Zero);

        // --- TEST 3: AND ---
        A = 32'hFFFF0000; B = 32'h0000FFFF; ALUControl = 3'b010; // AND
        #10;
        $display("%4t | %s     | %h | %h | %h |  %b", $time, "AND", A, B, Result, Zero);

        // --- TEST 4: OR ---
        A = 32'hFFFF0000; B = 32'h0000FFFF; ALUControl = 3'b011; // OR
        #10;
        $display("%4t | %s      | %h | %h | %h |  %b", $time, "OR", A, B, Result, Zero);

        // --- TEST 5: SLT (Simple Case) ---
        A = 32'd10; B = 32'd20; ALUControl = 3'b101; // SLT
        #10;
        $display("%4t | %s     | %h | %h | %h |  %b", $time, "SLT", A, B, Result, Zero);

        // --- TEST 6: SLT (The Signed Trap!) ---
        // Case: -1 vs 1
        // -1 in Hex is FFFFFFFF. 1 is 00000001.
        // If Unsigned: FFFFFFFF > 1 (Result 0).
        // If Signed:   -1 < 1       (Result 1).
        A = 32'hFFFFFFFF; B = 32'd1; ALUControl = 3'b101; // SLT
        #10;
        $display("%4t | %s     | %h | %h | %h |  %b", $time, "SLT", A, B, Result, Zero);

        // End Simulation
        $finish;
    end

endmodule