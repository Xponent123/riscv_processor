`timescale 1ns/1ps

module tb_control_unit;
    reg [6:0] opcode;
    wire RegWrite, MemtoReg, MemRead, MemWrite, Branch, ALUSrc;
    wire [1:0] ALUOp;

    control_unit dut (
        .opcode(opcode),
        .RegWrite(RegWrite),
        .MemtoReg(MemtoReg),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .Branch(Branch),
        .ALUSrc(ALUSrc),
        .ALUOp(ALUOp)
    );

    initial begin
        $display("Time\tOpcode    RegWrite MemtoReg MemRead MemWrite Branch ALUSrc ALUOp");
        $monitor("%0t\t%b   %b       %b         %b        %b       %b      %b      %b", 
                 $time, opcode, RegWrite, MemtoReg, MemRead, MemWrite, Branch, ALUSrc, ALUOp);

        // Test R-type: 0110011
        opcode = 7'b0110011;
        #10;
        
        // Test Load (ld): 0000011
        opcode = 7'b0000011;
        #10;
        
        // Test Store (sd): 0100011
        opcode = 7'b0100011;
        #10;
        
        // Test Branch (beq): 1100011
        opcode = 7'b1100011;
        #10;
        
        // Test unknown opcode: 1111111
        opcode = 7'b1111111;
        #10;
        
        $finish;
    end
endmodule
