module dmem(
    input clk, writeEn,
    input [31:0] a, writeData,
    output [31:0] rd
);
    reg [31:0] RAM [63:0];
    
    assign rd = RAM[a[31:2]]; // Word aligned read

    always @(posedge clk) begin
        if (writeEn) RAM[a[31:2]] <= writeData;
    end
endmodule