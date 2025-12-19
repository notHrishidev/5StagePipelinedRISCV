module ForwardingUnit (
    input [4:0] Raddr1_E,
    input [4:0] Raddr2_E,

    input [4:0] Waddr_M,
    input RegWrite_M,

    input [4:0] Waddr_W,
    input RegWrite_W,

    output reg [1:0] forwardA,
    output reg [1:0] forwardB
);
    always @(*) begin
        forwardA = 2'b00;
        
        //Are we writing something? AND We aren't writing to x0 right? AND same address?
        if(RegWrite_M && (Waddr_M != 0) && (Raddr1_E == Waddr_M)) begin
            forwardA = 2'b10;
        end
        else if (RegWrite_W && (Waddr_W != 0) && (Raddr1_E == Waddr_W)) begin
            forwardA = 2'b01;
        end


        forwardB = 2'b00;
        //Are we writing something? AND We aren't writing to x0 right? AND same address?
        if(RegWrite_M && (Waddr_M != 0) && (Raddr2_E == Waddr_M)) begin
            forwardB = 2'b10;
        end
        else if (RegWrite_W && (Waddr_W != 0) && (Raddr2_E == Waddr_W)) begin
            forwardB = 2'b01;
        end
    end
    
endmodule