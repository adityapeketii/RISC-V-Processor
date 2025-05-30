`include "Fetch.v"
`include "Decode.v"
`include "Execute.v"
`include "Data_memory.v"
`include "Next_PC.v"
`include "WriteBack.v"
`include "hazard_detection_unit.v"
`include "control_hazard_beq.v"

module Processor (
    input wire Clk,
    input wire reset
);

// Pipeline Stage Registers

// IF/ID Stage
reg [31:0] IF_ID_Instruction;
reg [63:0] IF_ID_PC;

// ID/EX Stage
reg [31:0] ID_EX_Instruction;
reg [63:0] ID_EX_PC;
reg [63:0] ID_EX_A; // Data from Rs1
reg [63:0] ID_EX_B; // Data from Rs2
reg [63:0] ID_EX_C; // Immediate value
reg [4:0]  ID_EX_rd; // Destination register

reg [1:0] ID_EX_ALUOp;
reg        ID_EX_ALUSrc;
reg        ID_EX_MemRead;
reg        ID_EX_MemWrite;
reg        ID_EX_MemtoReg;
reg        ID_EX_RegWrite;
reg        ID_EX_Branch;

// EX/MEM Stage 
reg [31:0] EX_MEM_Instruction;
reg [63:0] EX_MEM_ALU_result;
reg [63:0] EX_MEM_Target;
reg [63:0] EX_MEM_B;
reg        EX_MEM_Zero;
reg        EX_MEM_MemRead;
reg        EX_MEM_MemWrite;
reg        EX_MEM_MemtoReg;
reg        EX_MEM_Branch;
reg        EX_MEM_RegWrite;

// MEM/WB Stage 
reg [31:0] MEM_WB_Instruction;
reg [63:0] MEM_WB_ALU_result;
reg [63:0] MEM_WB_Data;
reg        MEM_WB_RegWrite;
reg        MEM_WB_MemtoReg;

// Interconnect wires
wire [63:0] pc_next;
wire [63:0] PC;
wire [31:0] Instruction;
wire Stall;           // Stall signal from hazard unit
wire Flush;           // Flush signal for control hazard
wire Branch;          // From control unit (indicates branch instruction)
wire MemtoReg;
wire MemWrite;
wire MemRead;
wire [1:0] ALUOp;
wire ALUSrc;
wire RegWrite;

wire [63:0] A; // Data from Rs1 register
wire [63:0] B; // Data from Rs2 register
wire [63:0] C; // Immediate data

wire Zero;         // ALU zero flag
wire [63:0] Target; // Branch target
wire [63:0] ALU_result;
wire [63:0] Data;

wire [63:0] Write_data;

// Instantiate Fetch stage
Fetch U1 (
    .Clk(Clk), 
    .reset(reset), 
    .pc_next(pc_next), 
    .PC(PC), 
    .instruction(Instruction), 
    .stall(Stall)
);

// Instantiate hazard detection unit (for load-use hazards)
hazard_detection_unit HDU (
    .ID_EX_MemRead(ID_EX_MemRead),     // from ID/EX
    .ID_EX_RD(ID_EX_rd),               // destination register in ID/EX
    .IF_ID_Rs1(Instruction[19:15]),     // first source register in IF/ID
    .IF_ID_Rs2(Instruction[24:20]),     // second source register in IF/ID
    .stall(Stall)
);

// Instantiate control hazard unit (for branch flush)
control_hazard_beq CHU (
    .Branch(ID_EX_Branch), // Branch signal coming from ID/EX
    .Zero(Zero),           // Zero flag from Execute
    .Flush(Flush)
);

// IF/ID Stage Register
always @(negedge Clk or posedge reset) begin
    if (reset) begin
        IF_ID_Instruction <= 32'b0;
        IF_ID_PC <= 64'b0;
    end 
    else if (Flush) begin
        // Flush IF/ID: insert NOP
        IF_ID_Instruction <= 32'b0;
        IF_ID_PC <= 64'b0;
    end
    else if (Stall) begin
        // Maintain previous values on stall
        IF_ID_Instruction <= IF_ID_Instruction;
        IF_ID_PC <= IF_ID_PC;
    end 
    else begin
        IF_ID_Instruction <= Instruction;
        IF_ID_PC <= PC;
    end
