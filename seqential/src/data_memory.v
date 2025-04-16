`timescale 1ns / 1ps

module data_memory (
    input clk,
    input mem_write,      
    input mem_read,       
    input [63:0] address, 
    input [63:0] write_data, 
    output reg [63:0] read_data
);
    
    reg [63:0] memory [0:255]; // 256 x 64-bit words (double-word addressing)
    
    always @(posedge clk) begin
        if (mem_write) 
            memory[address] <= write_data; // Direct word addressing
    end
    
    always @(*) begin
        if (mem_read) 
            read_data = memory[address]; // Direct word addressing
        else 
            read_data = 64'b0;
    end

endmodule
