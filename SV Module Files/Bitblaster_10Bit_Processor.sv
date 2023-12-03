// Author:     John Akujobi
// Date:       November, Fall, 2023
// Name:       Bitblaster 10-Bit Processor
// Filename:   Bitblaster_10Bit_Processor.sv
// Description: This is the top-level module for the Bitblaster 10-bit processor.
//  It integrates various components like ALU, register file, controller, and input/output logic
//  to simulate a complete processor architecture. This module coordinates the flow of data 
//  and control signals across the processor.

// 10-bit processor
// This is the top level file
module Bitblaster_10Bit_Processor (
    input logic [9:0] Raw_Data_From_Switches,
    input logic Clock_50MHz,
    input logic Peek_Button,
    input logic Clock_Button,

    output logic [9:0] LED_B_Data_Bus,          //LEDR[9:0] data bus for current values on the Data bus
    output logic [6:0] DHEX0,                   //HEX0[6:0] data bus current 10-bit value on the data bus decoded to three 7-segment displays or output of 2nd read port of register file
    output logic [6:0] DHEX1,                   //HEX1[6:0] data bus
    output logic [6:0] DHEX2,                   //HEX2[6:0] data bus
    output logic [6:0] THEX_Current_Timestep,   //HEX5 [6:0] Current Timestep
    output logic LED_D_Done
);

logic Extrn_Enable_Signal;                      //External Data Receiver Enable
logic [9:0] Instruction_From_IR;                //Goes from the output of the instruction register to the INSTR instruction input of the ALU
logic [1:0] Timestep_2_bits;                    //Timestep counter: Goes from output of Counter to
wire [9:0] Shared_Data_Bus;                     //Shared Data Bus 
logic [9:0] Q1_REG_Read_From_Register_File;
logic Debounced_Clock;                          //Debounced
logic IR_Enable;                                //Enable signal for the instruction register
logic [1:0] Data_2_bits;                        //Data last 2 bits of data bus
logic Debounced_Peek;
logic Clear_Signal;                             //Clear signal for the instruction register and outputLogicModule



//! Input Logic
inputlogic inputLogicModule(
    .RawData(Raw_Data_From_Switches),
    .Peek_key(Peek_Button),
    .CLK_50MHz(Clock_50MHz),
    .RawCLK(Clock_Button),
    .Extrn_Enable(Extrn_Enable_Signal),
    
    //Outputs from input logic
    .databus(Shared_Data_Bus),
    .data2bit(Data_2_bits),
    .CLKb(Debounced_Clock),
    .PeeKb(Debounced_Peek)
);

//! Counter module
upcount2 countermodule (
    .CLR (Clear_Signal),
    .CLKb (Debounced_Clock),
    .CNT (Timestep_2_bits)
);

//! Instruction Register
reg10 instructionRegister (
    .D(Shared_Data_Bus),
    .EN (IR_Enable), //Instruction Register Enable
    .CLKb (Debounced_Clock),
    .Q(Instruction_From_IR)
);

//!____________________________________________________________________________________________________________________________________
logic ENW_ENW;
logic [1:0] Rin_WRA;                            //The address of the register to write to
logic [1:0] Rout_RDA0;
logic ENR_ENR0;


logic Ain_Ain;                                  //Enable signal to save data to the intermediate ALU input “A”
logic Gin_Gin;                                  //Enable signal to save data to the intermediate ALU input “G”
logic Gout_Gout;                                //Enable signal to save data from the intermediate ALU output “G”
logic [3:0] ALUcont_FN;                         //Signal to control which arithmetic or logic operation the ALU should perform

logiv EN_RAM_to_BUS;                            //Enable signal to read data from RAM
logic EN_BUS_to_RAM;                            //Enable signal to write data to RAM

logic EN_Address_Register_Read_from_BUS;        //Enable signal for the address register to read from the BUS

