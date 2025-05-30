

module Control(
    input [31:0] Instruction,
    output reg Branch,
    output reg MemRead,
    output reg MemtoReg,
    output reg [1:0] ALUOp,
    output reg MemWrite,
    output reg ALUSrc,
    output reg RegWrite
);

    wire [6:0] opcode;
    assign opcode = Instruction[6:0]; 

    parameter r_type = 7'b0110011;
    parameter ld = 7'b0000011;
    parameter sd = 7'b0100011;
    parameter beq = 7'b1100011;

    always @(*) begin
        // Default 
        Branch = 1'b0;
        MemRead = 1'b0;
        MemtoReg = 1'b0;
        ALUOp = 2'b00;
        MemWrite = 1'b0;
        ALUSrc = 1'b0;
        RegWrite = 1'b0;

        case(opcode)
            r_type: begin
                Branch = 1'b0;
                MemRead = 1'b0;
                MemtoReg = 1'b0;
                ALUOp = 2'b10;       
                MemWrite = 1'b0;
                ALUSrc = 1'b0;
                RegWrite = 1'b1;
            end

            ld: begin
                Branch = 1'b0;
                MemRead = 1'b1;
                MemtoReg = 1'b1;
                ALUOp = 2'b00;
                MemWrite = 1'b0;
                ALUSrc = 1'b1;
                RegWrite = 1'b1;
            end

            sd: begin
                Branch = 1'b0;
                MemRead = 1'b0;
                MemtoReg = 1'bx;
                ALUOp = 2'b00;
                MemWrite = 1'b1;
                ALUSrc = 1'b1;
                RegWrite = 1'b0;
            end

            beq: begin

                Branch = 1'b1;
                MemRead = 1'b0;
                MemtoReg = 1'bx;
                ALUOp = 2'b01;
                MemWrite = 1'b0;
                ALUSrc = 1'b0;
                RegWrite = 1'b0;
            end

            default: begin
                // Invalid opcode - sets all controls to 0(taken from load-use hazard case)
                Branch = 1'b0;
                MemRead = 1'b0;
                MemtoReg = 1'b0;
                ALUOp = 2'b00;
                MemWrite = 1'b0;
                ALUSrc = 1'b0;
                RegWrite = 1'b0;
            end
        endcase
    end
endmodule

module Register_file(
    input clk,
    input RegWrite,
    input [4:0] rs1,
    input [4:0] rs2,
    input [4:0] rd,
    input [63:0] write_data,
    output [63:0] read_data1,
    output [63:0] read_data2
);

    reg [63:0] registers [0:31];
    integer file;
    integer i;
    integer scan_result;
    reg [63:0] reg_value;
    reg [4:0] reg_index;

    
    initial begin
     
        for (i = 0; i < 32; i = i + 1) begin
            registers[i] = 64'd0;
        end
        
       
        file = $fopen("registers.txt", "r");
        if (file) begin
            while (!$feof(file)) begin
                scan_result = $fscanf(file, "%d %h\n", reg_index, reg_value);
                if (scan_result == 2) begin  
                    if (reg_index < 32) begin
                        registers[reg_index] = reg_value;
                    end
                end
            end
            $fclose(file);
        end
        else begin
         
            file = $fopen("registers.txt", "w");
            for (i = 0; i < 32; i = i + 1) begin
                if (i == 0) begin
                    registers[i] = 64'd0;  // x0 is always 0
                end
                else begin
                    registers[i] = i; 
                end
                $fdisplay(file, "%d %h", i, registers[i]);
            end
            $fclose(file);
        end
    end

    assign read_data1 = registers[rs1];
    assign read_data2 = registers[rs2];

  
    always @(negedge clk) begin
        if (RegWrite && (rd != 5'd0)) begin
            registers[rd] <= write_data;
            
            
            file = $fopen("registers.txt", "w");
            for (i = 0; i < 32; i = i + 1) begin
                if (i == rd && rd != 0) begin
                  
                    $fdisplay(file, "%d %h", i, write_data);
                end
                else begin
                    
                    $fdisplay(file, "%d %h", i, registers[i]);
                end
            end
            $fclose(file);
        end
    end

endmodule

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
                imm_value = {{52{Instruction[31]}}, Instruction[31:20]};
            end
            // I-Type: Load immediate
            I_Type_ld: begin
                imm_value = {{52{Instruction[31]}}, Instruction[31:20]};
            end
            // S-Type: Store
            S_Type: begin
                imm_value = {{52{Instruction[31]}}, 
                            Instruction[31:25], 
                            Instruction[11:7]};
            end

            // B-Type: Branch
            B_Type: begin
                imm_value = {{52{Instruction[31]}}, 
                            Instruction[7], 
                            Instruction[30:25], 
                            Instruction[11:8], 
                            1'b0};  
            end

            // Default case
            default: begin
                imm_value = 64'b0;
            end
        endcase
    end

endmodule

module Decode(
    input Clk,
    input RegWrite,
    input [31:0] Instruction,
    input [63:0] write_data,
    output [63:0] A,
    output [63:0] B,
    output [63:0] C,
    input [4:0] addr  
);

    wire [4:0] rs1;
    wire [4:0] rs2;
    wire [4:0] rd;

    assign rd = addr;
    assign rs1 = Instruction[19:15];
    assign rs2 = Instruction[24:20];

    Register_file RF_ID(
        .clk(Clk),
        .RegWrite(RegWrite),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .write_data(write_data),
        .read_data1(A),
        .read_data2(B)
    );

    ImmediateGenerator IG(
        .Instruction(Instruction),
        .imm_value(C)
    );

endmodule
