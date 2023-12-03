// Authors: John Akujobi, LNU Sukhman Singh, Kay Humphrey
// Date: November, Fall, 2023
// Name: Controller
// Filename: controller.sv
// Description: This module acts as the central controller for the processor.
//  It interprets instructions and sets control signals accordingly.
//  The controller orchestrates the sequence of operations in the processor,
//  managing data flow between registers, ALU, and other components.

module controller(
    input logic [9:0] INST,     //Immediatevalue to be used for the two immediate instructions
    input logic [1:0] T,        //Current timestep

    output logic [9:0] IMM,     //This put the immediate value we are working with into the bus
                                // So, like the value we want the register to read
    output logic [1:0] Rin,     //Address for the register to be written to, from the shared data bus
    output logic [1:0] Rout,    //Address for the register to be read from, to the shared data bus
    output logic ENW,           //Enable signal to write data to the register file
    output logic ENR,           //Enable signal to read data from the register file
    output logic Ain,           //Enable signal to save data to the intermediate ALU input “A”
    output logic Gin,           //Enable signal to save data to the intermediate ALU output “G”
    output logic Gout,          //Enable signal to write data from the ALU intermediate output “G” to the shared data bus
    output logic [3:0] ALUcont, //Signal to control which arithmetic or logic operation the ALU should perform
    output logic Ext,           //Enable signal to drive the shared data bus from the external “data” signal
    output logic IRin,          //Enable signal to save data to the instruction register
    output logic Clr,            //Clear signal for the timestep counter

    //RAM signals
    output logic RAM_read_from_RAM,  // Enable signal to read data from RAM
    output logic RAM_write_to_RAM, // Enable signal to write data to RAM
    output logic EN_AddressRegRead //Enable signal to let the address read from the bus
);

parameter 
    LOAD = 4'b0000,             //Load data from the instruction register to Rx: Rx←[Rx]
    COPY = 4'b0001,             //Copy the value from Ry and store to Rx: Rx←[Ry]
    ADD = 4'b0010,              //add Rx and RY; Add the values in Rx and Ry and store the result inRx:  Rx←[Rx] + [Ry]
    SUB = 4'b0011,              //sub Rx and RY; Subtract the value in Ry from Rx and store the result inRx:  Rx←[Rx] − [Ry]
    INV = 4'b0100,              //inv Rx and RY; Take the twos-complement of the value in Ry and store to Rx:  Rx←−[Ry]
    FLIP = 4'b0101,             //flp Rx and RY; Flip the bits of the value in Ry and store to Rx:  Rx←∼[Ry]
    AND = 4'b0110,              //and Rx and RY; Bit-wise AND the values in Rx and Ry and store the result inRx:  Rx←[Rx] & [Ry]
    OR = 4'b0111,               //or Rx and RY; Bit-wise OR the values in Rx and Ry and store the result inRx:  Rx←[Rx] | [Ry]
    XOR = 4'b1000,              //xor Rx and RY; Bit-wise XOR the values in Rx and Ry and store the result inRx:  Rx←[Rx] ⊕ [Ry]
    LSL = 4'b1001,              //lsl Rx and RY; Logical shift left the value in Rx by Ry and store the result inRx:  Rx←[Rx] << [Ry]
    LSR = 4'b1010,              //lsr Rx and RY; Logical shift right the value in Rx by Ry and store the result inRx:  Rx←[Rx] >> [Ry]
    ASR = 4'b1011,              //asr Rx and RY; Arithmetic shift right the value of Rx by Ry and store the result inRx:  Rx←[Rx] >>> [Ry]
    ADDI = 4'b1100,             //addi Rx, 6’bIIIIII; Add the value in Rx and the 6’bIIIIII and store the result inRx:  Rx←[Rx] + [6’bIIIIII]
    SUBI = 4'b1101;             //subi Rx, 6’bIIIIII; Subtract the value in Rx and the 6’bIIIIII and store the result inRx:  Rx←[Rx] − [6’bIIIIII]

// logic [1:0] Rx = INST[7:6]; //Rx register
// logic [1:0] Ry = INST[5:4]; //Ry register

