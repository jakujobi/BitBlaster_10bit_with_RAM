// Authors: John Akujobi
// Date: November, Fall, 2023
// Name: Input Logic
// Filename: inputlogic.sv
// Description: The input logic module manages external inputs to the processor.
// It includes debouncing logic for stable input signals and routes external
// data to the processor's internal bus. It plays a vital role in interfacing
// the processor with external sources like switches and buttons.

module inputlogic (
    input logic [9:0] RawData,      //10 bit raw data from external switches on the DE-10 Lite board
    input logic Peek_key,           //Peek button 
    input logic CLK_50MHz,          //50 MHz clock from DE-10 Lite
    input logic RawCLK,             //Clock button from DE-10 Lite
    input Extrn_Enable,             //This enables the external data to write into the shared data bus

    output logic [9:0] databus,     //write to the shared data bus
    output logic [1:0] data2bit,    //for the peek function and writes to RDA1, and it represents which register to be peeked into
    output logic CLKb,              //debounced clock
    output logic PeeKb              //debounced peek
);

//Debounce the keys________________
debouncer peek_debouncer (
    .A_noisy(Peek_key),
    .CLK50M(CLK_50MHz),
    .A(PeeKb)
);

debouncer clk_debouncer (
    .A_noisy(RawCLK),
    .CLK50M(CLK_50MHz),
    .A(CLKb)
);

assign data2bit = RawData[1:0];     //splice the lowest 2 bits into the data2bit output

//always comp block that assigns the data to the databus when the external data is enabled
//else the databus is set to 10'bz, which is a high impedance state
always_comb begin
    if (Extrn_Enable) begin
        databus = RawData;
    end
    else begin
        databus = 10'bz;
    end
end

endmodule