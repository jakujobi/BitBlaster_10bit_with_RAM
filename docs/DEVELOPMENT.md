# Development Guide

## Table of Contents
- [Getting Started](#getting-started)
- [Project Structure](#project-structure)
- [Development Workflow](#development-workflow)
- [Pin Assignments](#pin-assignments)
- [Compilation and Synthesis](#compilation-and-synthesis)
- [Testing and Debugging](#testing-and-debugging)
- [Common Issues](#common-issues)

---

## Getting Started

### Development Environment Setup

**Required Software:**

1. **Intel Quartus Prime Lite Edition 22.1** or newer
   - Download: https://www.intel.com/content/www/us/en/software-kit/773998/
   - Size: ~5 GB download, ~20 GB installed
   - OS: Windows, Linux
   - Components needed:
     - Quartus Prime Lite
     - MAX 10 FPGA device support
     - ModelSim-Intel FPGA Starter Edition (optional, for simulation)

2. **USB Blaster Driver**
   - Included with Quartus installation
   - Windows: Drivers install automatically
   - Linux: See [USB Blaster Linux Setup](https://www.intel.com/content/www/us/en/docs/programmable/683689/current/setting-up-the-intel-fpga-download-cable-linux.html)

**Required Hardware:**

- Intel DE10-Lite FPGA Development Board
  - Board ID: 10M50DAF484C7G
  - Purchase: [Terasic DE10-Lite](https://www.terasic.com.tw/cgi-bin/page/archive.pl?No=1021)
  - Price: ~$85 USD (as of 2023)
- USB cable (Type A to Mini-B)

### Initial Setup

```bash
# 1. Clone repository
git clone https://github.com/jakujobi/BitBlaster_10bit_with_RAM.git
cd BitBlaster_10bit_with_RAM

# 2. Open project in Quartus
# Launch Quartus Prime Lite
# File → Open Project → Select:
#   Bitblaster_10Bit_Processor/Bitblaster_10Bit_Processor.qpf

# 3. Verify device settings
# Assignments → Device → Should show:
#   Family: MAX 10
#   Device: 10M50DAF484C7G

# 4. First compilation (to verify setup)
# Processing → Start Compilation
# Or press Ctrl+L
```

**Expected First Compilation Time**: 1-2 minutes

---

## Project Structure

### Directory Layout

```
BitBlaster_10bit_with_RAM/
│
├── SV Module Files/              # Source code (SystemVerilog)
│   ├── Bitblaster_10Bit_Processor.sv  # Top-level integration
│   ├── controller.sv             # Control FSM (850 lines)
│   ├── ALU.sv                    # Arithmetic/Logic Unit
│   ├── registerFile.sv           # 4×10-bit register file
│   ├── ram_1024x10.sv            # 1KB RAM module
│   ├── inputlogic.sv             # Input handling
│   ├── outputlogic.sv            # Display drivers
│   ├── reg10.sv                  # Instruction register
│   ├── upcount2.sv               # Timestep counter
│   ├── debouncer.sv              # Button debouncer
│   └── Trash/                    # Unused/deprecated modules
│       ├── binary4todecimal7decoder.sv
│       ├── decimal7decoder.sv
│       ├── t_ff.sv
│       ├── D_FF_neg.sv
│       └── extrn.sv
│
├── Bitblaster_10Bit_Processor/   # Quartus project
│   ├── Bitblaster_10Bit_Processor.qpf   # Project file
│   ├── Bitblaster_10Bit_Processor.qsf   # Settings file (pin assignments)
│   ├── Bitblaster_10Bit_Processor.qws   # Workspace
│   ├── db/                       # Quartus database (generated)
│   ├── incremental_db/           # Incremental compilation (generated)
│   ├── output_files/             # Compiled bitstreams (.sof, .pof)
│   │   └── Bitblaster_10Bit_Processor.sof  # FPGA programming file
│   └── simulation/               # Simulation files (if used)
│
├── Diagrams/                     # Architecture diagrams
│   ├── 10 bit processor diagram.drawio   # Draw.io source
│   ├── Version 2/
│   └── Version 3/                # Latest diagrams
│
├── Top Level View/               # Schematic exports
│   ├── Top View of Bitblaster_10bit_processor_with_RAM.png
│   ├── Top View of Bitblaster_10bit_processor_with_RAM.svg
│   ├── Top View of Bitblaster_10bit_processor_with_RAM.pdf
│   └── Top View of Bitblaster_10bit_processor_with_RAM.csv  # Netlist
│
├── Project Report Solo/          # Documentation
│   ├── Bitblaster_10bit_Processor_Project Report.pdf
│   └── Bitblaster_10bit_Processor_Project Report.pptx
│
├── Files from Class/             # Course reference materials
│
├── docs/                         # Developer documentation
│   ├── ARCHITECTURE.md           # System architecture
│   └── DEVELOPMENT.md            # This file
│
├── README.md                     # Main project README
├── LICENSE                       # GPL-3.0 license
├── .gitignore                    # Git ignore rules
└── .gitattributes                # Git attributes
```

### Module Dependencies

```
Bitblaster_10Bit_Processor (top)
├── Depends on: All modules below
│
inputlogic
├── Depends on: debouncer (×2 instances)
│
upcount2
├── Depends on: None (standalone)
│
reg10
├── Depends on: None (standalone)
│
controller
├── Depends on: None (combinational logic only)
│
registerFile
├── Depends on: None (standalone)
│
ram_1024x10
├── Depends on: None (standalone)
│
ALU
├── Depends on: None (standalone)
│
outputlogic
├── Depends on: None (uses internal functions)
│
debouncer
├── Depends on: None (standalone)
```

**Compilation Order**: Quartus automatically determines correct order.

---

## Development Workflow

### Making Changes

**Typical workflow:**

1. **Edit source files**
   - Use any text editor (VS Code, Sublime, Notepad++, etc.)
   - SystemVerilog syntax highlighting recommended
   - Files located in `SV Module Files/`

2. **Analysis & Synthesis** (quick check, ~30 seconds)
   ```
   Processing → Start → Analysis & Elaboration
   ```
   - Checks syntax errors
   - Verifies module instantiations
   - Does not place/route

3. **Full Compilation** (complete build, ~1-2 minutes)
   ```
   Processing → Start Compilation
   Or: Ctrl+L
   ```
   - Analysis & Synthesis
   - Fitter (Place & Route)
   - Timing Analysis
   - Assembler (generates .sof file)

4. **Review compilation report**
   ```
   Processing → Compilation Report
   ```
   - Check for warnings
   - Verify resource utilization
   - Review timing analysis

5. **Program FPGA**
   ```
   Tools → Programmer
   ```
   - Select Hardware Setup (USB-Blaster)
   - Mode: JTAG
   - Add File: output_files/Bitblaster_10Bit_Processor.sof
   - Check "Program/Configure"
   - Click "Start"

6. **Test on hardware**
   - Use switches to input instructions/data
   - Observe LEDs and 7-segment displays
   - Press clock button to step through instructions

### Recommended VS Code Extensions

```json
{
  "recommendations": [
    "mshr-h.veriloghdl",           // SystemVerilog support
    "leafvmaple.verilog",          // Additional Verilog tools
    "eirikpre.systemverilog",      // SystemVerilog syntax
    "mermaid.mermaid-markdown-syntax-highlighting"  // For diagrams
  ]
}
```

### Git Workflow

```bash
# Create feature branch
git checkout -b feature/your-feature-name

# Make changes
# Edit files...

# Commit changes
git add SV\ Module\ Files/your_module.sv
git commit -m "Brief description of change"

# Push to GitHub
git push origin feature/your-feature-name

# Open Pull Request on GitHub
```

**What to commit:**
- ✅ `.sv` source files
- ✅ `.qpf`, `.qsf` project files
- ✅ Documentation (`.md` files)
- ✅ Diagrams (`.drawio`, exported `.png`/`.svg`)

**What NOT to commit:**
- ❌ `db/` directory
- ❌ `incremental_db/` directory
- ❌ `output_files/` (except for releases)
- ❌ `.qws` workspace files
- ❌ Simulation waveforms (`.vwf`)
- ❌ Temporary files

`.gitignore` is configured to handle most of these automatically.

---

## Pin Assignments

### Complete Pin Mapping

All pins are assigned in `Bitblaster_10Bit_Processor.qsf`. Below is the complete mapping:

#### Clock and Reset

| Signal | Pin | Type | Description |
|--------|-----|------|-------------|
| `Clock_50MHz` | PIN_P11 | Input | System 50 MHz oscillator |
| `Clock_Button` | PIN_B8 | Input | Manual clock (KEY1) |
| `Peek_Button` | PIN_A7 | Input | Register peek (KEY0) |

#### Input Switches (SW[9:0])

| Signal | Pin | Bit | Physical Switch |
|--------|-----|-----|-----------------|
| `Raw_Data_From_Switches[0]` | PIN_C10 | LSB | SW0 |
| `Raw_Data_From_Switches[1]` | PIN_C11 | | SW1 |
| `Raw_Data_From_Switches[2]` | PIN_D12 | | SW2 |
| `Raw_Data_From_Switches[3]` | PIN_C12 | | SW3 |
| `Raw_Data_From_Switches[4]` | PIN_A12 | | SW4 |
| `Raw_Data_From_Switches[5]` | PIN_B12 | | SW5 |
| `Raw_Data_From_Switches[6]` | PIN_A13 | | SW6 |
| `Raw_Data_From_Switches[7]` | PIN_A14 | | SW7 |
| `Raw_Data_From_Switches[8]` | PIN_B14 | | SW8 |
| `Raw_Data_From_Switches[9]` | PIN_F15 | MSB | SW9 |

#### Output LEDs (LEDR[9:0])

| Signal | Pin | Bit | Physical LED |
|--------|-----|-----|--------------|
| `LED_B_Data_Bus[0]` | PIN_A8 | LSB | LEDR0 |
| `LED_B_Data_Bus[1]` | PIN_A9 | | LEDR1 |
| `LED_B_Data_Bus[2]` | PIN_A10 | | LEDR2 |
| `LED_B_Data_Bus[3]` | PIN_B10 | | LEDR3 |
| `LED_B_Data_Bus[4]` | PIN_D13 | | LEDR4 |
| `LED_B_Data_Bus[5]` | PIN_C13 | | LEDR5 |
| `LED_B_Data_Bus[6]` | PIN_E14 | | LEDR6 |
| `LED_B_Data_Bus[7]` | PIN_D14 | | LEDR7 |
| `LED_B_Data_Bus[8]` | PIN_A11 | | LEDR8 |
| `LED_B_Data_Bus[9]` | PIN_B11 | MSB | LEDR9 |

#### 7-Segment Display HEX0 (Data LSB)

| Signal | Pin | Segment |
|--------|-----|---------|
| `DHEX0[0]` | PIN_C14 | a |
| `DHEX0[1]` | PIN_E15 | b |
| `DHEX0[2]` | PIN_C15 | c |
| `DHEX0[3]` | PIN_C16 | d |
| `DHEX0[4]` | PIN_E16 | e |
| `DHEX0[5]` | PIN_D17 | f |
| `DHEX0[6]` | PIN_C17 | g |

#### 7-Segment Display HEX1 (Data Middle)

| Signal | Pin | Segment |
|--------|-----|---------|
| `DHEX1[0]` | PIN_C18 | a |
| `DHEX1[1]` | PIN_D18 | b |
| `DHEX1[2]` | PIN_E18 | c |
| `DHEX1[3]` | PIN_B16 | d |
| `DHEX1[4]` | PIN_A17 | e |
| `DHEX1[5]` | PIN_A18 | f |
| `DHEX1[6]` | PIN_B17 | g |

#### 7-Segment Display HEX2 (Data MSB)

| Signal | Pin | Segment |
|--------|-----|---------|
| `DHEX2[0]` | PIN_B20 | a |
| `DHEX2[1]` | PIN_A20 | b |
| `DHEX2[2]` | PIN_B19 | c |
| `DHEX2[3]` | PIN_A21 | d |
| `DHEX2[4]` | PIN_B21 | e |
| `DHEX2[5]` | PIN_C22 | f |
| `DHEX2[6]` | PIN_B22 | g |

#### 7-Segment Display HEX5 (Timestep)

| Signal | Pin | Segment |
|--------|-----|---------|
| `THEX_Current_Timestep[0]` | PIN_F21 | a |
| `THEX_Current_Timestep[1]` | PIN_E22 | b |
| `THEX_Current_Timestep[2]` | PIN_E21 | c |
| `THEX_Current_Timestep[3]` | PIN_C19 | d |
| `THEX_Current_Timestep[4]` | PIN_C20 | e |
| `THEX_Current_Timestep[5]` | PIN_D19 | f |
| `THEX_Current_Timestep[6]` | PIN_E17 | g |

#### Done LED

| Signal | Pin | Type |
|--------|-----|------|
| `LED_D_Done` | PIN_A12 | Output |

### Modifying Pin Assignments

**Method 1: Quartus Pin Planner**
```
Assignments → Pin Planner
```
- Visual interface
- Drag and drop pins
- Auto-saves to .qsf file

**Method 2: Edit .qsf directly**
```tcl
set_location_assignment PIN_XX -to signal_name
```

**After changing pins:**
1. Save project
2. Recompile (Ctrl+L)
3. Reprogram FPGA

---

## Compilation and Synthesis

### Compilation Stages

1. **Analysis & Synthesis**
   - Parses SystemVerilog files
   - Elaborates hierarchy
   - Performs logic optimization
   - Outputs: Technology-mapped netlist
   - Time: ~30 seconds

2. **Fitter (Place & Route)**
   - Places logic elements on FPGA
   - Routes interconnections
   - Optimizes for timing/area
   - Time: ~45 seconds

3. **Timing Analysis**
   - Checks setup/hold times
   - Reports critical paths
   - Verifies clock constraints
   - Time: ~5 seconds

4. **Assembler**
   - Generates programming file (.sof)
   - Creates fuse map
   - Time: ~5 seconds

**Total compilation time**: 1-2 minutes

### Reading Compilation Reports

#### Resource Utilization

```
Compilation Report → Fitter → Resource Section
```

Look for:
- Total logic elements used (~500 for this design)
- Embedded memory bits (~10,240 for RAM)
- Pin count (~50 pins)

**Example output:**
```
; Fitter Summary                         ;
+-----------------------------------------+
; Total logic elements : 478 / 49,760    ;
; Total registers      : 156             ;
; Total pins           : 52 / 360        ;
; Total memory bits    : 10,240 / 1,638,400 ;
+-----------------------------------------+
```

#### Timing Analysis

```
Compilation Report → TimeQuest Timing Analyzer
```

**Key metrics:**
- Slack: Positive = timing met, Negative = timing violated
- Fmax: Maximum safe clock frequency

**For this design:**
- Expected Fmax: >100 MHz (ample margin for 50 MHz clock)
- Critical path: Usually in controller combinational logic

### Compilation Warnings

**Common warnings to ignore:**

```
Warning (332060): Node: XYZ was determined to be a clock
```
- Harmless, Quartus auto-detected clocks

```
Warning (15714): Some pins have incomplete I/O assignments
```
- Only if unused pins, safe to ignore

**Warnings to investigate:**

```
Critical Warning (332148): Timing requirements not met
```
- Check timing report
- May need clock constraints or logic optimization

```
Warning (10030): Verilog HDL Continuous Assignment warning
```
- Check for unintended latches or combinational loops

---

## Testing and Debugging

### Hardware Testing Procedure

**1. Load Instruction Test**
```
Purpose: Verify instruction fetch and register write

Steps:
1. Set SW[9:0] = 0000000000 (ld R0 instruction)
2. Press Clock_Button once
3. Set SW[9:0] = 0000101010 (value 42 decimal)
4. Press Clock_Button once
5. Observe LEDR[9:0] should show 0000101010

Expected: R0 now contains 42
```

**2. ALU Operation Test**
```
Purpose: Verify arithmetic operations

Steps:
1. Load 5 into R0 (instruction: 0000000000, data: 0000000101)
2. Load 3 into R1 (instruction: 0001000000, data: 0000000011)
3. ADD R2, R0, R1 (instruction: 0010000010)
   - Requires 4 clock pulses (T0→T1→T2→T3)
4. Check HEX5 counts 0→1→2→3→0
5. Result should be in R2

Expected: R2 = 8 (binary: 0000001000)
```

**3. Peek Function Test**
```
Purpose: Verify register peek capability

Steps:
1. Load known values into R0, R1, R2, R3
2. Set SW[1:0] = 00 (select R0)
3. Hold Peek_Button (KEY0)
4. Observe HEX2-0 display R0 contents
5. Release button
6. Change SW[1:0] to 01, 10, 11 and repeat

Expected: HEX displays switch between bus and selected register
```

**4. RAM Test**
```
Purpose: Verify memory operations

Steps:
1. Load address 100 into R0
2. Load value 255 into R1
3. Execute STR R0, R1 (store R1 to RAM[R0])
4. Load address 100 into R2
5. Execute LDR R3, R2 (load from RAM[R2] to R3)
6. Peek into R3

Expected: R3 = 255
```

### Debugging Techniques

#### 1. LED Observation

- **LEDR[9:0]**: Real-time data bus monitor
  - Shows current value on bus
  - Updates immediately as bus changes
  
- **HEX5**: Timestep indicator
  - 0 = Instruction fetch
  - 1 = Decode/operand read
  - 2 = Execute
  - 3 = Writeback
  - Should cycle 0→1→2→3→0 for each instruction

#### 2. Signal Tap Logic Analyzer

For advanced debugging, use Quartus Signal Tap:

```
Tools → Signal Tap Logic Analyzer
```

**Recommended signals to probe:**
- `Shared_Data_Bus[9:0]`
- `Timestep_2_bits[1:0]`
- `Instruction_From_IR[9:0]`
- `ENR_ENR0`, `ENW_ENW` (register file controls)
- `Ain_Ain`, `Gin_Gin`, `Gout_Gout` (ALU controls)

#### 3. Simulation (Optional)

If ModelSim is installed:

```
Tools → Run Simulation Tool → RTL Simulation
```

**Note**: No pre-configured testbenches exist in this project. You would need to create your own `.sv` testbench files.

#### 4. Manual Inspection

For persistent issues:
1. Check controller.sv state transitions
2. Verify module instantiation in top-level
3. Check for tri-state conflicts on data bus
4. Verify all control signals default to safe states

---

## Common Issues

### Issue: FPGA not detected by programmer

**Symptoms**: Programmer shows "No hardware detected"

**Solutions**:
1. Check USB cable connection
2. Verify DE10-Lite power switch is ON
3. Windows: Check Device Manager for USB-Blaster driver
4. Linux: Check USB permissions (`lsusb` should show Altera USB-Blaster)
5. Try different USB port (use USB 2.0, not 3.0)

### Issue: Design doesn't work after programming

**Symptoms**: LEDs don't respond, displays blank

**Solutions**:
1. Press RESET button on DE10-Lite (if exists)
2. Check Clock_50MHz is connected to correct pin (P11)
3. Verify all switches in middle position before programming
4. Re-program FPGA (sometimes first programming fails)
5. Check compilation report for warnings/errors

### Issue: Timing errors during compilation

**Symptoms**: "Timing requirements not met" in Fitter report

**Solutions**:
1. This design should not have timing issues at 50 MHz
2. If present, check for unintended combinational loops
3. Review critical path in TimeQuest Analyzer
4. Ensure all sequential elements use same clock edge (negative)

### Issue: Data bus shows 'X' or erratic values

**Symptoms**: LEDs flicker, inconsistent values

**Solutions**:
1. Check for multiple drivers on `Shared_Data_Bus`
2. Verify all tri-state outputs default to `10'bz`
3. Ensure only one enable signal active per cycle
4. Check controller.sv for proper mutual exclusion

### Issue: RAM doesn't store/retrieve correctly

**Symptoms**: LDR/STR instructions fail

**Solutions**:
1. Verify address register loads properly in T1
2. Check RAM enable signals in controller.sv (lines 180-200)
3. Ensure address is stable before read/write operation
4. Test with known address (e.g., 0, 1, 2) first

### Issue: Quartus compilation very slow

**Symptoms**: Compilation takes >5 minutes

**Solutions**:
1. Close other applications (Quartus uses lots of RAM)
2. Disable incremental compilation if corrupted:
   ```
   Assignments → Settings → Incremental Compilation → Off
   ```
3. Clean project: `Project → Clean...`
4. Delete `db/` and `incremental_db/` folders manually

---

## Performance Optimization

### Reducing Compilation Time

1. **Incremental Compilation** (already enabled)
   - Recompiles only changed modules
   - Saves ~50% time on minor changes

2. **Smart Compilation**
   ```
   Processing → Start → Start Smart Compilation
   ```
   - Skips unnecessary stages

3. **Parallel Compilation**
   ```
   Tools → Options → Processing → Maximum processors: <number>
   ```
   - Use all CPU cores

### Improving FPGA Performance

Current design is not performance-critical (manual clock), but for faster operation:

1. **Register Outputs**: Already done (all outputs from FF)
2. **Pipeline Optimization**: Could reduce to 3 cycles for some ops
3. **Clock Constraints**: Add SDC file for timing-driven compilation

---

## Advanced Topics

### Adding New Instructions

**Example: Adding a NOP (No Operation) instruction**

1. **Choose opcode**: e.g., `00_00_00_1110`

2. **Modify controller.sv**:
   ```systemverilog
   // In T1 section
   else if (INST[9:8] == 2'b00 && INST[3:0] == 4'b1110) begin
       // NOP - do nothing, just clear
       Clr = 1;
   end
   ```

3. **Test**: Load instruction `0000001110`, verify timestep advances

4. **Document**: Update README instruction table

### Creating a Simulation Testbench

**Basic testbench template**:

```systemverilog
`timescale 1ns / 1ps

module tb_processor();
    logic [9:0] switches;
    logic clk_50mhz;
    logic peek_btn, clk_btn;
    logic [9:0] leds;
    logic [6:0] hex0, hex1, hex2, hex5;
    logic led_done;
    
    // Instantiate DUT
    Bitblaster_10Bit_Processor dut (
        .Raw_Data_From_Switches(switches),
        .Clock_50MHz(clk_50mhz),
        .Peek_Button(peek_btn),
        .Clock_Button(clk_btn),
        .LED_B_Data_Bus(leds),
        .DHEX0(hex0),
        .DHEX1(hex1),
        .DHEX2(hex2),
        .THEX_Current_Timestep(hex5),
        .LED_D_Done(led_done)
    );
    
    // Clock generation
    initial clk_50mhz = 0;
    always #10 clk_50mhz = ~clk_50mhz;  // 50 MHz
    
    // Test sequence
    initial begin
        // Initialize
        switches = 10'b0;
        peek_btn = 1;  // Active low
        clk_btn = 1;   // Active low
        
        #100;  // Wait for startup
        
        // Load instruction
        switches = 10'b0000000000;  // ld R0
        #20 clk_btn = 0;
        #20 clk_btn = 1;
        
        // Load data
        switches = 10'b0000001010;  // value 10
        #20 clk_btn = 0;
        #20 clk_btn = 1;
        
        #100;
        $display("Test complete");
        $finish;
    end
endmodule
```

---

## Resources

### Official Documentation

- [Quartus Prime User Guide](https://www.intel.com/content/www/us/en/docs/programmable/683705/current/introduction.html)
- [DE10-Lite User Manual](https://www.terasic.com.tw/cgi-bin/page/archive.pl?No=1021)
- [MAX 10 FPGA Handbook](https://www.intel.com/content/www/us/en/docs/programmable/683751/current/introduction.html)

### Learning Resources

- [SystemVerilog Tutorial](https://www.chipverify.com/systemverilog/systemverilog-tutorial)
- [FPGA Design Flow](https://www.intel.com/content/www/us/en/docs/programmable/683082/current/getting-started-with-intel-fpga-design.html)
- Digital Design and Computer Architecture (textbook by Harris & Harris)

### Support

- [Intel FPGA Forums](https://community.intel.com/t5/FPGA-Wiki/ct-p/fpga-wiki)
- [Terasic Forums](https://forum.terasic.com/)
- Project Issues: https://github.com/jakujobi/BitBlaster_10bit_with_RAM/issues

---

*Last Updated: February 2024*
