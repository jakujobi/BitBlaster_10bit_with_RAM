module ram_1024x10 (
    input logic clk,
    input logic reset,
    input logic write_enable,
    input logic[9:0] address, // 10-bit address for 1024 locations
    input logic[9:0] data_in,  // 10-bit data input
    output logic[9:0] data_out // 10-bit data output
);

    // 1024x10 bit memory array
    logic[9:0] memory_array[1023:0];

    // Asynchronous reset to clear memory
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            // Clear the entire memory array
            for (int i = 0; i < 1024; i++) begin
                memory_array[i] <= 10'b0;
            end
        end
        else begin
            if (write_enable) begin
                // Write operation
                memory_array[address] <= data_in;
            end
        end
    end

    // Read operation
    assign data_out = memory_array[address];

endmodule

/*
Inputs:

clk: The clock signal for synchronizing the read/write operations.
reset: An asynchronous reset to clear the entire RAM.
write_enable: A signal to enable writing to the memory. When high, the module performs a write operation.
address: A 10-bit address to specify which of the 1024 locations to access.
data_in: The 10-bit data to be written to the specified address.
Output:

data_out: The 10-bit data read from the specified address.
Memory Array:

A 1024x10 bit memory array is declared to store the data.
Write Operation:

On the rising edge of the clock, if write_enable is high and reset is low, the data_in is written to the location specified by address.
Read Operation:

The data at the location specified by address is continuously assigned to data_out.
Reset Operation:

On the rising edge of the clock, if reset is high, the entire memory array is cleared (set to 0).
*/