    module instruction_memory(
        input  [63:0]  addr,
        output [31:0]  instruction
    );

        reg [31:0] mem [0:63];

        initial begin
            $readmemb("instructions.txt", mem); 
        end

        assign instruction = mem[addr[5:0]]; 
    endmodule
