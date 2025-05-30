`timescale 1ns/1ps

module tb_Data_memory;
  reg         clk;
  reg         MemRead;
  reg         MemWrite;
  reg  [63:0] addr;
  reg  [63:0] write_data;
  wire [63:0] read_data;

  Data_memory uut (
    .clk(clk),
    .MemRead(MemRead),
    .MemWrite(MemWrite),
    .addr(addr),
    .write_data(write_data),
    .read_data(read_data)
  );
  
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end
  
  initial begin
    MemRead   = 0;
    MemWrite  = 0;
    addr      = 64'd0;
    write_data = 64'd0;

    #10;

    MemWrite  = 1;
    addr      = 64'd8;     
    write_data = 64'd12345;
    #10;
    
    MemWrite = 0;
    #10;
    
    MemRead = 1;
    addr    = 64'd8;
    #10;
    $display("At address %d, read_data = %d", addr, read_data);
    
    MemRead  = 0;
    MemWrite = 1;
    addr     = 64'd16;
    write_data = 64'd98765;
    #10;
    
    MemWrite = 0;
    #10;
    
    MemRead = 1;
    addr    = 64'd16;
    #10;
    $display("At address %d, read_data = %d", addr, read_data);
    
    // Attempt to read from an address that was not written (address 24 bytes, index = 3)
    addr    = 64'd24;
    #10;
    $display("At address %d, read_data = %d", addr, read_data);
    
    $finish;
  end

endmodule
