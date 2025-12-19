module ForwardingUnit (
    input [4:0] Raddr1_E,
    input [4:0] Raddr2_E,

    input [4:0] Waddr_M,
    input RegWrite_M,

    input [4:0] Waddr_WB,
    input RegWrite_WB,

    output reg [1:0] forwardA,
    output reg [1:0] forwardB
);
    always @(*) begin
        forwardA = 2'b00;
        
        //Are we writing something? AND We aren't writing to x0 right? AND same address?
        if(RegWrite_m && (Waddr_m != 0) && (Raddr1_e == Waddr_m)) begin
            forwardA = 2'b10
        end
        else if (RegWrite_m && (Waddr_m != 0) && (Raddr1_e == Waddr_wb)) begin
            forwardA = 2'b01;
        end


        forwardB = 2'b00;
        //Are we writing something? AND We aren't writing to x0 right? AND same address?
        if(RegWrite_m && (Waddr_m != 0) && (Raddr2_e == Waddr_m)) begin
            forwardB = 2'b10
        end
        else if (RegWrite_m && (Waddr_m != 0) && (Raddr2_e == Waddr_wb)) begin
            forwardB = 2'b01;
        end
    end
    
endmodule