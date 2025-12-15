`timescale 1ns / 1ps
`include "regfile.v"


module regfile_TB   (
    reg           clk,
    reg           writeEn,
    reg   [4:0]   addr1,
    reg   [4:0]   addr2,
    reg   [4:0]   addr3,
    reg   [31:0]  writeData,
    wire  [31:0]  rd1,
    wire  [31:0]  rd2
);
    regfile DUT(
        .clk(clk),
        .writeEn(writeEN);
        .addr1(addr1),
        .addr2(addr2);
        .addr3(addr3);
        .writeData(writeData);
        .rd1(rd1),
        .rd2(rd2)
    );
    
    always begin
        #10
        clk = ~clk;
    end

    initial begin
        clk = 0;
        $display("Operation   | rd1    | rd2    | ")
    end
    
endmodule