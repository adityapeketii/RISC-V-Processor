`timescale 1ns/1ps

module control_unit_tb;

  // Inputs to the DUT
  reg  [6:0] instr_op;
  
  // Outputs from the DUT
  wire       Branch;
  wire       MemRead;
  wire       MemToReg;
  wire [1:0] ALUOp;
  wire       MemWrite;
  wire       ALUSrc;
  wire       RegWrite;
  
  // Instantiate the control unit
  control_unit dut (
    .instr_op (instr_op),
    .Branch   (Branch),
    .MemRead  (MemRead),
    .MemToReg (MemToReg),
    .ALUOp    (ALUOp),
    .MemWrite (MemWrite),
    .ALUSrc   (ALUSrc),
    .RegWrite (RegWrite)
  );

  // Test vectors: apply each opcode in turn, waiting 10 ns between them
  initial begin
    
    // R-type: 0110011
    instr_op = 7'b0110011; 
    #10;
    

    // Load (e.g., lw): 0000011
    instr_op = 7'b0000011; 
    #10;

    // Store (e.g., sw): 0100011
    instr_op = 7'b0100011; 
    #10;

    // Branch (e.g., beq): 1100011
    instr_op = 7'b1100011;
    #10;

    // Test an unknown opcode
    instr_op = 7'b1111111; 
    #10;
    
    // Done
    $finish;
  end

  // Display signal values every time they change
  initial begin
    $monitor($time, 
             " ns | opcode=%b | Branch=%b, MemRead=%b, MemToReg=%b, ALUOp=%b, MemWrite=%b, ALUSrc=%b, RegWrite=%b",
             instr_op, Branch, MemRead, MemToReg, ALUOp, MemWrite, ALUSrc, RegWrite);
  end
  
endmodule
