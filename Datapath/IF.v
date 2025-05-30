module PC(
    input clk,reset,
    input [63:0] nxt_pc,
    output reg [63:0] pc
);

    always @(posedge clk or posedge reset) begin
        if(reset)
        pc <= 64'd0;
        else
        pc <= nxt_pc;
    end
    
endmodule 

module Inst_Memory(
    input  [63:0] address,
    output [31:0] instruction
);

    reg [31:0] memory [255:0];

    initial begin
        // Instruction format: [funct7] [rs2] [rs1] [funct3] [rd] [opcode]

        // memory[0]: add x1, x2, x3
        //   funct7 = 0000000, rs2 = x3 (00011), rs1 = x2 (00010), funct3 = 000, rd = x1 (00001), opcode = 0110011
        memory[0] = 32'b0000000_00011_00010_000_00001_0110011;

        // memory[1]: sub x4, x5, x6
        //   funct7 = 0100000, rs2 = x6 (00110), rs1 = x5 (00101), funct3 = 000, rd = x4 (00100), opcode = 0110011
        memory[1] = 32'b0100000_00110_00101_000_00100_0110011;

        // memory[2]: and x7, x8, x9
        //   funct7 = 0000000, rs2 = x9 (01001), rs1 = x8 (01000), funct3 = 111, rd = x7 (00111), opcode = 0110011
        memory[2] = 32'b0000000_01001_01000_111_00111_0110011;

        // memory[3]: or x10, x11, x12
        //   funct7 = 0000000, rs2 = x12 (01100), rs1 = x11 (01011), funct3 = 110, rd = x10 (01010), opcode = 0110011
        memory[3] = 32'b0000000_01100_01011_110_01010_0110011;

        // memory[4]: ld x13, 0(x14)
        //   I-type: immediate = 000000000000, rs1 = x14 (01110), funct3 = 011, rd = x13 (01101), opcode = 0000011
        memory[4] = 32'b000000000000_01110_011_01101_0000011;

        // memory[5]: sd x15, 4(x16)
        //   S-type: immediate split as imm[11:5] = 0000000, imm[4:0] = 00100, rs2 = x15 (01111), rs1 = x16 (10000), funct3 = 011, opcode = 0100011
        memory[5] = 32'b0000000_01111_10000_011_00100_0100011;

        // memory[6]: beq x17, x18, 8
        memory[6] = 32'b0_000000_10010_10001_000_0010_0_1100011;
        
    end

    assign instruction = memory[address[63:2]];

endmodule

module IF(
    input clk,reset,
    input [63:0] pc_next,
    output [31:0] instruction
);
    wire [63:0] instruction_addrs;

    PC Prog_counter(
        .clk(clk),
        .reset(reset),
        .nxt_pc(pc_next),
        .pc(instruction_addrs)
    );

    Inst_Memory imem(
        .address(instruction_addrs),
        .instruction(instruction)
    );

endmodule


