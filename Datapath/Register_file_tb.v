`timescale 1ns/1ps

module tb_Register_file;

  reg         clk;
  reg         RegWrite;
  reg  [4:0]  rs1;
  reg  [4:0]  rs2;
  reg  [4:0]  rd;
  reg  [63:0] write_data;
  wire [63:0] read_data1;
  wire [63:0] read_data2;
  
    Register_file uut (
    .clk(clk),
    .RegWrite(RegWrite),
    .rs1(rs1),
    .rs2(rs2),
    .rd(rd),
    .write_data(write_data),
    .read_data1(read_data1),
    .read_data2(read_data2)
  );
  

  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end


  initial begin
    RegWrite   = 0;
    rs1        = 5'd0;
    rs2        = 5'd0;
    rd         = 5'd0;
    write_data = 64'd0;
    #10;

    RegWrite   = 1;
    rd         = 5'd1;
    write_data = 64'd17600;
    #10;
    
    rd         = 5'd2;
    write_data = 64'd298700;
    #10;

    RegWrite = 0;
    #10;
    
    rs1 = 5'd1;
    rs2 = 5'd2;
    #10;
    
    $display("Register 1: %d", read_data1); 
    $display("Register 2: %d", read_data2); 

    RegWrite   = 1;
    rd         = 5'd0;
    write_data = 64'd999;
    #10;
    
    rs1 = 5'd0;
    #10;

    $display("Register 0: %d", read_data1);
    $finish;
  end

endmodule
