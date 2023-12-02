// Authors: John Akujobi
// Date: November, Fall, 2023
// Name: Register File
// Filename: registerFile.sv
// Description: This module represents a collection of registers in the processor.
//  It facilitates reading from and writing to the registers.
//  The register file is crucial for storing intermediate data and states
//  during instruction execution.

module registerFile (
    input logic [9:0] D,        // Common 10-bit input data
    input logic ENW,            // Enable the register to read from the bus
    input logic ENR0,           // Read enable for Register This allows us to read the data that is on the bus
    input logic ENR1,           // Read enable for register peek This enable is used for speaking to see what is stored in which register
    input logic CLKb,           // Clock signal (negative edge triggered)

    input logic [1:0] WRA,      // The register address that will read from the bus.
    
    input logic [1:0] RDA0,     // Register to write into Q0 bus (2-bit)
    input logic [1:0] RDA1,     // Register to write into Q1 (2-bit)

    output logic [9:0] Q0,      // Output data for Q0 to the shared bus
    output logic [9:0] Q1       // Output data for Q1
);

logic [9:0] registers[3:0];     // Define four 10-bit registers


// Initial block to set all registers to zero
initial begin
    registers[0] = 10'b0;   
    registers[1] = 10'b0; 
    registers[2] = 10'b0;
    registers[3] = 10'b0;
end

// Read from the bus and write (Clocked) to the registers
always_ff @(negedge CLKb) begin
    if (ENW) begin
        registers[WRA] <= D;    // Write data into the register specified by WRA
    end
end


// Write into the bus from the register (Combinational)
always_comb begin
    if (ENR0) begin
        Q0 = registers[RDA0];   // Output data from the register specified by RDA0
    end else begin
        Q0 = 10'bz;             // High-impedance state if not enabled
    end

    if (ENR1) begin
        Q1 = registers[RDA1];   // Output data from the register specified by RDA1
    end else begin
        Q1 = 10'bz;             // High-impedance state if not enabled
    end
end

endmodule


/*
Similar to the in-class example, the register for this processor will contain eight 10-bit registers.
Each register shares a common 10-bit input (D), and share two common 10-bit data outputs (Q0
and Q1).
- To determine which register (if any) should be saving the input data and driving the
output signals, there are three 3-bit address inputs and three enable inputs.
- The operation of the register file is as follows:
    Write-operation: On the active-edge of the debounced clock signal CLKb, if ENW is active,
    then the register associated with the write address WRA saves the value on the D input.

    Read-operation: The read operation of the register file is combinational and does not depend on the active-edge of the clock.
    For each read signal (Q0 or Q1), if ENR is active, the output Q is equal to the value stored in the register associated with read address RDA. If not
    enabled, the register file should disconnect its outputs to avoid contention (i.e., high-impedance ‘Z’).

Warning: you should NOT have an additional 8 registers to implement the second read port; this will cost you points.
Use good engineering design to be able to add a second read port to your design.
*/


// Authors: John Akujobi
// Date: November, Fall, 2023
// Name: Register File
// Filename: registerFile.sv
// Description: This module represents a collection of registers in the processor.
//  It facilitates reading from and writing to the registers.
//  The register file is crucial for storing intermediate data and states
//  during instruction execution.