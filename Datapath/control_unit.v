module control_unit
(
    input      [6:0] instr_op,   // The 7-bit opcode field from the instruction
    output reg       Branch,
    output reg       MemRead,
    output reg       MemToReg,
    output reg [1:0] ALUOp,
    output reg       MemWrite,
    output reg       ALUSrc,
    output reg       RegWrite
);

    // RISC-V base opcodes (simplified):
    localparam OPCODE_RTYPE = 7'b0110011;  // e.g., add, sub, sll, etc. (R-type)
    localparam OPCODE_LOAD  = 7'b0000011;  // e.g., lw
    localparam OPCODE_STORE = 7'b0100011;  // e.g., sw
    localparam OPCODE_BRANCH= 7'b1100011;  // e.g., beq, bne

    always @* begin
        // Default values (often safer to default to 0)
        Branch   = 1'b0;
        MemRead  = 1'b0;
        MemToReg = 1'b0;
        ALUOp    = 2'b00;
        MemWrite = 1'b0;
        ALUSrc   = 1'b0;
        RegWrite = 1'b0;

        case (instr_op)

            // R-type
            OPCODE_RTYPE: begin
                RegWrite = 1'b1;   // Write back to register file
                ALUSrc   = 1'b0;   // ALU operand 2 from register
                MemToReg = 1'b0;   // ALU result goes to register
                Branch   = 1'b0;   // Not a branch
                MemRead  = 1'b0;   // Not reading from data memory
                MemWrite = 1'b0;   // Not writing to data memory
                ALUOp    = 2'b10;  // ALU control will decode func3/func7
            end

            // Load (e.g., lw)
            OPCODE_LOAD: begin
                RegWrite = 1'b1;
                ALUSrc   = 1'b1;   // Immediate offset
                MemToReg = 1'b1;   // Data memory output to register
                Branch   = 1'b0;
                MemRead  = 1'b1;   // Read from data memory
                MemWrite = 1'b0;
                ALUOp    = 2'b00;  // Typically “add” for address calc
            end

            // Store (e.g., sw)
            OPCODE_STORE: begin
                RegWrite = 1'b0;   // No register file write
                ALUSrc   = 1'b1;   // Immediate offset
                MemToReg = 1'b0;
                Branch   = 1'b0;
                MemRead  = 1'b0;
                MemWrite = 1'b1;   // Write to data memory
                ALUOp    = 2'b00;  // Typically “add” for address calc
            end

            // Branch (e.g., beq)
            OPCODE_BRANCH: begin
                RegWrite = 1'b0;
                ALUSrc   = 1'b0;   // Use register operands
                MemToReg = 1'b0;
                Branch   = 1'b1;   // Branch hardware active
                MemRead  = 1'b0;
                MemWrite = 1'b0;
                ALUOp    = 2'b01;  // Typically “subtract” for comparison
            end

            // Add any additional opcodes (e.g., JAL, JALR, LUI) here

            default: begin
                // For unrecognized opcodes, default everything to safe values
                RegWrite = 1'b0;
                ALUSrc   = 1'b0;
                MemToReg = 1'b0;
                Branch   = 1'b0;
                MemRead  = 1'b0;
                MemWrite = 1'b0;
                ALUOp    = 2'b00;  // Could be a “don’t care”
            end
        endcase
    end

endmodule
