module ForwardingUnit (
    input [4:0] Raddr1_e,
    input [4:0] Raddr2_e,

    input [4:0] Waddr_m,
    input RegWrite_m,

    input [4:0] Waddr_wb,
    input RegWrite_wb,

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