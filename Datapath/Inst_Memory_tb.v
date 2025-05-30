`timescale 1ns/1ps

module tb_inst_memory;

  // Declare testbench signals.
  reg  [31:0] address;
  wire [31:0] instruction;

  // Instantiate the Inst_Memory module.
  Inst_Memory uut (
    .address(address),
    .instruction(instruction)
  );

  initial begin
    // Print a header for the output.
    $display("Time\tAddress\t\tInstruction");
    $monitor("%0t\t%h\t%b", $time, address, instruction);

    // Test various addresses.
    // Since the module uses word addressing (address[31:2]),
    // an address of 0 fetches memory[0], 4 fetches memory[1], 8 fetches memory[2], etc.
    address = 32'd0;    // Expected to fetch memory[0]: add x1, x2, x3
    #10 address = 32'd4;  // Expected to fetch memory[1]: sub x4, x5, x6
    #10 address = 32'd8;  // Expected to fetch memory[2]: and x7, x8, x9
    #10 address = 32'd12; // Expected to fetch memory[3]: or x10, x11, x12
    #10 address = 32'd16; // Expected to fetch memory[4]: ld x13, 0(x14)
    #10 address = 32'd20; // Expected to fetch memory[5]: sd x15, 4(x16)
    #10 address = 32'd24; // Expected to fetch memory[6]: beq x17, x18, 8
    #10 $finish;
  end

endmodule
