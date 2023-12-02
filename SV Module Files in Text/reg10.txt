// Authors: John Akujobi,
// Date: November, Fall, 2023
// Name: instruction register
// Filename: reg10.sv
// Description: This module is a register
//  that stores 10-bit values instruction from the shared data bus
//  and is negative-edge clock triggered with synchronous active-high enable.

module reg10 (
    input logic [9:0] D,    // 10-bit input data
    input logic EN,         // Active-high enable signal
    input logic CLKb,       // Clock signal (negative edge triggered)

    output logic [9:0] Q    // 10-bit output data (register value)
);

// The register logic
// Captures input D on the negative edge of CLKb when EN is high
always_ff @(negedge CLKb) begin
    if (EN) begin
        Q  <= D;            // Load the input D into the register Q
    end
    // Note: If EN is low, the register retains its previous value
end

endmodule

/*
- The 10-bit instruction register is negative-edge triggered with synchronous active-high enable.
- This register is used to save the instruction at timestep 0, and maintain the instruction throughout the multiple clock cycles required to complete a given instruction.
*/
 
// Authors: John Akujobi,
// Date: November, Fall, 2023
// Name: instruction register
// Filename: reg10.sv
// Description: This module is a register
//  that stores 10-bit values instruction from the shared data bus
//  and is negative-edge clock triggered with synchronous active-high enable.