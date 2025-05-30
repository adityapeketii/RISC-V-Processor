module ImmediateGenerator (
    input wire [31:0] Instruction,  
    output reg [63:0] imm_value     
);

    wire [6:0] imm_type= Instruction[6:0] ;
    
    parameter I_Type    = 7'b0010011;
    parameter I_Type_ld = 7'b0000011;  
    parameter S_Type    = 7'b0100011;  
    parameter B_Type    = 7'b1100011;  
    

    always @(*) begin
        case(imm_type)
            // I-Type: ALU immediate
            I_Type: begin
                imm_value = {{52{instruction[31]}}, instruction[31:20]};
            end
            // I-Type: Load immediate
            I_Type_ld: begin
                imm_value = {{52{instruction[31]}}, instruction[31:20]};
            end
            // S-Type: Store
            S_Type: begin
                imm_value = {{52{instruction[31]}}, 
                            instruction[31:25], 
                            instruction[11:7]};
            end

            // B-Type: Branch
            B_Type: begin
                imm_value = {{52{instruction[31]}}, 
                            instruction[7], 
                            instruction[30:25], 
                            instruction[11:8], 
                            1'b0};  
            end

            // Default case
            default: begin
                imm_value = 64'b0;
            end
        endcase
    end

endmodule

