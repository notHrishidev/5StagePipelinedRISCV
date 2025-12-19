module regfile (
    input           clk,
    input           writeEn,
    input   [4:0]   Raddr1,
    input   [4:0]   Raddr2,
    input   [4:0]   Waddr,
    input   [31:0]  writeData,
    output  [31:0]  rd1,
    output  [31:0]  rd2
);
    reg [31:0] rf [31:0];
    assign rd1 = (Raddr1==5'b0) ? 32'b0 : rf[Raddr1];
    assign rd2 = (Raddr2==5'b0) ? 32'b0 : rf[Raddr2];
    always @(posedge clk ) begin
        if(writeEn) begin
            rf[Waddr] <= writeData;
        end
    end
endmodule