always_comb begin
    // Initialize all outputs to default values
    IMM = 10'bzzzzzzzzzz;   // Default value for IMM
    Rin = 2'b0;             // Default value for Rin
    Rout = 2'b0;            // Default value for Rout
    ENW = 1'b0;             // Default value for ENW
    ENR = 1'b0;             // Default value for ENR
    Ain = 1'b0;             // Default value for Ain
    Gin = 1'b0;             // Default value for Gin
    Gout = 1'b0;            // Default value for Gout
    ALUcont = 4'bzzzz;      // Default value for ALUcont
    Ext = 1'b0;             // Default value for Ext
    IRin = 1'b0;            // Default value for IRin
    Clr = 1'b0;             // Default value for Clr

    EN_AddressRegRead = 1'b0; // Default value for EN_AddressRegRead
    RAM_read_from_RAM = 1'b0; // Default value for RAM_read_from_RAM
    RAM_write_to_RAM = 1'b0; // Default value for RAM_write_to_RAM

    //! T0: T = 00 Get the instruction from extern into the instruction register
    if (T == 2'b00) begin
        // Initialize all outputs to default values
        IMM = 10'bzzzzzzzzzz;   // Default value for IMM
        Rin = 2'b0;             // Default value for Rin
        Rout = 2'b0;            // Default value for Rout
        ENW = 1'b0;             // Default value for ENW
        ENR = 1'b0;             // Default value for ENR
        Ain = 1'b0;             // Default value for Ain
        Gin = 1'b0;             // Default value for Gin
        Gout = 1'b0;            // Default value for Gout
        ALUcont = 4'bzzzz;      // Default value for ALUcont
        //Ext = 1'b0;             // Default value for Ext
        //IRin = 1'b0;            // Default value for IRin
        Clr = 1'b0;             // Default value for Clr

        EN_AddressRegRead = 1'b0; // Default value for EN_AddressRegRead
        RAM_read_from_RAM = 1'b0; // Default value for RAM_read_from_RAM
        RAM_write_to_RAM = 1'b0; // Default value for RAM_write_to_RAM

        Ext = 1;                //Allow external data input
        IRin = 1;               //Let the instruction register read


    //! T1: T = 01
    end else if (T == 2'b01) begin
        // Initialize all outputs to default values
        IMM = 10'bzzzzzzzzzz;   // Default value for IMM
        Rin = 2'b0;             // Default value for Rin
        Rout = 2'b0;            // Default value for Rout
        ENR = 1'b0;             // Default value for ENR
        ENW = 1'b0;             // Default value for ENW
        Ain = 1'b0;             // Default value for Ain
        Gin = 1'b0;             // Default value for Gin
        Gout = 1'b0;            // Default value for Gout
        ALUcont = 4'bzzzz;      // Default value for ALUcont
        Ext = 1'b0;             // Default value for Ext
        IRin = 1'b0;            // Default value for IRin
        Clr = 1'b0;             // Default value for Clr
    
        EN_AddressRegRead = 1'b0; // Default value for EN_AddressRegRead
        RAM_read_from_RAM = 1'b0; // Default value for RAM_read_from_RAM
        RAM_write_to_RAM = 1'b0; // Default value for RAM_write_to_RAM

        //Rx = INST[7:6];       //Get the Rx register
        //Ry = INST[5:4];       //Get the Ry register

        //LOAD operation
        if (INST[9:8] == 2'b00 && INST[3:0] == LOAD) begin //4'b0000 equals to LOAD
            Ext = 1;            //Allow external data input
            Rin = INST[7:6];    //Load the data into the Rx register
            ENW = 1;            //Let the register file read
            Clr = 1;            //Done with the operation, reset the counter
        end
        
        //COPY operation
        else if (INST[9:8] == 2'b00 && INST[3:0] == 4'b0001) begin //4'b0001 equals to COPY
            Rout = INST[5:4];   //Prep the Ry register to write
            ENR = 1;            //Let the register file write to the bus
            Rin = INST[7:6];    //Load the data into the Rx register
            ENW = 1;            //Let the register file read
            Clr = 1;            //Done with the operation, reset the counter
        end

        //!New additions______________________________
        //LDR operation: Load the data stored in RAM at the 10-bit address stored in Ry to Rx
        else if (INST[9:8] == 2'b00 && INST[3:0] == 4'b1100) begin //4'1100 equals to LDR
            Rout = INST[5:4];    //Prep the Ry register to write
            ENR = 1;            //Let the register file write to bus
            EN_AddressRegRead = 1; //Let AddressReg read
            ENW = 0;            //Don't let the register file read
        end

        //STR operation: 
        else if (INST[9:8] == 2'b00 && INST[3:0] == 4'b1101) begin //4'1101 equals to STR
            Rout = INST[7:6];    //Prep the Rx register to write
            ENR = 1;            //Let the register file write to bus
            EN_AddressRegRead = 1; //Let AddressReg read
            ENW = 0;            //Don't let the register file read
        end

        //Other ALU operations
        else begin
            Rout = INST[7:6];   //Prep the Rx register to write
            ENR = 1;            //Let the register file write to the bus
            Ain = 1;            //Let the A register save the value from the bus
        end

    //! T2: T = 10
    end else if (T == 2'b10) begin
        // Initialize all outputs to default values
        IMM = 10'bzzzzzzzzzz;   // Default value for IMM
        Rin = 2'b0;             // Default value for Rin
        Rout = 2'b0;            // Default value for Rout
        ENW = 1'b0;             // Default value for ENW
        ENR = 1'b0;             // Default value for ENR
        Ain = 1'b0;             // Default value for Ain
        Gin = 1'b0;             // Default value for Gin
        Gout = 1'b0;            // Default value for Gout
        ALUcont = 4'bzzzz;      // Default value for ALUcont
        Ext = 1'b0;             // Default value for Ext
        IRin = 1'b0;            // Default value for IRin
        Clr = 1'b0;             // Default value for Clr
    
        EN_AddressRegRead = 1'b0; // Default value for EN_AddressRegRead
        RAM_read_from_RAM = 1'b0; // Default value for RAM_read_from_RAM
        RAM_write_to_RAM = 1'b0; // Default value for RAM_write_to_RAM

        //Normal ALU operations
        if (INST[9:8] == 2'b00) begin
            //!New additions______________________________
            //LDR operation: Load the data stored in RAM at the 10-bit address stored in Ry to Rx
            if (INST[3:0] == 4'b1100) begin //4'1100 equals to LDR
                EN_AddressRegRead = 0; //Stop SD register from reading
                RAM_read_from_RAM = 1;  //Let RAM read from bus

                ENR = 0;               //Don't let the register file write to the bus
                Rin = INST[7:6];       //Prep Rx register to save the value from the bus
                ENW = 1;               //Let the register file to read the value from the bus
                Clr = 1;            //Done with the operation, reset the counter

            //STR operation: 
            end else if (INST[3:0] == 4'b1101) begin //4'1101 equals to STR
                EN_AddressRegRead = 0; //Stop SD register from reading
                RAM_write_to_RAM = 1;  //Let RAM read from bus

                Rout = INST[5:4];    //Prep the Ry register to write
                ENR = 1;            //Let the register file write to bus
                ENW = 0;            //Don't let the register file read
                Clr = 1;            //Done with the operation, reset the counter
            
            end else begin
                Rout = INST [5:4];  //Prep the Ry register to write
                ENR = 1;            //Let the register file write to the bus
                ALUcont = INST[3:0];//Get the ALU operation from the instruction
                Gin = 1;                //Let the G register save the value from the bus
            end

        //ADDI operation
        end else if (INST[9:8] == 2'b10) begin 
            ENR = 0;             //Don't let the register file write to the bus
            IMM[5:0] = INST[5:0];//Get the immediate value from the instruction
            IMM[9:6] = 4'b0000;  //Set the other bit to 0
            ALUcont = 4'b0010;   //Get the ALU operation from the instruction
            Gin = 1;                //Let the G register save the value from the bus

        //SUBI operation
        end else if (INST[9:8] == 11) begin
            ENR = 0;             //Don't let the register file write to the bus
            IMM[5:0] = INST[5:0];//Get the immediate value from the instruction
            IMM[10:6] = 4'b0000; //Set the other bit to 0
            ALUcont = 4'b0011;   //Get the ALU operation from the instruction
            Gin = 1;                //Let the G register save the value from the bus
        end else begin
            //Blah blahhhh...do nothing
        end

    //! T3: 3rd Timestep
    end else if ( T == 2'b11 ) begin
        // Initialize all outputs to default values
        IMM = 10'bzzzzzzzzzz;   // Default value for IMM
        Rin = 2'b0;             // Default value for Rin
        Rout = 2'b0;            // Default value for Rout
        ENW = 1'b0;             // Default value for ENW
        ENR = 1'b0;             // Default value for ENR
        Ain = 1'b0;             // Default value for Ain
        Gin = 1'b0;             // Default value for Gin
        Gout = 1'b0;            // Default value for Gout
        ALUcont = 4'bzzzz;      // Default value for ALUcont
        Ext = 1'b0;             // Default value for Ext
        IRin = 1'b0;            // Default value for IRin
        //Clr = 1'b0;             // Default value for Clr
        
        EN_AddressRegRead = 1'b0; // Default value for EN_AddressRegRead
        RAM_read_from_RAM = 1'b0; // Default value for RAM_read_from_RAM
        RAM_write_to_RAM = 1'b0; // Default value for RAM_write_to_RAM

        Clr = 1'b0;             // Default value for Clr

        if (INST[9:8] == 2'b00 && INST[3:0] != 4'b1100 && INST[3:0] != 4'b1101) begin
            //Store the value from the bus into the G register and into the Rx register
            Gout = 1;              //Let the G register save the value from the bus
            Rin = INST[7:6];       //Prep Rx register to save the value from the bus
            ENW = 1;               //Let the register file to read the value from the bus
            Clr = 1;               //Done with the operation, reset the counter
        end else begin
            Clr = 1; //Reset the counter
        end
        
    end else begin
        Clr = 1; //Reset the counter
    end
end //for comb

endmodule


/*
Processor Controller
- The ‘brains’ of the processor, and perhaps the most challenging aspect of the design process, is the controller.
- The controller needs to determine the output of each of the control signals for the processor (shown as red in Fig. 1).
- The list of outputs, given in Table 2, are combinational logic that depend on the current timestep T and the current instruction INSTR (from the list in Table 1).
- It is suggested that a time-instruction table similar to that in class is created, and behavioral or procedural logic is derived.

Table 2: Processor Control Signal Outputs

Signal Bit-width Description
- IMM   10  Immediate value to be used for the two immediate instructions
- Rin   2   Address for the register to be written to, from the shared data bus
- Rout  2   Address for the register to be read from, to the shared data bus
- ENW   1   Enable signal to write data to the register file
- ENR   1   Enable signal to read data from the register file
- Ain   1   Enable signal to save data to the intermediate ALU input “A”
- Gin   1   Enable signal to save data to the intermediate ALU output “G”
- Gout  1   Enable signal to write data from the ALU intermediate output “G” to the shared data bus
- ALUcont 4 Signal to control which arithmetic or logic operation the ALU should perform
- Ext   1    Enable signal to drive the shared data bus from the external “data” signal
- IRin  1     Enable signal to save data to the instruction register
- Clr   1     Clear signal for the timestep counter
*/

/*
ld Rx (00_XX_UUU_0000)
    - Load data into Rx from the slide switches (external data input): Rx ← Data
cp Rx, Ry (00_XX_YY_0001)
    - Copy the value from Ry and store to Rx: Rx ← [Ry]
add Rx, Ry (00_XX_YY_0010)
    - Add the values in Rx and Ry and store the result in Rx: Rx ← [Rx] + [Ry]
sub Rx, Ry (00_XX_YY_0011)
    - Subtract the value in Ry from Rx and store the result in Rx: Rx ← [Rx] − [Ry]
inv Rx, Ry (00_XX_YY_0100)
    - Take the twos-complement of the value in Ry and store to Rx: Rx ← −[Ry]
flp Rx, Ry (00_XX_YY_0101)
    - Flip the bits of the value in Ry and store to Rx: Rx ← ∼[Ry]
and Rx, Ry (00_XX_YY_0110)
    - Bit-wise AND the values in Rx and Ry and store the result in Rx: Rx ← [Rx] & [Ry]
or Rx, Ry (00_XX_YY_0111)
    - Bit-wise OR the values in Rx and Ry and store the result in Rx: Rx ← [Rx] | [Ry]
xor Rx, Ry (00_XX_YY_1000)
    - Bit-wise XOR the values in Rx and Ry and store the result in Rx: Rx ← [Rx] ∧ [Ry]
lsl Rx, Ry (00_XX_YY_1001)
    - Logical shift left the value in Rx by Ry and store the result in Rx: Rx ← [Rx] << [Ry]
lsr Rx, Ry (00_XX_YY_1010)
    - Logical shift right the value in Rx by Ry and store the result in Rx: Rx ← [Rx] >> [Ry]
asr Rx, Ry (00_XX_YY_1011)
    - Arithmetic shift right the value of Rx by Ry and store the result in Rx: Rx ← [Rx] >>> [Ry]
addi Rx, 6’bIIIIII (10_XX_IIIIII)
    - Add the 6-bit immediate value 10’b0000IIIIII (left-padded with zeros) to the value in Rx and store in Rx: Rx ← [Rx] + 10’b0000IIIIII
subi Rx, 6’bIIIIII (11_XX_IIIIII)
    - Subtract the 6-bit immediate value 10’b0000IIIIII (left-padded with zeros) from the value in Rx
    - then store in Rx: Rx ← [Rx] - 10’b0000IIIIII
*/
//        


// Authors: John Akujobi, LNU Sukhman Singh, Kay Humphrey
// Date: November, Fall, 2023
// Name: Controller
// Filename: controller.sv
// Description: This module acts as the central controller for the processor.
//  It interprets instructions and sets control signals accordingly.
//  The controller orchestrates the sequence of operations in the processor,
//  managing data flow between registers, ALU, and other components.