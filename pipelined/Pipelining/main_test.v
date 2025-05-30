`timescale 1ns/1ps

module Processor_testbench;
    // Testbench signals
    reg Clk;
    reg reset;

    // Instantiate the Processor
    Processor uut (
        .Clk(Clk),
        .reset(reset)
    );

    // Clock generation
    // 10ns clock period (50 MHz)
    always #5 Clk = ~Clk;

    // Task to display detailed processor state
    task display_detailed_results;
        begin
            $display("========== Processor State at Time %0t ==========", $time);
            
            // Fetch Stage
            $display("Fetch Stage:");
            $display("  Current PC       = 0x%d", uut.PC);
            $display("  Current Instr    = 0b%b", uut.Instruction);
            
            // IF/ID Pipeline Register
            $display("IF/ID Pipeline Register:");
            $display("  IF_ID_Instruction= 0b%b", uut.IF_ID_Instruction);
            $display("  IF_ID_PC         = 0x%d", uut.IF_ID_PC);
            
            // Decode Stage
            $display("Decode Stage:");
            $display("  Register A (Rs1) = 0x%d", uut.A);
            $display("  Register B (Rs2) = 0x%d", uut.B);
            $display("  Immediate Value  = 0x%d", uut.C);
            
            // ID/EX Pipeline Register
            $display("ID/EX Pipeline Register:");
            $display("  ID_EX_Instruction= 0b%b", uut.ID_EX_Instruction);
            $display("  ID_EX_A          = 0x%d", uut.ID_EX_A);
            $display("  ID_EX_B          = 0x%d", uut.ID_EX_B);
            $display("  ID_EX_C          = 0x%d", uut.ID_EX_C);
            
            // Execute Stage
            $display("Execute Stage:");
            $display("  ALU Result       = 0x%d", uut.ALU_result);
            $display("  Zero Flag        = %b", uut.Zero);
            $display("  Target Address   = 0x%b", uut.Target);
            $display("  Forward A   = 0x%b", uut.U4.ForwardA);
            $display("  Forward B   = 0x%b", uut.U4.ForwardB);
            $display("  A   = 0x%d", uut.U4.RS1);
            $display("  B   = 0x%d", uut.U4.RS2);
            $display("  ALUControl   = 0x%d", uut.U4.ALUcontrol);
           
            // Memory Stage
            $display("Memory Stage:");
            $display("  Memory Data Read = 0x%d", uut.Data);
            
            // Write Back Stage
            $display("Write Back Stage:");
            $display("  Write Back Data  = 0x%d", uut.Write_data);
            $display("  Write Back Address  = 0x%b", uut.MEM_WB_Instruction[11:7]);
             $display("  Write Back  = 0x%b", uut.MEM_WB_RegWrite);
            // Next PC
            $display("Next PC            = 0x%d", uut.pc_next);
            
            $display("===========================================\n");
        end
    endtask

    // Task to display minimal results
    task display_minimal_results;
        begin
            $display("Time = %0t | PC = 0x%h | Instr = 0b%b | ALU Result = 0x%h", 
                     $time, uut.PC, uut.Instruction, uut.ALU_result);
        end
    endtask

    // Testbench sequence
    initial begin
        // Initialize VCD dump
        $dumpfile("processor_testbench.vcd");
        $dumpvars(0, Processor_testbench);

        // Initialize signals
        Clk = 0;
        reset = 1;  // Assert reset

        // Hold reset for a few clock cycles
        #10;
        
        reset = 0;  // Deassert reset

        #170;
        $finish;
    end

    // Optional: Add error checking or specific test conditions
    // You can add specific checks or assertions here to validate processor behavior
endmodule
