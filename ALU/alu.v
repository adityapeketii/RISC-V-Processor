module mux2to1 (
    input a, b, sel, 
    output out
);
    wire nsel, temp1, temp2;
    not (nsel, sel);
    and (temp1, a, nsel);
    and (temp2, b, sel);
    or  (out, temp1, temp2);
endmodule

module mux2to1_64(
    input  [63:0] a, b,
    input         sel,
    output [63:0] out
);
    assign out = sel ? b : a;
endmodule


module and_64bit(
    input [63:0] a,
    input [63:0] b,
    output [63:0] z
);
    genvar i;
    generate
        for(i = 0; i < 64; i = i + 1) begin : and_64
            and(z[i], a[i], b[i]);
        end
    endgenerate
endmodule


module or_64bit(
    input [63:0] a, b,
    output [63:0] z
);
    genvar i;
    generate
        for(i = 0; i < 64; i = i + 1) begin : or_64
            or(z[i], a[i], b[i]);
        end
    endgenerate
endmodule

module xor_64bit(
    input [63:0] a, b,
    output [63:0] z
);
    genvar i;
    generate
        for(i = 0; i < 64; i = i + 1) begin : xor_64
            xor(z[i], a[i], b[i]);
        end
    endgenerate
endmodule

module fulladder(
    output sum, 
    output cout, 
    input a, b, cin
);
    wire p, g, t;
    xor (p, a, b);
    xor (sum, p, cin);
    and (g, a, b);
    and (t, p, cin);
    or  (cout, g, t);
endmodule

module adder_subtractor_64bit(
    output [63:0] sum,
    output cout,
    input signed [63:0] a,
    input signed [63:0] b,
    input mode  // 0: addition, 1: subtraction
);
    wire [63:0] b_mode;  // Selected b based on mode
    wire cin;
    wire [64:0] carry;
    
    
    // For subtraction, cin is 1 (to complete the two's complement conversion)
    assign cin = mode;
    assign carry[0] = cin;
    
    genvar i;
    generate
        for(i = 0; i < 64; i = i + 1) begin : fulladder_loop
            xor(b_mode[i], b[i], cin);
            fulladder fa(
                .sum(sum[i]),
                .cout(carry[i+1]),
                .a(a[i]),
                .b(b_mode[i]),
                .cin(carry[i])
            );
        end
    endgenerate
    
    assign cout = carry[64];
endmodule

