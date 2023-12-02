# BitBlaster_10bit_Processor

## Overview

Welcome to the BitBlaster_10bit_Processor!

This repository is home to our custom-designed 10-bit processor, crafted meticulously as part of a project for a Digital Logic Design course at South Dakota State University.

This processor isn't just a piece of code; it's our journey into the heart of computing, that offered us a glimpse into how data is manipulated at the most fundamental level, bridging the gap between theoretical concepts and practical implementation.  Each line of code, each module, weaves together to form the 10 bit processor capable of handling a range of 16 arithmetic and logic operations.

The processor is built to run on the [DE10-Lite board](https://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&No=1021), and was compiled using [Quartus Prime Lite (22.1 std)](https://www.intel.com/content/www/us/en/software-kit/773998/intel-quartus-prime-lite-edition-design-software-version-22-1-1-for-windows.html), a FPGA Development tool by Intel.

## Features

* **10-Bit Data Bus** : Efficiently handles operations with a 10-bit wide shared data bus.
* **Multi-Stage ALU**
  * This is the heart of computation in our processor. 8322
  * It performs several arithmetic, bitwise manipulations and logical operations.
* **Register File**
  * Contains 10-bit registers with read and write capabilities.
* **Controller Module**
  * Our controller module orchestrates the flow of data with precision. It determines how and when each part of the processor acts, ensuring a seamless symphony of digital operations.
* **Output Logic**
  * Visualizes internal processor signals for debugging and educational purposes.
  * Displays this through LEDs and HEX displays on the DE10-Lite board
* **Input Logic**
  * Handles external data inputs and clock signals.
  * This is done through the binary switches on the DE10-Lite board

## Modules

The project consists of several SystemVerilog modules, each responsible for a distinct function within the processor:

1. **Top Level Module (`Bitblaster_10Bit_Processor`)** : Integrates all other modules and serves as the main entry point of the processor.
2. **Controller (`controller`)** : Determines the output of each control signal based on the current instruction and timestep.
3. **ALU (`ALU`)** : Executes arithmetic and logic operations.
4. **Register File (`registerFile`)** : Stores and manages data within the processor.
5. **Input Logic (`inputlogic`)** : Manages external data inputs and debounces signals.
6. **Output Logic (`outputlogic`)** : Provides a visual interface for monitoring processor signals.
7. **Counter (`upcount2`)** : A 2-bit counter module used to track instruction timesteps.
8. **Instruction Register** (`reg10`): This stores the instruction and transmits it to the controller

## Instruction Set

The processor supports a variety of instructions including load, copy, add, subtract, bitwise operations, and shift operations. It also includes immediate value operations for addition and subtraction.

* **Loading and Copying** : Instructions like `ld Rx` and `cp Rx, Ry` enable seamless data loading from external sources and copying between registers. They form the backbone of data movement within the processor.
* **Arithmetic Operations** : With instructions like `add Rx, Ry`, `sub Rx, Ry`, `addi Rx, 6’bIIIIII`, and `subi Rx, 6’bIIIIII`, the processor effortlessly performs basic to complex arithmetic operations, making it ideal for calculations and number manipulations.
* **Bitwise Operations** : Explore the realm of bitwise computing with `and Rx, Ry`, `or Rx, Ry`, `xor Rx, Ry`, `inv Rx, Ry`, and `flp Rx, Ry`. These instructions open doors to logical operations, essential in the world of digital electronics.
* **Shift Operations** : The processor supports logical and arithmetic shifts through `lsl Rx, Ry`, `lsr Rx, Ry`, and `asr Rx, Ry`. These operations are fundamental in tasks that involve bit manipulation and efficient data processing.
* **Immediate Operations** : Our processor simplifies operations with immediate values, adding another layer of versatility. Instructions like `addi` and `subi` facilitate direct arithmetic operations with embedded immediate values, enhancing processing speed and reducing the need for additional data loading steps.

## Usage

In this repository, we have stored the entire processor project which can be download and loaded into Quartus Lite software. After opening up the project in the software, you can click compile, and program the DE10-Lite board. We have done this to make it easy to deploy to your board.

Other wise, to use the modules, import them into your SystemVerilog project and instantiate them according to your needs. The top-level module (`Bitblaster_10Bit_Processor`) serves as a reference for how these modules interact.

As for license, the project is under the GNU General Public License. Please cite and give credit when using parts or whole of this project. Thanks!

## Authors

* **[John Akujobi](https://jakujobi.com/)** - Bitblaster_10Bit_Processor.sv, controller.sv, ALU.sv, registerFile.sv, inputlogic.sv, outputlogic.sv, upcount2.sv, reg10.sv, Quartus Poject setup, Debugging.
* **LNU Sukhman Singh** - Controller, Pin assignment, Debugging, Testing

## End
