module imem (
    input   [31:0]  addr,
    output  [31:0]  inst
);
    reg [31:0] RAM [0:63];

    initial begin
        $readmemh("C:\AAA_quickAccess\5StagePipelinedRISCV\program.hex", RAM);
    end

    assign inst = RAM[addr[31:2]];
endmodule

/*
RAM is an array with 64 elements. Each element is of 32 bits which is
not directly our concern right now. We will read a 32 bit word from addr.
This will have the address of the instruction to be read but the twist is
that the PC counts in bytes. ie., 0, 4, 8, 12 etc. Hence the last two
digits of the addr will be zero all the time. But RAM is indexed in this
Implementation starting from 0 and ending with 63, one instruction
occupying one slot. Hence that needs to be mapped to the RAM using
inst = RAM[addr[31:2]]
This will take the top 30 bits from the addr register, which is the input
and give it to the index of RAM which then takes the 32 bit value in that
location and gives it to "inst"
*/