`timescale 1ns / 1ps

module forwarding_unit(
    input  [4:0] EX_Rs1,
    input  [4:0] EX_Rs2,
    input  [4:0] MEM_Rd,
    input        MEM_RegWrite,
    input  [4:0] WB_Rd,
    input        WB_RegWrite,
    output reg [1:0] ForwardA,
    output reg [1:0] ForwardB
);

    always @(*) begin
        ForwardA = 2'b00;
        ForwardB = 2'b00;

        if (MEM_RegWrite && (MEM_Rd != 5'd0) && (MEM_Rd == EX_Rs1)) begin
            ForwardA = 2'b10;  
        end
        else if (WB_RegWrite && (WB_Rd != 5'd0) &&
                 !(MEM_RegWrite && (MEM_Rd != 5'd0) && (MEM_Rd == EX_Rs1)) &&
                 (WB_Rd == EX_Rs1)) begin
            ForwardA = 2'b01;  
        end

        if (MEM_RegWrite && (MEM_Rd != 5'd0) && (MEM_Rd == EX_Rs2)) begin
            ForwardB = 2'b10;
        end
        else if (WB_RegWrite && (WB_Rd != 5'd0) &&
                 !(MEM_RegWrite && (MEM_Rd != 5'd0) && (MEM_Rd == EX_Rs2)) &&
                 (WB_Rd == EX_Rs2)) begin
            ForwardB = 2'b01;  
        end
    end

endmodule
