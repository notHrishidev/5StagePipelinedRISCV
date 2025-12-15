module regfile (
    input           clk,
    input           writeEn,
    input   [4:0]   addr1,
    input   [4:0]   addr2,
    input   [4:0]   addr3,
    input   [31:0]  writeData,
    output  [31:0]  rd1,
    output  [31:0]  rd2
);
    reg [31:0] rf [31:0];
    assign rd1 = (addr1=5'b0) ? 32'b0 : rf[addr1];
    assign rd2 = (addr2=5'b0) ? 32'b0 : rf[addr2];
    always @(posedge clk ) begin
        if(writeEn) begin
            rf[addr3] <= writeData;
        end
    end
endmodule