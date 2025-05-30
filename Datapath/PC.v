module PC(
    input clk,reset,
    input [63:0] nxt_pc,
    output [63:0] pc
);

    always @(posedge clk or posedge reset) begin
        if(reset)
        pc <= 64'd0;
        else
        pc <= nxt_pc;
    end
    
endmodule 