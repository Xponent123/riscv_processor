`timescale 1ns/1ps
`include "instruction_memory.v"
`include "control_unit.v"
`include "register_file.v"
`include "imm_gen.v"
`include "alu_control.v"
`include "alu.v"
`include "data_memory.v"

module cpu_top(
    input clk,
    input reset
);
    reg [63:0] pc;
    reg [63:0] pc_next;
    wire [63:0] pc_plus_4;
    wire [63:0] pc_branch;
    wire branch_taken;
    wire [31:0] instruction;
    wire [6:0]  opcode   = instruction[6:0];
    wire [4:0]  rd       = instruction[11:7];
    wire [2:0]  func3    = instruction[14:12];
    wire [4:0]  rs1      = instruction[19:15];
    wire [4:0]  rs2      = instruction[24:20];
    wire [6:0]  func7    = instruction[31:25];
    wire        func7_5  = func7[5];
    wire RegWrite;
    wire MemtoReg;
    wire MemRead;
    wire MemWrite;
    wire Branch;
    wire ALUSrc;
    wire [1:0] ALUOp;
    wire [3:0] ALUControl;
    wire [63:0] reg_data1;
    wire [63:0] reg_data2;
    wire [63:0] imm_out;
    wire [63:0] alu_in2;
    wire [63:0] alu_result;
    wire alu_zero;
    wire [63:0] mem_read_data;
    
    assign pc_plus_4 = pc + 64'd1;
    assign pc_branch = pc + imm_out;
    assign branch_taken = Branch & alu_zero;
    always @(*) begin
        pc_next = branch_taken ? pc_branch : pc_plus_4;
    end
    instruction_memory imem (
        .addr(pc),
        .instruction(instruction)
    );
    control_unit ctrl (
        .opcode(opcode),
        .RegWrite(RegWrite),
        .MemtoReg(MemtoReg),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .Branch(Branch),
        .ALUSrc(ALUSrc),
        .ALUOp(ALUOp)
    );
    register_file rf (
        .clk(clk),
        .reset(reset),
        .RegWrite(RegWrite),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .write_data((MemtoReg) ? mem_read_data : alu_result),
        .read_data1(reg_data1),
        .read_data2(reg_data2)
    );
    immediate_gen immgen (
        .instruction(instruction),
        .imm_out(imm_out)
    );
    alu_control alu_ctrl (
        .ALU_op(ALUOp),
        .funct3(func3),
        .bit30(func7_5),
        .ALUControl(ALUControl)
    );
    assign alu_in2 = (ALUSrc) ? imm_out : reg_data2;
    ALU my_alu (
        .rs1(reg_data1),
        .rs2(alu_in2),
        .alu_control(ALUControl),
        .rd(alu_result),
        .alu_zero(alu_zero)
    );
    data_memory dmem (
        .clk(clk),
        .mem_read(MemRead),
        .mem_write(MemWrite),
        .address(alu_result),
        .write_data(reg_data2),
        .read_data(mem_read_data)
    );
    always @(posedge clk or posedge reset) begin
        if (reset)
            pc <= 64'b0;
        else 
            pc <= pc_next;
    end
endmodule

module cpu_top_tb;
  reg clk;
  reg reset;
  cpu_top UUT (
    .clk(clk),
    .reset(reset)
  );
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end
  initial begin
    $dumpfile("cpu_top_wave.vcd");
    $dumpvars(0, cpu_top_tb);
    reset = 1;
    #10;
    reset = 0;
    $display("Initial values of registers");
    $display("Register x1 = %d", UUT.rf.regs[1]);
    $display("Register x2 = %d", UUT.rf.regs[2]);
    $display("Register x3 = %d", UUT.rf.regs[3]);
    $display("Register x4 = %d", UUT.rf.regs[4]);
    $display("Register x5 = %d", UUT.rf.regs[5]);
    #130;
    $display("Register x6 = %d", UUT.rf.regs[6]);
    $display("Register x7 = %d", UUT.rf.regs[7]);
    $display("Register x8 = %d", UUT.rf.regs[8]);
    $display("Register x9 = %d", UUT.rf.regs[9]);
    $display("memory at address 10 = %d", UUT.dmem.memory[10]);
    $display("memory at address 16 = %d", UUT.dmem.memory[16]);
    $display("Register x10 = %d", UUT.rf.regs[10]);
    $display("Register x11 = %d", UUT.rf.regs[11]);
    $display("Register x12 = %d", UUT.rf.regs[12]);
    $display("Register x0 = %d", UUT.rf.regs[0]);
    $finish;
  end
  always @(posedge clk) begin
    if (!reset)
      $display("Time: %t, PC: %h, Instruction: %b", $time, UUT.pc, UUT.instruction);
  end
endmodule