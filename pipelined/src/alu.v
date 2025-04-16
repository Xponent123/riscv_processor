`timescale 1ns / 1ps

module ALU (
    input [3:0] alu_control,
    input  [63:0] rs1,
    input  [63:0] rs2,
    output reg [63:0] rd,
    output alu_zero
);

    wire [63:0] and_result;
    wire [63:0] or_result;
    wire [63:0] add_result;
    wire  add_cout;
    wire [63:0] sub_result;
    wire  sub_cout;

    and_gate u_and(.A(rs1), .B(rs2), .Y(and_result));

    or_gate u_or( .A(rs1), .B(rs2), .Y(or_result));

    adder_64bit u_add(.A(rs1), .B(rs2), .Cin(1'b0), .Result(add_result), .Cout(add_cout));

    subtractor_64bit u_sub(.A(rs1), .B(rs2), .Result(sub_result), .Cout(sub_cout));

    always @(*) begin
        case (alu_control)
            4'b0000: rd = and_result;
            4'b0001: rd = or_result;
            4'b0010: rd = add_result;
            4'b0110: rd = sub_result;
            default: rd = 64'd0;
        endcase
    end

    assign alu_zero = (rd == 64'd0);

endmodule

module and_gate(input [63:0] A,B, output [63:0] Y);
    genvar i;
    generate
        for (i = 0; i < 64; i = i + 1) begin
            and (Y[i], A[i], B[i]);
        end
    endgenerate
endmodule

module or_gate(input [63:0] A,B, output [63:0] Y);
    genvar i;
    generate
        for (i = 0; i < 64; i = i + 1) begin
            or (Y[i], A[i], B[i]);
        end
    endgenerate
endmodule

module full_adder(input A, B, Cin, output Sum, Cout);
    wire AxorB;
    xor (AxorB, A, B);
    xor (Sum, AxorB, Cin);
    wire AB, BCin, ACin;
    and (AB, A, B);
    and (BCin, B, Cin);
    and (ACin, A, Cin);
    or (Cout, AB, BCin, ACin);
endmodule

module adder_64bit(input [63:0] A, B, input Cin, output [63:0] Result, output Cout);
    wire [63:0] sum;
    wire [64:0] carry;

    assign carry[0] = Cin;

    genvar i;
    generate
        for (i = 0; i < 64; i = i + 1) begin : adder_loop
            full_adder fa(A[i], B[i], carry[i], sum[i], carry[i+1]);
        end
    endgenerate

    assign Result = sum;
    assign Cout = carry[64];
endmodule

module bitwise_not(input [63:0] A, output [63:0] Result);
    genvar i;
    generate
        for (i = 0; i < 64; i = i + 1) begin
            not (Result[i], A[i]);
        end
    endgenerate
endmodule

module subtractor_64bit(input [63:0] A, B, output [63:0] Result, output Cout);
    wire [63:0] B_compl;
    bitwise_not not_b (.A(B), .Result(B_compl));
    adder_64bit sub (.A(A), .B(B_compl), .Cin(1'b1), .Result(Result), .Cout(Cout));
endmodule