//! Controller
controller controllerModule(
    .INST(Instruction_From_IR),
    .T(Timestep_2_bits),

    .IMM(Shared_Data_Bus),

    //Goes to Register File
    .ENW(ENW_ENW),
    .Rin(Rin_WRA),
    .Rout(Rout_RDA0),
    .ENR(ENR_ENR0),

    //Goes to ALU
    .Ain(Ain_Ain),
    .Gin(Gin_Gin),
    .Gout(Gout_Gout),
    .ALUcont(ALUcont_FN),

    //To other Components
    .Ext(Extrn_Enable_Signal),
    .IRin(IR_Enable),
    .Clr(Clear_Signal),

    //RAM signals
    .RAM_read_from_RAM(EN_RAM_to_BUS),  // Enable signal to read data from RAM
    .RAM_write_to_RAM(EN_BUS_to_RAM); // Enable signal to write data to RAM
    .EN_AddressRegRead (EN_Address_Register_Read_from_BUS)  // Enable signal for the address register to read from the BUS
);

//! Register File
registerFile registerFileModule (
    .D (Shared_Data_Bus),                       // Common 10-bit input data
    .ENR0(ENR_ENR0),                            // Read enable for Normal
    .ENR1(ENR1_1bit),                           // Read enable for Q1

    .CLKb(Debounced_Clock),                     // Clock signal (negative edge triggered)

    .ENW (ENW_ENW),                             // Write enable
    .WRA(Rin_WRA),                              // Read address (2-bit) This means read from the databus and write on the rx register inside it
    .RDA0(Rout_RDA0),                           // Read address for Q0 (2-bit)
    .RDA1(Data_2_bits),                         // Read address for Q1 (2-bit)
    
    .Q0(Shared_Data_Bus),                       // Output data for Q0
    .Q1(Q1_REG_Read_From_Register_File)         // Output data for Q1
);

//! RAM
ram_1024x10 ramModule (
.clk (Debounced_Clock), // Clock signal (negative edge triggered)
.EN_write_to_RAM (EN_BUS_to_RAM), // Write enable
.EN_read_from_RAM (EN_RAM_to_BUS), // Read enable

.din (Shared_Data_Bus), // Input data
.dout (Shared_Data_Bus) // Output data

.address (Address_from_Register), // Address
.EN_AddressRegRead (EN_Address_Register_Read_from_BUS)  // Enable signal for the address register to read from the BUS
); 

//! Multi-stage ALU
ALU multistageALU (
    .OP (Shared_Data_Bus),
    .Ain (Ain_Ain),
    .Gin (Gin_Gin),
    .Gout (Gout_Gout),
    .FN (ALUcont_FN),
    .CLKb (Debounced_Clock),

    //Output
    .RES (Shared_Data_Bus)
);

//! Output Logic
outputlogic outputLogicModule(
    .BUS(Shared_Data_Bus),
    .REG(Q1_REG_Read_From_Register_File),
    .TIME(Timestep_2_bits),
    .DONE(Clear_Signal),
    .Pkb(Debounced_Peek),

    // outputs from output logic
    .LED_B(LED_B_Data_Bus),
    .DHEX0(DHEX0),
    .DHEX1(DHEX1),
    .DHEX2(DHEX2),
    .THEX(THEX_Current_Timestep ),
    .LED_D(LED_D_Done)
);

endmodule


// Author:     John Akujobi
// Date:       November, Fall, 2023
// Name:       Bitblaster 10-Bit Processor
// Filename:   Bitblaster_10Bit_Processor.sv
// Description: This is the top-level module for the Bitblaster 10-bit processor.
// It integrates various components like ALU, register file, controller, and input/output logic
// to simulate a complete processor architecture. This module coordinates the flow of data 
// and control signals across the processor.