module slt_sltu_64bit(
    input [63:0] a, b,
    output slt,    // 1 if (signed) a < b
    output sltu    // 1 if (unsigned) a < b
);
    wire [63:0] difference;
    wire cout;
    // Subtract b from a.
    adder_subtractor_64bit sub_inst(
        .a(a),
        .b(b),
        .mode(1'b1), // Always subtraction for comparison
        .sum(difference),
        .cout(cout)
    );
    assign slt  = difference[63]; // Negative difference => a < b (signed)
    assign sltu = ~cout;         // No carry => a < b (unsigned)
endmodule


module sll_64bit (
    input [63:0] A,
    input [4:0] shift,
    output [63:0] Out
);
    wire [63:0] stage0, stage1, stage2, stage3, stage4;
    genvar i;
    
    generate
        for (i = 0; i < 64; i = i + 1) begin : stage0_loop
            wire in0, in1;
            assign in0 = A[i];
            assign in1 = (i == 0) ? 1'b0 : A[i-1];
            mux2to1 mux0 (.a(in0), .b(in1), .sel(shift[0]), .out(stage0[i]));
        end
    endgenerate
    
    generate
        for (i = 0; i < 64; i = i + 1) begin : stage1_loop
            wire in0, in1;
            assign in0 = stage0[i];
            assign in1 = (i < 2) ? 1'b0 : stage0[i-2];
            mux2to1 mux1 (.a(in0), .b(in1), .sel(shift[1]), .out(stage1[i]));
        end
    endgenerate
    
    generate
        for (i = 0; i < 64; i = i + 1) begin : stage2_loop
            wire in0, in1;
            assign in0 = stage1[i];
            assign in1 = (i < 4) ? 1'b0 : stage1[i-4];
            mux2to1 mux2 (.a(in0), .b(in1), .sel(shift[2]), .out(stage2[i]));
        end
    endgenerate
    
    generate
        for (i = 0; i < 64; i = i + 1) begin : stage3_loop
            wire in0, in1;
            assign in0 = stage2[i];
            assign in1 = (i < 8) ? 1'b0 : stage2[i-8];
            mux2to1 mux3 (.a(in0), .b(in1), .sel(shift[3]), .out(stage3[i]));
        end
    endgenerate

    generate
        for (i = 0; i < 64; i = i + 1) begin : stage4_loop
            wire in0, in1;
            assign in0 = stage3[i];
            assign in1 = (i < 16) ? 1'b0 : stage3[i-16];
            mux2to1 mux4 (.a(in0), .b(in1), .sel(shift[4]), .out(stage4[i]));
        end
    endgenerate
    
    assign Out = stage4;
endmodule

module srl_64bit (
    input [63:0] A,
    input [4:0] shift,
    output [63:0] Out
);
    wire [63:0] stage0, stage1, stage2, stage3, stage4;
    genvar i;
    
    generate
        for (i = 0; i < 64; i = i + 1) begin : stage0_loop
            wire in0, in1;
            assign in0 = A[i];
            assign in1 = (i < 63) ? A[i+1] : 1'b0;
            mux2to1 mux0 (.a(in0), .b(in1), .sel(shift[0]), .out(stage0[i]));
        end
    endgenerate
    
    generate
        for (i = 0; i < 64; i = i + 1) begin : stage1_loop
            wire in0, in1;
            assign in0 = stage0[i];
            assign in1 = (i < 62) ? stage0[i+2] : 1'b0;
            mux2to1 mux1 (.a(in0), .b(in1), .sel(shift[1]), .out(stage1[i]));
        end
    endgenerate
    
    generate
        for (i = 0; i < 64; i = i + 1) begin : stage2_loop
            wire in0, in1;
            assign in0 = stage1[i];
            assign in1 = (i < 60) ? stage1[i+4] : 1'b0;
            mux2to1 mux2 (.a(in0), .b(in1), .sel(shift[2]), .out(stage2[i]));
        end
    endgenerate
    
    generate
        for (i = 0; i < 64; i = i + 1) begin : stage3_loop
            wire in0, in1;
            assign in0 = stage2[i];
            assign in1 = (i < 56) ? stage2[i+8] : 1'b0;
            mux2to1 mux3 (.a(in0), .b(in1), .sel(shift[3]), .out(stage3[i]));
        end
    endgenerate
    
    // Stage 4: Shift right by 16
    generate
        for (i = 0; i < 64; i = i + 1) begin : stage4_loop
            wire in0, in1;
            assign in0 = stage3[i];
            assign in1 = (i < 48) ? stage3[i+16] : 1'b0;
            mux2to1 mux4 (.a(in0), .b(in1), .sel(shift[4]), .out(stage4[i]));
        end
    endgenerate
    
    assign Out = stage4;
endmodule

module sra_64bit (
    input [63:0] A,
    input [4:0] shift,
    output [63:0] Out
);
    wire [63:0] stage0, stage1, stage2, stage3, stage4;
    genvar i;
    
    generate
        for (i = 0; i < 64; i = i + 1) begin : stage0_loop
            wire in0, in1;
            assign in0 = A[i];
            // For the last bit, use the sign bit (A[63]) instead of 0.
            assign in1 = (i < 63) ? A[i+1] : A[63];
            mux2to1 mux0 (.a(in0), .b(in1), .sel(shift[0]), .out(stage0[i]));
        end
    endgenerate
    
    generate
        for (i = 0; i < 64; i = i + 1) begin : stage1_loop
            wire in0, in1;
            assign in0 = stage0[i];
            assign in1 = (i < 62) ? stage0[i+2] : stage0[63];
            mux2to1 mux1 (.a(in0), .b(in1), .sel(shift[1]), .out(stage1[i]));
        end
    endgenerate
    
    generate
        for (i = 0; i < 64; i = i + 1) begin : stage2_loop
            wire in0, in1;
            assign in0 = stage1[i];
            assign in1 = (i < 60) ? stage1[i+4] : stage1[63];
            mux2to1 mux2 (.a(in0), .b(in1), .sel(shift[2]), .out(stage2[i]));
        end
    endgenerate
    
    generate
        for (i = 0; i < 64; i = i + 1) begin : stage3_loop
            wire in0, in1;
            assign in0 = stage2[i];
            assign in1 = (i < 56) ? stage2[i+8] : stage2[63];
            mux2to1 mux3 (.a(in0), .b(in1), .sel(shift[3]), .out(stage3[i]));
        end
    endgenerate
    
    generate
        for (i = 0; i < 64; i = i + 1) begin : stage4_loop
            wire in0, in1;
            assign in0 = stage3[i];
            assign in1 = (i < 48) ? stage3[i+16] : stage3[63];
            mux2to1 mux4 (.a(in0), .b(in1), .sel(shift[4]), .out(stage4[i]));
        end
    endgenerate
    
    assign Out = stage4;
endmodule

module alu (
    input  [6:0]           func7,      
    input  [2:0]           func3,      
    input  signed [63:0]   rs1,        
    input  signed [63:0]   rs2,        
    output reg signed [63:0] rd       
);
    
    wire [63:0] add_result;
    wire [63:0] sub_result;
    wire [63:0] sll_result;
    wire [63:0] srl_result;
    wire [63:0] sra_result;
    wire [63:0] and_result;
    wire [63:0] or_result;
    wire [63:0] xor_result;
    wire        slt_result;
    wire        sltu_result;
    
    adder_subtractor_64bit add_inst (
        .a(rs1),
        .b(rs2),
        .mode(1'b0),  // Addition
        .sum(add_result),
        .cout() 
    );
    
    adder_subtractor_64bit sub_inst (
        .a(rs1),
        .b(rs2),
        .mode(1'b1),  // Subtraction
        .sum(sub_result),
        .cout() 
    );
    
    // Logical operations
    and_64bit and_inst (.a(rs1), .b(rs2), .z(and_result));
    or_64bit  or_inst  (.a(rs1), .b(rs2), .z(or_result));
    xor_64bit xor_inst (.a(rs1), .b(rs2), .z(xor_result));
    
    //Shift units
    sll_64bit sll_inst (.A(rs1), .shift(rs2[4:0]), .Out(sll_result));
    srl_64bit srl_inst (.A(rs1), .shift(rs2[4:0]), .Out(srl_result));
    sra_64bit sra_inst (.A(rs1), .shift(rs2[4:0]), .Out(sra_result));
    
    // SLT/SLTU unit
    slt_sltu_64bit slt_unit (
        .a(rs1),
        .b(rs2),
        .slt(slt_result),
        .sltu(sltu_result)
    );
    
    // ALU Operation Selection
    always @(*) begin
        case (func3)
            3'b000: rd = func7[5] ? sub_result : add_result; // ADD (func7[5]==0) or SUB (func7[5]==1)
            3'b001: rd = sll_result;                           // SLL
            3'b010: rd = {{63{1'b0}}, slt_result};             // SLT (signed)
            3'b011: rd = {{63{1'b0}}, sltu_result};            // SLTU (unsigned)
            3'b100: rd = xor_result;                           // XOR
            3'b101: rd = func7[5] ? sra_result : srl_result;     // SRA (func7[5]==1) or SRL (func7[5]==0)
            3'b110: rd = or_result;                            // OR
            3'b111: rd = and_result;                           // AND
            default: rd = 64'b0;
        endcase
    end
endmodule




