`timescale 1ns / 1ps

module ALU_tb;

    reg [3:0] alu_control;
    reg [63:0] rs1, rs2;
    wire [63:0] rd;
    wire alu_zero;

    ALU uut (
        .alu_control(alu_control),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .alu_zero(alu_zero)
    );

    initial begin
        $monitor("ALU Control=%b | rs1=%h | rs2=%h | rd=%h | alu_zero=%b", alu_control, rs1, rs2, rd, alu_zero);

        rs1 = 64'hA5A5A5A5A5A5A5A5;
        rs2 = 64'h5A5A5A5A5A5A5A5A;

        alu_control = 4'b0000; // AND
        #10;

        alu_control = 4'b0001; // OR
        #10;

        alu_control = 4'b0010; // ADD
        #10;

        alu_control = 4'b0110; // SUBTRACT
        #10;

        rs1 = 64'hFFFFFFFFFFFFFFFF;
        rs2 = 64'hFFFFFFFFFFFFFFFF;
        alu_control = 4'b0010; // ADD (overflow case)
        #10;

        rs1 = 64'h0000000000000000;
        rs2 = 64'h0000000000000000;
        alu_control = 4'b0110; // SUBTRACT (zero case)
        #10;

        $finish;
    end

endmodule
