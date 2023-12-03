module ram_1024x10 (
    input logic clk,
    input logic EN_write_to_RAM,    // Enable signal to write to RAM
    input logic EN_read_from_RAM,   // Enable signal to read from RAM
    input logic[9:0] data_in,  // 10-bit data input

    input logic[9:0] address, // 10-bit address for 1024 locations
    input logic EN_AddressRegRead, // Enable signal for the address register to read from the BUS

    output logic[9:0] data_out // 10-bit data output
);

logic [9:0] Stored_Address;

//Address Register
always_ff @(negedge clk) begin
    if (EN_AddressRegRead) begin
        Stored_Address <= address;
    end
end


// 1024x10 bit memory array
logic[9:0] memory_array[1023:0];

// Load into the RAM memory
always_ff @(negedge clk) begin
        if (EN_write_to_RAM) begin
            // Write operation
            memory_array[Stored_Address] <= data_in;
        end
end

// Read from RAM operation
//assign data_out = memory_array[address];
always_comb begin
    if (EN_read_from_RAM) begin
        data_out = memory_array[Stored_Address];
    end else begin
        data_out = 10'bz;             // High-impedance state if not enabled
    end
end

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