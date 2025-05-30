module ALUInputMuxA (
    input [63:0] ID_EX_A,        // Original register value from ID/EX stage
    input [63:0] EX_MEM_ALU_result,  // ALU result from EX/MEM stage
    input [63:0] MEM_WB_WriteBack,   // Write-back data from MEM/WB stage
    input [1:0] ForwardA,        // Forwarding control signal
    
    output reg [63:0] ALU_input  // Selected input for ALU
);

always @(*) begin
    case(ForwardA)
        2'b00: ALU_input = ID_EX_A;           // Use original register value
        2'b10: ALU_input = EX_MEM_ALU_result; // Forward from EX/MEM stage
        2'b01: ALU_input = MEM_WB_WriteBack;  // Forward from MEM/WB stage
        default: ALU_input = ID_EX_A;         // Default to original value
    endcase
end

endmodule


module ALUInputMuxB (
    input [63:0] ID_EX_B,        // Original register value from ID/EX stage
    input [63:0] EX_MEM_ALU_result,  // ALU result from EX/MEM stage
    input [63:0] MEM_WB_WriteBack,   // Write-back data from MEM/WB stage
    input [1:0] ForwardB,        // Forwarding control signal
    
    output reg [63:0] ALU_input  // Selected input for ALU
);

always @(*) begin
    case(ForwardB)
        2'b00: ALU_input = ID_EX_B;           // Use original register value
        2'b10: ALU_input = EX_MEM_ALU_result; // Forward from EX/MEM stage
        2'b01: ALU_input = MEM_WB_WriteBack;  // Forward from MEM/WB stage
        default: ALU_input = ID_EX_B;         // Default to original value
    endcase
end

endmodule
