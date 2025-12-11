module ALU (
    input      [31:0]   A,
    input      [31:0]   B,
    input      [2:0]    ALUControl,
    output reg [31:0]   Result,
    output              Zero
);
    always @(*) begin
        case (ALUControl)
            3'b000  :   Result = A + B;
            3'b001  :   Result = A - B;
            3'b010  :   Result = A & B;
            3'b011  :   Result = A | B;
            3'b100  :   Result = A ^ B;
            3'b101: begin         // SLT (Set Less Than) ie., A<B ?
                if (A[31] != B[31]) begin
                    if(A(31)) Result = 32'b1;
                    else      Result = 32'b0;
                end
                else begin
                    if (A < B)  Result = 32'd1;
                    else        Result = 32'd0;
                end
            end
            default :
        endcase
    end
    assign Zero = (Result == 32'b0) ? 1'b1 : 1'b0;
endmodule