end

// ID Stage: Instruction Decode and Control Generation
Control U2 (
    .Instruction(IF_ID_Instruction),
    .Branch(Branch),
    .MemRead(MemRead),
    .MemtoReg(MemtoReg),
    .ALUOp(ALUOp),
    .MemWrite(MemWrite),
    .ALUSrc(ALUSrc),
    .RegWrite(RegWrite)
);

Decode U3 (
    .Clk(Clk),
    .RegWrite(MEM_WB_RegWrite),
    .Instruction(IF_ID_Instruction),
    .write_data(Write_data),
    .A(A),
    .B(B),
    .C(C),
    .addr(MEM_WB_Instruction[11:7])
);

// ID/EX Stage Register
always @(negedge Clk or posedge reset) begin
    if (reset) begin
        ID_EX_Instruction <= 32'b0;
        ID_EX_PC <= 64'b0;
        ID_EX_A <= 64'b0;
        ID_EX_B <= 64'b0;
        ID_EX_C <= 64'b0;
        ID_EX_rd <= 5'b0;
        ID_EX_ALUOp <= 2'b00;
        ID_EX_ALUSrc <= 1'b0;
        ID_EX_MemRead <= 1'b0;
        ID_EX_MemWrite <= 1'b0;
        ID_EX_MemtoReg <= 1'b0;
        ID_EX_RegWrite <= 1'b0;
        ID_EX_Branch <= 1'b0;
    end 
    else if (Flush) begin
        // On flush, insert a NOP into ID/EX
        ID_EX_Instruction <= 32'b0;
        ID_EX_PC <= 64'b0;
        ID_EX_A <= 64'b0;
        ID_EX_B <= 64'b0;
        ID_EX_C <= 64'b0;
        ID_EX_rd <= 5'b0;
        ID_EX_ALUOp <= 2'b00;
        ID_EX_ALUSrc <= 1'b0;
        ID_EX_MemRead <= 1'b0;
        ID_EX_MemWrite <= 1'b0;
        ID_EX_MemtoReg <= 1'b0;
        ID_EX_RegWrite <= 1'b0;
        ID_EX_Branch <= 1'b0;
    end 
    else if (Stall) begin
        // Hold the values (or insert NOP in control signals) during stall
        ID_EX_Instruction <= ID_EX_Instruction;
        ID_EX_PC <= ID_EX_PC;
        ID_EX_A <= ID_EX_A;
        ID_EX_B <= ID_EX_B;
        ID_EX_C <= ID_EX_C;
        ID_EX_rd <= ID_EX_rd;
        // Disable control signals to prevent side effects
        ID_EX_ALUOp <= 2'b00;
        ID_EX_ALUSrc <= 1'b0;
        ID_EX_MemRead <= 1'b0;
        ID_EX_MemWrite <= 1'b0;
        ID_EX_MemtoReg <= 1'b0;
        ID_EX_RegWrite <= 1'b0;
        ID_EX_Branch <= 1'b0;
    end 
    else begin
        ID_EX_Instruction <= IF_ID_Instruction;
        ID_EX_PC <= IF_ID_PC;
        ID_EX_A <= A;
        ID_EX_B <= B;
        ID_EX_C <= C;
        ID_EX_rd <= IF_ID_Instruction[11:7];
        ID_EX_ALUOp <= ALUOp;
        ID_EX_ALUSrc <= ALUSrc;
        ID_EX_MemRead <= MemRead;
        ID_EX_MemWrite <= MemWrite;
        ID_EX_MemtoReg <= MemtoReg;
        ID_EX_RegWrite <= RegWrite;
        ID_EX_Branch <= Branch;
    end
end

