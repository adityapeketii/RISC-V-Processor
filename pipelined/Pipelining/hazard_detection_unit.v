module hazard_detection_unit(
    input ID_EX_MemRead,
    input [4:0] ID_EX_RD,
    input [4:0] IF_ID_Rs1,
    input [4:0] IF_ID_Rs2,
    output reg stall
);

    always@(*) begin
        if(ID_EX_MemRead && ((ID_EX_RD == IF_ID_Rs1) || (ID_EX_RD == IF_ID_Rs2)))
            stall = 1'b1;
        else
            stall = 1'b0;
    end
 

endmodule