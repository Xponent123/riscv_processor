`timescale 1ns/1ps

module tb_alu_control;
    reg  [1:0] ALU_op;
    reg  [2:0] funct3;
    reg        bit30;
    wire [3:0] ALUControl;

    alu_control dut (
        .ALU_op(ALU_op),
        .funct3(funct3),
        .bit30(bit30),
        .ALUControl(ALUControl)
    );

    initial begin
        $display("ALU_op\tfunct3\tbit30\tALUControl");
        $monitor("%b\t%b\t%b\t%b", ALU_op, funct3, bit30, ALUControl);

        // Test case 1: ALU_op = 00 -> D0 = 4'b0010
        ALU_op  = 2'b00;
        funct3  = 3'b000;
        bit30   = 1'b1;
        #10;

        // Test case 1: ALU_op = 00 -> D0 = 4'b0010
        ALU_op  = 2'b00;
        funct3  = 3'b000;
        bit30   = 1'b0;
        #10;

        // Test case 2: ALU_op = 01 -> D1 = 4'b0110
        ALU_op  = 2'b01;
        #10;

        // Test case 3: ALU_op = 10, funct3 = 000, bit30 = 0 -> 4'b0010 (ADD)
        ALU_op  = 2'b10;
        funct3  = 3'b000;
        bit30   = 1'b0;
        #10;

        // Test case 4: ALU_op = 10, funct3 = 000, bit30 = 1 -> 4'b0110 (SUB)
        ALU_op  = 2'b10;
        funct3  = 3'b000;
        bit30   = 1'b1;
        #10;

        // Test case 5: ALU_op = 10, funct3 = 111, bit30 = 0 -> 4'b0000 (AND)
        ALU_op  = 2'b10;
        funct3  = 3'b111;
        bit30   = 1'b0;
        #10;

        // Test case 6: ALU_op = 10, funct3 = 110, bit30 = 0 -> 4'b0001 (OR)
        ALU_op  = 2'b10;
        funct3  = 3'b110;
        bit30   = 1'b0;
        #10;

        $finish;
    end
endmodule