// Execute Stage
Execute U4 (
    .EX_MEM_ALU_result(EX_MEM_ALU_result),
    .MEM_WB_WriteBack(Write_data),
    .A(ID_EX_A),
    .B(ID_EX_B),
    .C(ID_EX_C),
    .PC(ID_EX_PC),
    .funct3(ID_EX_Instruction[14:12]),
    .funct7(ID_EX_Instruction[31:25]),
    .ALUOp(ID_EX_ALUOp),
    .ALUSrc(ID_EX_ALUSrc),
    .ID_EX_RegisterA(ID_EX_Instruction[19:15]),
    .ID_EX_RegisterB(ID_EX_Instruction[24:20]),
    .EX_MEM_Instruction(EX_MEM_Instruction),
    .MEM_WB_Instruction(MEM_WB_Instruction),
    .EX_MEM_RegWrite(EX_MEM_RegWrite),
    .MEM_WB_RegWrite(MEM_WB_RegWrite),
    .Zero(Zero),
    .Target(Target),
    .ALU_result(ALU_result)
);

// EX/MEM Stage Register
always @(negedge Clk or posedge reset) begin
    if (reset) begin
        EX_MEM_Instruction <= 32'b0;
        EX_MEM_ALU_result <= 64'b0;
        EX_MEM_Target     <= 64'b0;
        EX_MEM_B          <= 64'b0;
        EX_MEM_Zero       <= 1'b0;
        EX_MEM_MemRead    <= 1'b0;
        EX_MEM_MemWrite   <= 1'b0;
        EX_MEM_MemtoReg   <= 1'b0;
        EX_MEM_Branch     <= 1'b0;
        EX_MEM_RegWrite   <= 1'b0;
    end 
    else begin
        EX_MEM_Instruction <= ID_EX_Instruction;
        EX_MEM_ALU_result  <= ALU_result;
        EX_MEM_Target      <= Target;
        EX_MEM_B           <= ID_EX_B;
        EX_MEM_Zero        <= Zero;
        EX_MEM_MemRead     <= ID_EX_MemRead;
        EX_MEM_MemWrite    <= ID_EX_MemWrite;
        EX_MEM_MemtoReg    <= ID_EX_MemtoReg;
        EX_MEM_Branch      <= ID_EX_Branch;
        EX_MEM_RegWrite    <= ID_EX_RegWrite;
    end
end

// Data Memory Stage
Data_memory U5 (
    .Clk(Clk),
    .address(EX_MEM_ALU_result),
    .Data_write(EX_MEM_B),
    .MemWrite(EX_MEM_MemWrite),
    .MemRead(EX_MEM_MemRead),
    .Data_read(Data)
);

// MEM/WB Stage Register
always @(negedge Clk or posedge reset) begin
    if (reset) begin
        MEM_WB_Instruction <= 32'b0;
        MEM_WB_ALU_result  <= 64'b0;
        MEM_WB_Data        <= 64'b0;
        MEM_WB_RegWrite    <= 1'b0;
        MEM_WB_MemtoReg    <= 1'b0;
    end 
    else begin
        MEM_WB_Instruction <= EX_MEM_Instruction;
        MEM_WB_ALU_result  <= EX_MEM_ALU_result;
        MEM_WB_Data        <= Data;
        MEM_WB_RegWrite    <= EX_MEM_RegWrite;
        MEM_WB_MemtoReg    <= EX_MEM_MemtoReg;
    end
end

// WriteBack Stage
WriteBack U6 (
    .ALU_result(MEM_WB_ALU_result),
    .Data(MEM_WB_Data),
    .MemtoReg(MEM_WB_MemtoReg),
    .Write_data(Write_data)
);

// Next PC Stage: choose between sequential and branch target.
Next_PC U7 (
    .Branch(EX_MEM_Branch),  // Could also be generated from earlier stage if forwarding PC branch decision earlier
    .Zero(Zero),
    .PC(PC),
    .Target(EX_MEM_Target),
    .next_pc(pc_next)
);

endmodule