/*
You will build the processor shown in Fig. 1 with the set of instructions in Section 3.2.
Your data bus will be 10-bits wide, and is used to pass data between elements of your processor (shown in green in Fig. 1).
A general description of the processor will be provided here, with each of the top-level modules and inputs/outputs described in more detail below.
Your 10-bit processor takes in data and instructions via an external source (labeled “data”).
Depending on the current instruction (saved in the instruction register) and the current timestep (saved in a 2-bit counter),
    your controller drives the control signals of your multi-stage processor circuit. All data is saved in one of four 10-bit registers (R0–R3) within the register file.
To perform arithmetic and logic operations on the stored data, a multi-stage arithmetic logic unit (ALU) is used that calculates an output G = A FN OP,
    where “FN” is the arithmetic or logic operation to be performed,
    A and G are intermediate input and output registers, respectively,
    and OP and RES are connected to the shared data bus as the operand input and result output, respectively.
The processor has a shared data bus.

The 10-bit processor is similar to that discussed in the supplementary PDF written by Brown and Vranesic (old textbook) and that we discussed in class.
The PDF contains many hints and SystemVerilog samples beyond those discussed in class.

3.2 Instruction Set
You will implement, and your processor will support, the following functions using the exact instruction formats in Table 1.
Some instructions use the ALU, some need just one operand, some are just for data movement, and some use immediate values as operands.
ARM-TI is leaving you the design decision to determine how best to decode each instruction, but they expect the minimum number of timesteps required per instruction type
    (hint: if you only need one operand, you might (read: must) be able to skip an ALU step [wink, wink]).

Table 1: Processor instruction set
Opcode          Mnemonic            Instruction
00_XX_UUU_0000  ld Rx               Load data into Rx from the slide switches (external data input): Rx ← Data
00_XX_YY_0001   cp Rx, Ry           Copy the value from Ry and store to Rx: Rx ← [Ry]
00_XX_YY_0010   add Rx, Ry          Add the values in Rx and Ry and store the result in Rx: Rx ← [Rx] + [Ry]
00_XX_YY_0011   sub Rx, Ry          Subtract the value in Ry from Rx and store the result in Rx: Rx ← [Rx]−[Ry]
00_XX_YY_0100   inv Rx, Ry          Take the twos-complement of the value in Ry and store to Rx: Rx ← −[Ry]
00_XX_YY_0101   flp Rx, Ry          Flip the bits of the value in Ry and store to Rx: Rx ←∼ [Ry]
00_XX_YY_0110   and Rx, Ry          Bit-wise AND the values in Rx and Ry and store the result in Rx: Rx ← [Rx] & [Ry]
00_XX_YY_0111   or Rx, Ry           Bit-wise OR the values in Rx and Ry and store the result in Rx: Rx ← [Rx] | [Ry]
00_XX_YY_1000   xor Rx, Ry          Bit-wise XOR the values in Rx and Ry and stroe the result in Rx: ← [Rx] ∧ [Ry]
00_XX_YY_1001   lsl Rx, Ry          Logical shift left the value in Rx by Ry and store the result in Rx: Rx ← [Rx] <<[Ry]
00_XX_YY_1010   lsr Rx, Ry          Logical shift right the value in Rx by Ry and store the result in Rx: Rx ← [Rx] >>[Ry]
00_XX_YY_1011   asr Rx, Ry          Arithmatic shift right the value of Rx by Ry and store the result in Rx: ← [Rx] >>>[Ry]
10_XX_IIIIII    addi Rx, 6’bIIIIII  Add the 6-bit immediate value 10’b0000IIIIII (left-padded with zeros) to the value in Rx and store in Rx: Rx ← [Rx] + 10’b0000IIIIII
11_XX_IIIIII    subi Rx, 6’bIIIIII  Subtract the 6-bit immediate value 10’b0000IIIIII (left-padded with zeros) from the value in Rx and store in Rx: Rx ← [Rx] - 10’b0000IIIIII

*/


// Author:     John Akujobi
// Date:       November, Fall, 2023
// Name:       Bitblaster 10-Bit Processor
// Filename:   Bitblaster_10Bit_Processor.sv
// Description: This is the top-level module for the Bitblaster 10-bit processor.
//  It integrates various components like ALU, register file, controller, and input/output logic
//  to simulate a complete processor architecture. This module coordinates the flow of data 
//  and control signals across the processor.