`timescale 1ns / 1ps

module data_memory_tb;

    reg clk;
    reg mem_write;
    reg mem_read;
    reg [63:0] address;
    reg [63:0] write_data;
    wire [63:0] read_data;

    data_memory uut (
        .clk(clk),
        .mem_write(mem_write),
        .mem_read(mem_read),
        .address(address),
        .write_data(write_data),
        .read_data(read_data)
    );

    always #5 clk = ~clk; 

    initial begin
        $dumpfile("data_memory_tb.vcd"); 
        $dumpvars(0, data_memory_tb);

        clk = 0;
        mem_write = 0;
        mem_read = 0;
        address = 0;
        write_data = 0;

        uut.memory[0] = 64'h0000000000000001;
        uut.memory[1] = 64'h0000000000000002;
        uut.memory[2] = 64'h0000000000000003;
        uut.memory[3] = 64'h0000000000000004;

        $display("Initial Memory:");
        $display("mem[0] = %h", uut.memory[0]);
        $display("mem[1] = %h", uut.memory[1]);
        $display("mem[2] = %h", uut.memory[2]);
        $display("mem[3] = %h", uut.memory[3]);

        #10;
        mem_write = 1;
        address = 10; 
        write_data = 64'hDEADBEEFDEADBEEF;
        #10 mem_write = 0;

        $display("Memory After Write:");
        $display("mem[10] = %h", uut.memory[10]); 

        #10;
        mem_read = 1;
        address = 10;
        #10;
        $display("Read Data: %h", read_data);
        mem_read = 0;

        #10;
        mem_write = 1;
        address = 2;
        write_data = 64'hCAFEBABECAFEBABE;
        #10 mem_write = 0;

        #10;
        $display("Final Memory:");
        $display("mem[10] = %h", uut.memory[10]); 
        $display("mem[2] = %h", uut.memory[2]); 

        #10 $finish;
    end

endmodule
