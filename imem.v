module imem (
    input   [31:0]  addr,
    output  [31:0]  inst
);
    reg [31:0] RAM [0:63];

    initial begin
        $readmemh("memfile.dat", RAM);
    end

    assign inst = RAM[addr[31:2]];
endmodule