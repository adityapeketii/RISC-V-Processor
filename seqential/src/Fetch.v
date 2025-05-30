module PC(
    input Clk,reset,
    input [63:0] nxt_pc,
    output reg [63:0] PC
);
    initial begin

        PC <= 64'd0;
        
    end
    always @(posedge Clk or posedge reset) begin
        if(reset)
        PC <= 64'd0;
        else
        PC <= nxt_pc;
    end
    
endmodule 

module Inst_Memory(
    input  [63:0] address,
    output [31:0] instruction
);

    reg [31:0] memory [255:0];

    initial begin
        // Instruction format: [funct7] [rs2] [rs1] [funct3] [rd] [opcode]

        // ADD x1, x2, x3  (x1 = x2 + x3)
        memory[0] = 32'b0000000_00011_00010_000_00001_0110011; 

        // ADD x4, x5, x6  (x4 = x5 + x6)
        memory[1] = 32'b0000000_00101_00110_000_00100_0110011; 
        
        // SUB x7, x4, x1  (x7 = x4 - x1)
        memory[2] = 32'b0100000_00001_00100_000_00111_0110011;

        // AND x4, x5, x6  (x4 = x5 & x6)
        memory[3] = 32'b0000000_00110_00101_111_00100_0110011; 

        // OR x7, x8, x9  (x7 = x8 or x9)
        memory[4] = 32'b0000000_01001_01000_110_00111_0110011; 

        //  beq x14, x7, 4 
        memory[5] = 32'b0000000_01110_00111_000_00100_1100011;

        // AND x4, x5, x6  (x4 = x5 & x6)
         memory[6] = 32'b0000000_00110_00101_111_00100_0110011; 

        // SW x5 16(x10)
        memory[7] = 32'b0000000_01101_01010_011_10000_0100011; 
        
        // LD x7 16(x10)
        memory[8] = 32'b000000010000_01010_011_00111_0000011;

        memory[9] = 32'b0000000_00111_01000_110_01111_0110011;

    end

    assign instruction = memory[address[63:2]];

endmodule

module Fetch(
    input Clk,
    input reset,
    input [63:0] pc_next,
    output reg [63:0] PC ,
    output reg [31:0] instruction
);
    wire [63:0] instruction_addrs;
    wire [31:0] fetch_out ;
    PC Prog_counter(
        .Clk(Clk),
        .reset(reset),
        .nxt_pc(pc_next),
        .PC(instruction_addrs)
    );

    Inst_Memory imem(
        .address(instruction_addrs),
        .instruction(fetch_out)
    );
    always @(*) begin
        PC <= instruction_addrs ;
        instruction <= fetch_out ;
    end 
endmodule