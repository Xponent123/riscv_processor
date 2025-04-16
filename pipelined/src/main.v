`timescale 1ns/1ps
`include "instruction_memory.v"
`include "control_unit.v"
`include "register_file.v"
`include "imm_gen.v"
`include "alu_control.v"
`include "alu.v"
`include "data_memory.v"
`include "pipeline_reg.v"
`include "forwarding.v"
`include "hazard_detection_unit.v"

module cpu(
    input clk,
    input reset
);
    reg [63:0] pc;
    wire [31:0] IF_instruction;
    instruction_memory imem (
        .addr(pc),
        .instruction(IF_instruction)
    );
    
    wire [63:0] pc_plus4;
    assign pc_plus4 = pc + 64'd1;
    
    wire PC_Src;
    assign PC_Src = MEM_Branch && MEM_Alu_zero;
    wire flush;
    assign flush = PC_Src;
    
    wire PCWrite;
    wire IF_ID_reg_write;
    
    wire [63:0] ID_pc;
    wire [31:0] ID_instruction;
    IF_ID_reg if_id(
        .clk(clk),
        .reset(reset),
        .flush(flush),               
        .IF_ID_reg_write(IF_ID_reg_write),
        .if_pc(pc),
        .if_instruction(IF_instruction),
        .id_pc(ID_pc),
        .id_instruction(ID_instruction)
    );
    
    wire [63:0] pc_next = (PC_Src) ? MEM_PC : pc_plus4;
    always @(posedge clk or posedge reset) begin
        if (reset)
            pc <= 64'b0;
        else if (PCWrite)
            pc <= pc_next;
    end

    wire [6:0] opcode   = ID_instruction[6:0];
    wire [4:0] rd       = ID_instruction[11:7];
    wire [4:0] rs1      = ID_instruction[19:15];
    wire [4:0] rs2      = ID_instruction[24:20];
    wire [2:0] funct3   = ID_instruction[14:12];
    wire [6:0] funct7   = ID_instruction[31:25];
    wire       bit30    = ID_instruction[30];

    wire RegWrite, MemtoReg, MemRead, MemWrite, Branch, ALUSrc;
    wire [1:0] ALUOp;
    control_unit ctrl(
        .opcode(opcode),
        .RegWrite(RegWrite),
        .MemtoReg(MemtoReg),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .Branch(Branch),
        .ALUSrc(ALUSrc),
        .ALUOp(ALUOp)
    ); 

    
    wire ControlStall;
    
    reg RegWrite_reg, MemtoReg_reg, MemRead_reg, MemWrite_reg, Branch_reg, ALUSrc_reg;
    reg [1:0] ALUOp_reg;
    always @(*) begin
        if (ControlStall) begin
            RegWrite_reg  = 1'b0;
            MemtoReg_reg  = 1'b0;
            MemRead_reg   = 1'b0;
            MemWrite_reg  = 1'b0;
            Branch_reg    = 1'b0;
            ALUSrc_reg    = 1'b0;
            ALUOp_reg     = 2'b00; 
        end else begin
            RegWrite_reg  = RegWrite;
            MemtoReg_reg  = MemtoReg;
            MemRead_reg   = MemRead;
            MemWrite_reg  = MemWrite;
            Branch_reg    = Branch;
            ALUSrc_reg    = ALUSrc;
            ALUOp_reg     = ALUOp;
        end
    end

    wire [63:0] RegData1, RegData2;
    wire [63:0] WB_WriteData;
    wire [4:0] WB_Rd;
    wire WB_RegWrite;
    register_file rf(
        .clk(clk),
        .reset(reset),
        .rs1(rs1),
        .rs2(rs2),
        .rd(WB_Rd),
        .write_data(WB_WriteData),
        .RegWrite(WB_RegWrite),
        .read_data1(RegData1),
        .read_data2(RegData2)
    );
    
    wire [63:0] Imm;
    immediate_gen immgen(
        .instruction(ID_instruction),
        .imm_out(Imm)
    );

    wire EX_RegWrite, EX_MemtoReg, EX_MemRead, EX_MemWrite, EX_Branch, EX_ALUSrc;
    wire [1:0] EX_ALUOp;
    wire [63:0] EX_RegData1, EX_RegData2, EX_Imm, EX_pc;
    wire [4:0] EX_Rs1, EX_Rs2, EX_Rd;
    wire [2:0] EX_Funct3;
    wire EX_Bit30;
    
    ID_EXE_reg id_exe(
        .clk(clk),
        .reset(reset),
        .flush(flush),               
        .RegWrite(RegWrite_reg),
        .MemtoReg(MemtoReg_reg),
        .MemRead(MemRead_reg),
        .MemWrite(MemWrite_reg),
        .Branch(Branch_reg),
        .ALUSrc(ALUSrc_reg),
        .ALUOp(ALUOp_reg),
        .ID_pc(ID_pc),
        .ID_RegData1(RegData1),
        .ID_RegData2(RegData2),
        .ID_Imm(Imm),
        .ID_Rs1(rs1),
        .ID_Rs2(rs2),
        .ID_Rd(rd),
        .ID_funct3(funct3),
        .ID_bit30(bit30),
        .EX_RegWrite(EX_RegWrite),
        .EX_MemtoReg(EX_MemtoReg),
        .EX_MemRead(EX_MemRead),
        .EX_MemWrite(EX_MemWrite),
        .EX_Branch(EX_Branch),
        .EX_ALUSrc(EX_ALUSrc),
        .EX_ALUOp(EX_ALUOp),
        .EX_pc(EX_pc),
        .EX_RegData1(EX_RegData1),
        .EX_RegData2(EX_RegData2),
        .EX_Imm(EX_Imm),
        .EX_Rs1(EX_Rs1),
        .EX_Rs2(EX_Rs2),
        .EX_Rd(EX_Rd),
        .EX_funct3(EX_Funct3),
        .EX_bit30(EX_Bit30)
    );
    
    hazard_detection_unit hdu(
        .EX_MemRead(EX_MemRead),
        .EX_Rd(EX_Rd),
        .rs1(rs1),
        .rs2(rs2),
        .PCWrite(PCWrite),
        .IF_ID_reg_write(IF_ID_reg_write),
        .ControlStall(ControlStall)
    );

    wire [63:0] ALU_IN1, ALU_IN2;
    wire [1:0] ForwardA, ForwardB;
    wire [4:0] MEM_Rd;
    wire MEM_RegWrite;
    forwarding_unit fwd_unit(
        .EX_Rs1(EX_Rs1),
        .EX_Rs2(EX_Rs2),
        .MEM_Rd(MEM_Rd),
        .MEM_RegWrite(MEM_RegWrite),
        .WB_Rd(WB_Rd),
        .WB_RegWrite(WB_RegWrite),
        .ForwardA(ForwardA),
        .ForwardB(ForwardB)
    );
    assign ALU_IN1 = (ForwardA == 2'b10) ? MEM_ALU_result : ((ForwardA == 2'b01) ? WB_WriteData : EX_RegData1);
    assign ALU_IN2 = (ForwardB == 2'b10) ? MEM_ALU_result : ((ForwardB == 2'b01) ? WB_WriteData : EX_RegData2);

    wire [3:0] ALUControl;
    wire [63:0] ALU_result;
    wire zero;
    alu_control alu_ctrl(
        .ALU_op(EX_ALUOp),
        .funct3(EX_Funct3),
        .bit30(EX_Bit30),
        .ALUControl(ALUControl)
    );
    wire [63:0] alu_in2;
    assign alu_in2 = EX_ALUSrc ? EX_Imm : ALU_IN2;
    ALU alu_inst(
        .rs1(ALU_IN1),
        .rs2(alu_in2),
        .alu_control(ALUControl),
        .rd(ALU_result),
        .alu_zero(zero)
    );
    
    wire [63:0] EX_pc_branch;
    assign EX_pc_branch = EX_pc + EX_Imm;
    
    wire [63:0] MEM_ALU_result;
    wire [63:0] MEM_RegData2;
    wire [63:0] MEM_PC;
    EX_MEM_reg ex_mem(
        .clk(clk),
        .reset(reset),
        .flush(flush),               
        .EX_RegWrite(EX_RegWrite),
        .EX_MemtoReg(EX_MemtoReg),
        .EX_MemRead(EX_MemRead),
        .EX_MemWrite(EX_MemWrite),
        .EX_Branch(EX_Branch),
        .Alu_zero(zero),
        .Alu_result(ALU_result),
        .EX_RegData2(ALU_IN2),
        .EX_Rd(EX_Rd),
        .EX_PC(EX_pc_branch),
        .MEM_RegWrite(MEM_RegWrite),
        .MEM_MemtoReg(MEM_MemtoReg),
        .MEM_MemRead(MEM_MemRead),
        .MEM_MemWrite(MEM_MemWrite),
        .MEM_Branch(MEM_Branch),
        .MEM_Alu_zero(MEM_Alu_zero),
        .MEM_Alu_result(MEM_ALU_result),
        .MEM_RegData2(MEM_RegData2),
        .MEM_PC(MEM_PC),
        .MEM_Rd(MEM_Rd)
    );
    
    wire [63:0] MemReadData;
    data_memory dmem(
        .clk(clk),
        .mem_read(MEM_MemRead),
        .mem_write(MEM_MemWrite),
        .write_data(MEM_RegData2),
        .address(MEM_ALU_result),
        .read_data(MemReadData)
    );
    
    wire WB_MemtoReg;
    wire [63:0] WB_Alu_result, WB_MemReadData; 
    MEM_WB_reg mem_wb(
        .clk(clk),
        .reset(reset),
        .MEM_RegWrite(MEM_RegWrite),
        .MEM_MemtoReg(MEM_MemtoReg),
        .MEM_Alu_result(MEM_ALU_result),
        .MemReadData(MemReadData),
        .MEM_Rd(MEM_Rd),
        .WB_RegWrite(WB_RegWrite),
        .WB_MemtoReg(WB_MemtoReg),
        .WB_Alu_result(WB_Alu_result), 
        .WB_MemReadData(WB_MemReadData),
        .WB_Rd(WB_Rd)
    );
    
    assign WB_WriteData = WB_MemtoReg ? WB_MemReadData : WB_Alu_result;
    
endmodule

module cpu_tb;
    reg clk;
    reg reset;
    
    cpu uut (
        .clk(clk),
        .reset(reset)
    );
    
    always #5 clk = ~clk;
    
    initial begin
        $dumpfile("cpu_top_wave.vcd");
        $dumpvars(0, cpu_tb);
        clk = 0;
        reset = 1;
        #10;
        reset = 0;
        #300;
        $display("x5  = %d", uut.rf.regs[5]);
        $display("x6  = %d", uut.rf.regs[6]);
        $display("x7  = %d", uut.rf.regs[7]);
        $display("x8  = %d", uut.rf.regs[8]);
        $display("x9  = %d", uut.rf.regs[9]);
        $display("mem[17] = %d", uut.dmem.memory[17]);
        $display("x10 = %d", uut.rf.regs[10]);
        $display("x11 = %d", uut.rf.regs[11]);
        $display("x12 = %d", uut.rf.regs[12]);
        $display("x13 = %d", uut.rf.regs[13]);
        $display("x14 = %d", uut.rf.regs[14]);
        $display("x15 = %d", uut.rf.regs[15]);
        $display("x16 = %d", uut.rf.regs[16]);
        $display("x17 = %d", uut.rf.regs[17]);
        $display("x0  = %d", uut.rf.regs[0]);
        $finish;
    end
endmodule
