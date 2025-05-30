module control_hazard_beq (
    input wire Branch,  // Asserted for branch instructions in the pipeline
    input wire Zero,    // ALU Zero flag from Execute stage
    output reg Flush  // Signal to flush IF/ID and ID/EX registers
);
  always @(*) begin
    if (Branch && Zero)
      Flush = 1'b1;
    else
      Flush = 1'b0;
  end
endmodule
