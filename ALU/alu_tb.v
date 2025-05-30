`timescale 1ns/1ps

module alu_tb;

  reg  [6:0]          func7;
  reg  [2:0]          func3;
  reg  signed [63:0]  rs1;
  reg  signed [63:0]  rs2;
  wire signed [63:0]  rd;
  
  reg [8*20-1:0] opName; 
  
  alu uut (
      .func7(func7),
      .func3(func3),
      .rs1(rs1),
      .rs2(rs2),
      .rd(rd)
  );
  
  initial begin
    $display("Time\t\tTest Operation\t func7   func3\t\t  rs1\t\t       rs2\t\t       rd");
    $monitor("%0t\t%20s\t %b %b\t %h\t %h\t %h", $time, opName, func7, func3, rs1, rs2, rd);
  end
  
  initial begin

    #5;
    
    opName = "Addition";
    rs1   = 64'h0000_0000_0000_000f;
    rs2   = 64'h0000_0000_0000_0001;
    func7 = 7'b0000000; 
    func3 = 3'b000;
    #10;
    
    opName = "Subtraction";
    rs1   = 64'h0000_0000_0000_0005;
    rs2   = 64'h0000_0000_0000_0002;
    func7 = 7'b0100000; 
    func3 = 3'b000;
    #10;

    opName = "Addition Edge case";
    rs1   = 64'h7FFF_FFFF_FFFF_FFFF;
    rs2   = 64'h0000_0000_0000_0001;
    func7 = 7'b0000000; 
    func3 = 3'b000;
    #10;
    
    opName = "Subtraction Edge case";
    rs1   = 64'h8000_0000_0000_0000;
    rs2   = 64'h0000_0000_0000_0001;
    func7 = 7'b0100000;
    func3 = 3'b000;
    #10;
    
   
    opName = "SLT (signed)";
    rs1   = 64'h0000_0000_0000_0002;
    rs2   = 64'h0000_0000_0000_0005;
    func7 = 7'b0000000;
    func3 = 3'b010;
    #10;
    
    opName = "SLTU (unsigned)";
    rs1   = 64'h0000_0000_0000_000F;
    rs2   = 64'h0000_0000_0000_0002;
    func7 = 7'b0000000;
    func3 = 3'b011;
    #10;

    opName = "SLL";
    rs1   = 64'h0000_0000_0000_0001;
    rs2   = 64'h0000_0000_0000_0004; 
    func7 = 7'b0000000;
    func3 = 3'b001;
    #10;
  
    opName = "SRL";
    rs1   = 64'h8000_0000_0000_0000;
    rs2   = 64'h0000_0000_0000_0004;  
    func7 = 7'b0000000;
    func3 = 3'b101;
    #10;

    opName = "SRA";
    rs1   = 64'h8000_0000_0000_0000;
    rs2   = 64'h0000_0000_0000_0004;  
    func7 = 7'b0100000; 
    func3 = 3'b101;
    #10;

    opName = "SLL Edge Max";
    rs1   = 64'h0000_0000_0000_0001;
    rs2   = 64'h0000_0000_0000_003F; 
    func7 = 7'b0000000;
    func3 = 3'b001;
    #10;
    
    opName = "SRL Edge case";
    rs1   = 64'h8000_0000_0000_0000;
    rs2   = 64'h0000_0000_0000_003F; 
    func7 = 7'b0000000;
    func3 = 3'b101;
    #10;
    
    opName = "SRA Edge case";
    rs1   = 64'hFFFF_FFFF_FFFF_FFFE; 
    rs2   = 64'h0000_0000_0000_003F; // shift amount = 63
    func7 = 7'b0100000; 
    func3 = 3'b101;
    #10;
    
    opName = "OR";
    rs1   = 64'hF0F0_F0F0_F0F0_F0F0;
    rs2   = 64'h0F0F_0F0F_0F0F_0F0F;
    func7 = 7'b0000000;
    func3 = 3'b110;
    #10;
    
    opName = "AND";
    rs1   = 64'hFFFF_0000_FFFF_0000;
    rs2   = 64'h00FF_00FF_00FF_00FF;
    func7 = 7'b0000000;
    func3 = 3'b111;
    #10;

    opName = "XOR";
    rs1   = 64'hAAAA_AAAA_AAAA_AAAA;
    rs2   = 64'h5555_5555_5555_5555;
    func7 = 7'b0000000;
    func3 = 3'b100;
    #10;
    
    $display("Test completed.");
    $finish;
  end

endmodule
