`timescale 1ns/1ps

module tb_immediate_gen;
    reg  [31:0] instruction;
    wire [63:0] imm_out;

    immediate_gen dut (
        .instruction(instruction),
        .imm_out(imm_out)
    );

    initial begin
        $display("Time\tInstruction\t\timm_out");
        $monitor("%0t\t%h\t%h", $time, instruction, imm_out);

        instruction = 32'hFFF01283; // I-type (ld): opcode 0000011
        #10;
        instruction = 32'hFEF02223; // S-type (sd): opcode 0100011
        #10;
        instruction = 32'hFEF0E063; // B-type (beq): opcode 1100011
        #10;
        instruction = 32'h00A00533; // R-type (default): opcode 0110011 -> imm_out should be 0
        #10;
        $finish;
    end
endmodule
