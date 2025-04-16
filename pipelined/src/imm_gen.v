module immediate_gen(
    input  [31:0] instruction,
    output [63:0] imm_out
);
    wire [6:0] opcode = instruction[6:0];
    wire sign_bit = instruction[31];
    wire [11:0] imm_I_field = instruction[31:20];
    wire [63:0] imm_I = {{52{sign_bit}}, imm_I_field};
    wire [11:0] imm_S_field = {instruction[31:25], instruction[11:7]};
    wire [63:0] imm_S = {{52{sign_bit}}, imm_S_field};
    wire [12:0] imm_B_field = {instruction[31], instruction[7], instruction[30:25], instruction[11:8]};
    wire [63:0] imm_B = {{52{sign_bit}}, imm_B_field};

    wire n_op6, n_op5, n_op4, n_op3, n_op2;
    not u_nop6(n_op6, instruction[6]);
    not u_nop5(n_op5, instruction[5]);
    not u_nop4(n_op4, instruction[4]);
    not u_nop3(n_op3, instruction[3]);
    not u_nop2(n_op2, instruction[2]);

    wire sel_I_temp, sel_S_temp, sel_B_temp;
    wire temp_I1, temp_I2;
    and u_temp_I1(temp_I1, n_op6, n_op5, n_op4, n_op3, n_op2);
    and u_temp_I2(temp_I2, instruction[1], instruction[0]);
    and u_sel_I(sel_I_temp, temp_I1, temp_I2);
    wire temp_S1, temp_S2;
    and u_temp_S1(temp_S1, n_op6, instruction[5], n_op4, n_op3, n_op2);
    and u_temp_S2(temp_S2, instruction[1], instruction[0]);
    and u_sel_S(sel_S_temp, temp_S1, temp_S2);
    wire temp_B1, temp_B2;
    and u_temp_B1(temp_B1, instruction[6], instruction[5], n_op4, n_op3, n_op2);
    and u_temp_B2(temp_B2, instruction[1], instruction[0]);
    and u_sel_B(sel_B_temp, temp_B1, temp_B2);

    wire or_sel = sel_I_temp | sel_S_temp | sel_B_temp;
    wire default_case = ~or_sel;
    wire [1:0] mux_sel;
    assign mux_sel[1] = sel_B_temp | default_case;
    assign mux_sel[0] = sel_S_temp | default_case;

    mux_imm_gen mux_inst(
        .in0(imm_I),
        .in1(imm_S),
        .in2(imm_B),
        .in3(64'b0),
        .sel(mux_sel),
        .out(imm_out)
    );
endmodule

module mux_imm_gen(
    input  [63:0] in0,
    input  [63:0] in1,
    input  [63:0] in2,
    input  [63:0] in3,
    input  [1:0] sel,
    output [63:0] out
);
    genvar i;
    generate
        for(i=0; i<64; i=i+1) begin: mux_loop
            wire t0, t1, t2, t3;
            and u_a0(t0, in0[i], ~sel[1], ~sel[0]);
            and u_a1(t1, in1[i], ~sel[1], sel[0]);
            and u_a2(t2, in2[i], sel[1], ~sel[0]);
            and u_a3(t3, in3[i], sel[1], sel[0]);
            or u_or(out[i], t0, t1, t2, t3);
        end
    endgenerate
endmodule
