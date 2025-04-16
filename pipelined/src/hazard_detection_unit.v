module hazard_detection_unit (
    input wire EX_MemRead,
    input wire [4:0] EX_Rd,
    input wire [4:0] rs1,
    input wire [4:0] rs2,
    output reg PCWrite,
    output reg IF_ID_reg_write,
    output reg ControlStall
);

always @(*) begin
    PCWrite = 1;
    IF_ID_reg_write = 1;
    ControlStall = 0;

    if (EX_MemRead && 
       ((EX_Rd == rs1) || (EX_Rd == rs2))) begin
        PCWrite = 0;       
        IF_ID_reg_write = 0;    
        ControlStall = 1;  
    end
end

endmodule
