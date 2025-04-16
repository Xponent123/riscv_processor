module control_unit (
    input  [6:0] opcode,
    output RegWrite,
    output MemtoReg,
    output MemRead,
    output MemWrite,
    output Branch,
    output ALUSrc,
    output [1:0] ALUOp
);
    wire op6, op5, op4, op3, op2, op1, op0;
    assign op6 = opcode[6];
    assign op5 = opcode[5];
    assign op4 = opcode[4];
    assign op3 = opcode[3];
    assign op2 = opcode[2];
    assign op1 = opcode[1];
    assign op0 = opcode[0];

    wire n_op6, n_op5, n_op4, n_op3, n_op2;
    not n1(n_op6, op6);
    not n2(n_op5, op5);
    not n3(n_op4, op4);
    not n4(n_op3, op3);
    not n5(n_op2, op2);

    wire is_rtype;
    and a_rtype(is_rtype, n_op6, op5, op4, n_op3, n_op2, op1, op0);

    wire is_ld;
    and a_ld(is_ld, n_op6, n_op5, n_op4, n_op3, n_op2, op1, op0);

    wire is_sd;
    and a_sd(is_sd, n_op6, op5, n_op4, n_op3, n_op2, op1, op0);

    wire is_beq;
    and a_beq(is_beq, op6, op5, n_op4, n_op3, n_op2, op1, op0);

    or o_regwrite(RegWrite, is_rtype, is_ld);
    assign MemtoReg = is_ld;
    assign MemRead = is_ld;
    assign MemWrite = is_sd;
    assign Branch = is_beq;
    or o_alusrc(ALUSrc, is_ld, is_sd);
    assign ALUOp[1] = is_rtype;
    assign ALUOp[0] = is_beq;

endmodule
