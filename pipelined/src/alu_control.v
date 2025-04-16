module alu_control (
    input  [1:0] ALU_op,
    input  [2:0] funct3,
    input        bit30,
    output [3:0] ALUControl
);
    wire [3:0] D0 = 4'b0010; 
    wire [3:0] D1 = 4'b0110; 

    wire f3_2, f3_1, f3_0;
    assign f3_2 = funct3[2];
    assign f3_1 = funct3[1];
    assign f3_0 = funct3[0];

    wire n_f3_2, n_f3_1, n_f3_0;
    not u_nf3_2(n_f3_2, f3_2);
    not u_nf3_1(n_f3_1, f3_1);
    not u_nf3_0(n_f3_0, f3_0);

    wire is_000, is_111, is_110;
    and u_is_000(is_000, n_f3_2, n_f3_1, n_f3_0); 
    and u_is_111(is_111, f3_2, f3_1, f3_0);         
    and u_is_110(is_110, f3_2, f3_1, n_f3_0);         

    
    wire or_temp1, or_temp, sel_default;
    or  u_or1(or_temp1, is_000, is_111);
    or  u_or2(or_temp, or_temp1, is_110);
    not u_sel_default(sel_default, or_temp);

    wire D2_3;
    assign D2_3 = sel_default;

    wire D2_2_is000, D2_2;
    and u_and_D2_2(D2_2_is000, is_000, bit30);
    or  u_or_D2_2(D2_2, D2_2_is000, sel_default);

    wire D2_1;
    or  u_or_D2_1(D2_1, is_000, sel_default);

    wire D2_0;
    or  u_or_D2_0(D2_0, is_110, sel_default);

    wire [3:0] D2;
    assign D2 = {D2_3, D2_2, D2_1, D2_0};

    mux_alu_control mux_inst(.in0(D0), .in1(D1), .in2(D2), .sel(ALU_op), .out(ALUControl));
endmodule

module mux_alu_control(
    input  [3:0] in0,
    input  [3:0] in1,
    input  [3:0] in2,
    input  [1:0] sel,
    output [3:0] out
);
    
    wire s0, s1, s2, s_default;
    assign s0 = (~sel[1] & ~sel[0]);
    assign s1 = (~sel[1] &  sel[0]);
    assign s2 = ( sel[1] & ~sel[0]);
    assign s_default = (sel[1] & sel[0]); 

    genvar i;
    generate
        for(i = 0; i < 4; i = i + 1) begin: mux_loop
            wire a, b, c, d;
            and u_a(a, in0[i], s0);
            and u_b(b, in1[i], s1);
            and u_c(c, in2[i], s2);
            and u_d(d, 1'b0, s_default); 
            or  u_out(out[i], a, b, c, d);
        end
    endgenerate
endmodule
