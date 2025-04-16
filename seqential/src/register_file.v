module register_file(
    input              clk,
    input              reset,
    input              RegWrite,
    input      [4:0]   rs1,
    input      [4:0]   rs2,
    input      [4:0]   rd,
    input      [63:0]  write_data,
    output     [63:0]  read_data1,
    output     [63:0]  read_data2
);

    reg [63:0] regs [31:0];
    integer i;

    // Combined reset and write logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Initialize registers: preload some values and clear others
            regs[0] <= 64'b0;  // x0 is always 0
            regs[1] <= 64'd10; // Preload as desired
            regs[2] <= 64'd5;
            regs[3] <= 64'd1765;
            regs[4] <= 64'd281;
            regs[5] <= 64'd15;
            for (i = 6; i < 32; i = i + 1) begin
                regs[i] <= 64'b0;
            end
        end
        else if (RegWrite && (rd != 5'd0)) begin
            regs[rd] <= write_data;
        end
    end

    assign read_data1 = (rs1 == 5'd0) ? 64'b0 : regs[rs1];
    assign read_data2 = (rs2 == 5'd0) ? 64'b0 : regs[rs2];

endmodule
