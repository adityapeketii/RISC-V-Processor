
module shift_left_1
(
    input  wire [63:0] in_data,
    output wire [63:0] out_data
);

    assign out_data = in_data << 1;

endmodule
