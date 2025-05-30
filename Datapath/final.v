module SingleCycleCPU(
    input  wire clk
    // You could add a reset input, etc., if desired
);

    // -------------------------------
    // 1) Program Counter (PC) Register
    // -------------------------------
    reg [63:0] PC;

    // On each rising edge of the clock, update PC
    // (In a real design, you’d also handle reset)
    always @(posedge clk) begin
        PC <= nextPC;
    end

    // -------------------------------
    // Wires for interconnecting modules
    // -------------------------------
    wire [31:0] instruction;      // From Instruction Memory
    wire [6:0]  opcode     = instruction[6:0];
    wire [4:0]  rs1        = instruction[19:15];
    wire [4:0]  rs2        = instruction[24:20];
    wire [4:0]  rd         = instruction[11:7];

    // Control signals
    wire        Branch;
    wire        MemRead;
    wire        MemToReg;
    wire [1:0]  ALUOp;
    wire        MemWrite;
    wire        ALUSrc;
    wire        RegWrite;

    // Register File outputs
    wire [63:0] reg_data1;
    wire [63:0] reg_data2;

    // Immediate Generator output
    wire [63:0] imm_value;

    // Shift‐left‐1 output (for branch offset)
    wire [63:0] branch_offset;

    // ALU inputs/outputs
    wire [63:0] alu_input2;
    wire signed [63:0] alu_result;
    wire zero_flag;

    // Data memory output
    wire [63:0] data_memory_out;

    // MUX output that goes back into the register file (MemToReg MUX)
    wire [63:0] write_back_data;

    // Next PC wires
    wire [63:0] pc_plus_4;
    wire [63:0] pc_branch;
    wire [63:0] nextPC;

    // -------------------------------
    // 2) Instruction Memory
    //    (Address is PC)
    // -------------------------------
    Inst_Memory IMEM (
        .address     ( PC[31:0]       ),  // using lower bits as address
        .instruction ( instruction    )
    );

    // -------------------------------
    // 3) Control Unit
    // -------------------------------
    control_unit CU (
        .instr_op (opcode),
        .Branch   (Branch),
        .MemRead  (MemRead),
        .MemToReg (MemToReg),
        .ALUOp    (ALUOp),
        .MemWrite (MemWrite),
        .ALUSrc   (ALUSrc),
        .RegWrite (RegWrite)
    );

    // -------------------------------
    // 4) Register File
    // -------------------------------
    Register_file REGFILE (
        .clk         (clk),
        .RegWrite    (RegWrite),
        .rs1         (rs1),
        .rs2         (rs2),
        .rd          (rd),
        .write_data  (write_back_data),
        .read_data1  (reg_data1),
        .read_data2  (reg_data2)
    );

    // -------------------------------
    // 5) Immediate Generator
    // -------------------------------
    ImmediateGenerator IMMGEN (
        .Instruction (instruction),
        .imm_value   (imm_value)
    );

    // -------------------------------
    // 6) ALUSrc MUX (choose reg_data2 or immediate)
    // -------------------------------
    // We can reuse the mux2to1 (but note it is a 1-bit version in your code).
    // For 64-bit data, we either modify mux2to1 or just do a direct assign:
    assign alu_input2 = (ALUSrc) ? imm_value : reg_data2;

    // -------------------------------
    // 7) ALU
    //    (func7 = instruction[31:25], func3 = instruction[14:12])
    // -------------------------------
    alu ALU (
        .func7 (instruction[31:25]),
        .func3 (instruction[14:12]),
        .rs1   (reg_data1),
        .rs2   (alu_input2),
        .rd    (alu_result)
    );

    // Zero flag for branches
    assign zero_flag = (alu_result == 64'd0) ? 1'b1 : 1'b0;

    // -------------------------------
    // 8) Data Memory
    // -------------------------------
    Data_memory DMEM (
        .clk         (clk),
        .MemRead     (MemRead),
        .MemWrite    (MemWrite),
        .addr        (alu_result),
        .write_data  (reg_data2),      // For store instructions
        .read_data   (data_memory_out)
    );

    // -------------------------------
    // 9) MemToReg MUX (choose ALU result or Data Memory output)
    // -------------------------------
    assign write_back_data = (MemToReg) ? data_memory_out : alu_result;

    // -------------------------------
    // 10) Branch Address Calculation
    //     - Shift immediate left by 1
    //     - Add to current PC
    // -------------------------------
    shift_left_1 SHIFT1 (
        .in_data  (imm_value),
        .out_data (branch_offset)
    );

    // Adder for PC + 4
    // (we can either instantiate an adder_subtractor_64bit or just do a wire add)
    assign pc_plus_4 = PC + 64'd4;

    // Adder for PC + branch_offset
    assign pc_branch = PC + branch_offset;

    // Next PC MUX: If (Branch & zero_flag) => pc_branch, else pc_plus_4
    assign nextPC = (Branch & zero_flag) ? pc_branch : pc_plus_4;

endmodule
