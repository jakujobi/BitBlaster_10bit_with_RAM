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

//Address Register to store the address from the BUS when the EN_AddressRegRead signal is high
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