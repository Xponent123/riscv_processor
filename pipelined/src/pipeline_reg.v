`timescale 1ns/1ps

module IF_ID_reg(
    input clk,
    input reset,
    input flush,              
    input IF_ID_reg_write,
    input [63:0] if_pc,
    input [31:0] if_instruction,
    output reg [63:0] id_pc,
    output reg [31:0] id_instruction
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            id_pc <= 64'b0;
            id_instruction <= 32'b0;
        end else if (flush) begin
            id_pc <= 64'b0;
            id_instruction <= 32'b0;
        end else if (IF_ID_reg_write) begin
            id_pc <= if_pc;
            id_instruction <= if_instruction;
        end
    end
endmodule

module ID_EXE_reg(
    input clk,
    input reset,
    input flush,              
    input RegWrite,
    input MemtoReg,
    input MemRead,
    input MemWrite,
    input Branch,
    input ALUSrc,
    input [1:0] ALUOp,
    input [63:0] ID_pc,
    input [63:0] ID_RegData1,
    input [63:0] ID_RegData2,
    input [63:0] ID_Imm,
    input [4:0] ID_Rs1,
    input [4:0] ID_Rs2,
    input [4:0] ID_Rd,
    input [2:0] ID_funct3,
    input ID_bit30,
    output reg EX_RegWrite,
    output reg EX_MemtoReg,
    output reg EX_MemRead,
    output reg EX_MemWrite,
    output reg EX_Branch,
    output reg EX_ALUSrc,
    output reg [1:0] EX_ALUOp,
    output reg [63:0] EX_pc,
    output reg [63:0] EX_RegData1,
    output reg [63:0] EX_RegData2,
    output reg [63:0] EX_Imm,
    output reg [4:0] EX_Rs1,
    output reg [4:0] EX_Rs2,
    output reg [4:0] EX_Rd,
    output reg [2:0] EX_funct3,
    output reg EX_bit30
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            EX_RegWrite   <= 1'b0;
            EX_MemtoReg   <= 1'b0;
            EX_MemRead    <= 1'b0;
            EX_MemWrite   <= 1'b0;
            EX_Branch     <= 1'b0;
            EX_ALUSrc     <= 1'b0;
            EX_ALUOp      <= 2'b00;
            EX_pc         <= 64'b0;
            EX_RegData1   <= 64'b0;
            EX_RegData2   <= 64'b0;
            EX_Imm        <= 64'b0;
            EX_Rs1        <= 5'b0;
            EX_Rs2        <= 5'b0;
            EX_Rd         <= 5'b0;
            EX_funct3     <= 3'b0;
            EX_bit30      <= 1'b0;
        end else if (flush) begin
            // Flush: replace instruction with no-op by clearing all signals.
            EX_RegWrite   <= 1'b0;
            EX_MemtoReg   <= 1'b0;
            EX_MemRead    <= 1'b0;
            EX_MemWrite   <= 1'b0;
            EX_Branch     <= 1'b0;
            EX_ALUSrc     <= 1'b0;
            EX_ALUOp      <= 2'b00;
            EX_pc         <= 64'b0;
            EX_RegData1   <= 64'b0;
            EX_RegData2   <= 64'b0;
            EX_Imm        <= 64'b0;
            EX_Rs1        <= 5'b0;
            EX_Rs2        <= 5'b0;
            EX_Rd         <= 5'b0;
            EX_funct3     <= 3'b0;
            EX_bit30      <= 1'b0;
        end else begin
            EX_RegWrite   <= RegWrite;
            EX_MemtoReg   <= MemtoReg;
            EX_MemRead    <= MemRead;
            EX_MemWrite   <= MemWrite;
            EX_Branch     <= Branch;
            EX_ALUSrc     <= ALUSrc;
            EX_ALUOp      <= ALUOp;
            EX_pc         <= ID_pc;
            EX_RegData1   <= ID_RegData1;
            EX_RegData2   <= ID_RegData2;
            EX_Imm        <= ID_Imm;
            EX_Rs1        <= ID_Rs1;
            EX_Rs2        <= ID_Rs2;
            EX_Rd         <= ID_Rd;
            EX_funct3     <= ID_funct3;
            EX_bit30      <= ID_bit30;
        end
    end
endmodule

module EX_MEM_reg(
    input clk,
    input reset,
    input flush,              
    input EX_RegWrite,
    input EX_MemtoReg,
    input EX_MemRead,
    input EX_MemWrite,
    input EX_Branch,
    input Alu_zero,
    input [63:0] Alu_result,
    input [63:0] EX_RegData2,
    input [4:0] EX_Rd,
    input [63:0] EX_PC,
    output reg MEM_RegWrite,
    output reg MEM_MemtoReg,
    output reg MEM_MemRead,
    output reg MEM_MemWrite,
    output reg MEM_Branch,
    output reg MEM_Alu_zero,
    output reg [63:0] MEM_Alu_result,
    output reg [63:0] MEM_RegData2,
    output reg [4:0] MEM_Rd,
    output reg [63:0] MEM_PC
);
    always @(posedge clk or posedge reset) begin
        if(reset) begin
            MEM_RegWrite   <= 1'b0;
            MEM_MemtoReg   <= 1'b0;
            MEM_MemRead    <= 1'b0;
            MEM_MemWrite   <= 1'b0;
            MEM_Branch     <= 1'b0;
            MEM_Alu_zero   <= 1'b0;
            MEM_Alu_result <= 64'b0;
            MEM_RegData2   <= 64'b0;
            MEM_Rd         <= 5'b0;
            MEM_PC         <= 64'b0;
        end else if (flush) begin
            MEM_RegWrite   <= 1'b0;
            MEM_MemtoReg   <= 1'b0;
            MEM_MemRead    <= 1'b0;
            MEM_MemWrite   <= 1'b0;
            MEM_Branch     <= 1'b0;
            MEM_Alu_zero   <= 1'b0;
            MEM_Alu_result <= 64'b0;
            MEM_RegData2   <= 64'b0;
            MEM_Rd         <= 5'b0;
            MEM_PC         <= 64'b0;
        end else begin
            MEM_RegWrite   <= EX_RegWrite;
            MEM_MemtoReg   <= EX_MemtoReg;
            MEM_MemRead    <= EX_MemRead;
            MEM_MemWrite   <= EX_MemWrite;
            MEM_Branch     <= EX_Branch;
            MEM_Alu_zero   <= Alu_zero;
            MEM_Alu_result <= Alu_result;
            MEM_RegData2   <= EX_RegData2;
            MEM_Rd         <= EX_Rd;
            MEM_PC         <= EX_PC;
        end 
    end
endmodule

module MEM_WB_reg(
    input clk,
    input reset,
    input MEM_RegWrite,
    input MEM_MemtoReg,
    input [63:0] MEM_Alu_result,
    input [63:0] MemReadData,
    input [4:0] MEM_Rd,
    output reg WB_RegWrite,
    output reg WB_MemtoReg,
    output reg [63:0] WB_Alu_result,
    output reg [63:0] WB_MemReadData,
    output reg [4:0] WB_Rd
);
    always @(posedge clk or posedge reset) begin
        if(reset) begin
            WB_RegWrite    <= 1'b0;
            WB_MemtoReg    <= 1'b0;
            WB_Alu_result  <= 64'b0;
            WB_MemReadData <= 64'b0;
            WB_Rd          <= 5'b0;
        end else begin
            WB_RegWrite    <= MEM_RegWrite;
            WB_MemtoReg    <= MEM_MemtoReg;
            WB_Alu_result  <= MEM_Alu_result;
            WB_MemReadData <= MemReadData;
            WB_Rd          <= MEM_Rd;
        end
    end
endmodule
