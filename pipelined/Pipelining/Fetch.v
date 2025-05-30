module PC(
    input Clk,reset,
    input stall,
    input [63:0] nxt_pc,
    output reg [63:0] PC
);
    initial begin

        PC <= 64'd0;
        
    end
    always @(posedge Clk or posedge reset) begin
        if(reset)
        PC <= 64'd0;
        else if(stall)
        PC <= PC;
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

        // ADD x1, x2, x3  (x1 = x2 + x3) Expected=5
        memory[0] = 32'b0000000_00011_00010_000_00001_0110011; 

        // ADD x4, x5, x6  (x4 = x5 + x6) Expected=11
        memory[1] = 32'b0000000_00101_00110_000_00100_0110011; 
        
        // SUB x7, x4, x1  (x7 = x4 - x1) Expected= 6
        memory[2] = 32'b0100000_00001_00100_000_00111_0110011;

        // AND x8, x5, x6  (x8 = x5 & x6) Expected=4
        memory[3] = 32'b0000000_00110_00101_111_01000_0110011; 
        
        // SW x13 16(x10)
        memory[4] = 32'b0000000_01101_01010_011_10000_0100011; 

        // LD x7 16(x10) Expected=6
        memory[5] = 32'b000000010000_01010_011_00111_0000011;
        
        // OR x8, x7, x9  (x8 = x7 or x9) Expected=15
        memory[6] = 32'b0000000_00111_01001_110_01000_0110011; 


        // AND x5, x5, x6  (x5 = x5 & x6) Expected= 4
         memory[7] = 32'b0000000_00110_00101_111_00101_0110011; 
         
         // ADD x20, x20, x3  (x20 = x20 + x3) Expected=4
         memory[8] = 32'b0000000_10100_00011_000_10100_0110011; 
         
         // ADD x20, x20, x21  (x20 = x20 + x21) Expected=13
         memory[9] = 32'b0000000_10100_10101_000_10100_0110011; 
         
         // ADD x20, x20, x22  (x20 = x20 + x22) Expected=23
         memory[10] = 32'b0000000_10100_10110_000_10100_0110011;
         
         // BEQ X23 x22 +4
        memory[11] = 32'b0_000000_10111_10110_000_00100_1100011;

         // AND x20, x5, x6  (x20 = x5 & x6) Expected = 4 // Not to be called
        memory[12] = 32'b0000000_00110_00101_111_10110_0110011; 

         // SUB x26, x25, x24  (x26 = x25 - x24) Expected= -1
        memory[13] = 32'b0100000_11000_11001_000_11010_0110011; 

         // SW x22 16(x10)
        memory[14] = 32'b0000000_10110_01010_011_10000_0100011; 

        // SW x20 16(x10)
        memory[15] = 32'b0000000_10100_01010_011_10000_0100011; 

        // LD x7 16(x10) Expected= value in x20
        memory[16] = 32'b000000010000_01010_011_00111_0000011;

    end

    assign instruction = memory[address[63:2]];

endmodule

module Fetch(
    input Clk,
    input reset,
    input stall,
    input [63:0] pc_next,
    output reg [63:0] PC ,
    output reg [31:0] instruction
);
    wire [63:0] instruction_addrs;
    wire [31:0] fetch_out ;
    PC Prog_counter(
        .Clk(Clk),
        .reset(reset),
        .stall(stall),
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