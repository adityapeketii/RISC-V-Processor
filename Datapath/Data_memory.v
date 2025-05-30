module Data_memory(
    input clk,
    input MemRead,
    input MemWrite,
    input [63:0] addr,
    input [63:0] write_data,
    output [63:0] read_data
);

    reg [63:0] memory [0:255];

    assign read_data = MemRead ? memory[addr[63:3]] : 64'd0;

    always@(posedge clk) begin
        if(MemWrite)
            memory[addr[63:3]] <= write_data;
    end

endmodule