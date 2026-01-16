# BIST-per-Scan Circuit Implementation

## Project Overview

This project implements a comprehensive Built-In Self-Test (BIST) system using scan chain methodology for automated circuit testing. The BIST architecture enables self-testing of a predefined Circuit Under Test (CUT) without external test equipment.

### Course Information
- **Course**: Design Test and Reliability of Electronic Systems
- **Project**: Project #2 - BIST-per-Scan Implementation

## System Architecture

The BIST system integrates the following key components:

### Core Components

1. **Circuit Under Test (CUT)** (`cut.v`)
   - The target circuit to be tested
   - Modified with scan flip-flops for testability
   - Implements a finite state machine with multiple operational states

2. **BIST Controller** (`controller.v`)
   - Orchestrates the entire BIST sequence
   - Manages state transitions through six states (S0-S5)
   - Controls test initialization, execution, and completion
   - Parameters: N=13 scan cycles, M=1023 test patterns

3. **Linear Feedback Shift Register (LFSR)** (`lfsr.v`)
   - Generates pseudo-random test patterns
   - 16-bit maximal-length LFSR
   - Configurable seed for pattern optimization
   - Polynomial: x^16 + x^15 + x^13 + x^4 + 1

4. **Scan Chain**
   - Converts all CUT flip-flops to scan flip-flops
   - Enables serial test pattern loading
   - Facilitates observability of internal states

5. **Multiple Input Signature Register (MISR)** (`misr.v`)
   - Compresses CUT output responses into a signature
   - 16-bit signature register
   - Compresses 10-bit input vector (scan_out, fz_L, lclk, read_a[4:0], test_out[1:0])
   - Generates golden signature for fault-free operation

6. **Comparator**
   - Integrated within MISR module
   - Compares final signature against golden signature
   - Outputs pass/fail result

### System Diagram

<img width="800" alt="image" src="https://github.com/user-attachments/assets/595f7e7c-63f1-4ae8-bf13-999164edc33e" />

## File Structure

### Source Files
- `top_module.v` - Top-level BIST integration
- `controller.v` - BIST controller FSM
- `cut.v` - Circuit under test (original)
- `cut_scan_syn.v` - Synthesized CUT with scan chain
- `lfsr.v` - Pseudo-random pattern generator
- `misr.v` - Signature analyzer and comparator

### Testbenches
- `tb_cut.v` - CUT standalone testbench
- `tb_top_level_normal.v` - Top-level normal mode simulation
- `tb_top_level_bist.v` - BIST mode simulation
- `tb_top_level_controller.v` - Controller verification testbench

### Synthesis Scripts
- `synthesis_dft.tcl` - DFT synthesis (scan insertion)
- `synthesis_bist.tcl` - BIST system synthesis

### Configuration Files
- `fault.file` - Fault simulation configuration
- `strobes.tcl` - Signal strobing for fault simulation

### Automation Scripts
- `reseeding.py` - Automated seed optimization for coverage improvement

## Operation Modes

### Normal Mode
- `bist_start = 0`
- CUT operates in functional mode
- Direct input/output access to CUT
- Used for functional verification

### BIST Mode
- `bist_start = 1`
- Automated test sequence execution
- Controller manages test flow
- LFSR provides test patterns
- MISR collects and compresses responses

## BIST Controller States

| State | Description | Outputs |
|-------|-------------|---------|
| S0 | Idle - Waiting for BIST start | All outputs low |
| S1 | Initialize - Reset LFSR and MISR | init=1 |
| S2 | Running - Apply test patterns | mode=1, running=1 |
| S3 | Pattern complete - Check iteration count | running=1 |
| S4 | Finish - Final signature ready | finish=1 |
| S5 | End - BIST complete, results available | bist_end=1 |

## Test Sequence

1. **Initialization**: Reset system, load LFSR seed
2. **Pattern Generation**: LFSR generates pseudo-random patterns
3. **Scan Load**: Patterns shifted into CUT scan chain (13 cycles)
4. **Capture**: CUT executes one functional cycle
5. **Scan Unload**: Response captured and compressed into MISR
6. **Iteration**: Repeat steps 2-5 for M=1023 test patterns
7. **Comparison**: Final MISR signature compared to golden signature
8. **Result**: Pass/fail indication based on signature match

## Fault Coverage Optimization

The `reseeding.py` script automates the process of finding optimal LFSR seeds to maximize fault coverage:

### Features
- Target coverage: 95% (configurable)
- Automatic seed generation and testing
- Iterative simulation and fault analysis
- Comprehensive logging of results
- Parses fault coverage statistics (detected, potentially detected, undetected)

### Process
1. Generate random 16-bit LFSR seed
2. Update LFSR configuration
3. Run RTL simulation to generate golden signature
4. Update MISR with golden signature
5. Run fault simulation and synthesis
6. Parse fault coverage results
7. Log iteration data
8. Repeat until target coverage achieved

### Usage
```bash
python reseeding.py
```

The script automatically:
- Modifies `sources/lfsr.v` (line 18) with new seeds
- Updates `sources/misr.v` (line 19) with golden signatures
- Logs all iterations to `reports/bist_coverage_log.txt`
- Stops when coverage target is met

## Simulation and Verification

### RTL Simulation
```bash
# Normal mode simulation
make SIM_rtl_top_level_normal

# BIST mode simulation  
make SIM_rtl_top_level_bist

# Controller verification
make SIM_rtl_top_level_controller
```

### Synthesis
```bash
# DFT synthesis (scan insertion)
make SYN_dft

# BIST system synthesis
make SYN_final
```

### Fault Simulation
```bash
# Concurrent fault simulation
make FS_concurrent
```

## Key Design Parameters

| Parameter | Value | Description |
|-----------|-------|-------------|
| LFSR Width | 16 bits | Pattern generator register size |
| MISR Width | 16 bits | Signature register size |
| Scan Cycles (N) | 13 | Cycles per pattern load/unload |
| Test Patterns (M) | 1023 | Total number of test vectors |
| Clock Period | 4000 ns | System clock period |
| Target Coverage | 95% | Fault detection goal |

## Golden Signature

The golden signature represents the fault-free response of the CUT to the complete test pattern sequence. It is:
- Generated during BIST mode simulation
- Stored in `reports/golden-signature.txt`
- Embedded in MISR module as `GOLDEN_SIGNATURE` parameter
- Used for pass/fail determination

**Current Golden Signature**: `16'b1110010100001001`

## Results and Validation

### Verification Steps
1. **Functional Verification**: Compare CUT standalone vs. top-level normal mode
2. **BIST Execution**: Run BIST mode to generate golden signature
3. **Fault Coverage**: Evaluate stuck-at fault detection capability
4. **HAL Simulation**: Verify design integrity (warnings acceptable, fatal errors indicate problems)

### Success Criteria
- ✓ Normal mode output matches standalone CUT simulation
- ✓ BIST completes successfully (bist_end asserted)
- ✓ Golden signature generated and validated
- ✓ Fault coverage meets or exceeds target (95%)
- ✓ No fatal errors in HAL simulation

## Technology

- **Target Technology**: AMS C35 0.35μm CMOS
- **Library**: c35_CORELIB_TYP
- **Supply Voltage**: 3.3V
- **Synthesis Tool**: Cadence GENUS
- **Simulation**: Verilog HDL

## Important Notes

1. **Seed Selection**: LFSR seed must be non-zero for proper PRNG operation
2. **Timing**: All testbenches use synchronized clock edges for deterministic behavior
3. **Scan Chain**: Auto-generated during DFT synthesis, not manually specified
4. **Reset Handling**: Both synchronous reset for FSM and initialization pulse for LFSR/MISR
5. **Golden Signature**: Must be regenerated if LFSR seed or test parameters change

## Troubleshooting

### Common Issues

**Issue**: Signature mismatch  
**Solution**: Regenerate golden signature after any design or seed changes

**Issue**: Low fault coverage  
**Solution**: Run `reseeding.py` to find better LFSR seed

**Issue**: Simulation doesn't complete  
**Solution**: Check controller parameter N and M values, verify vector files loaded

**Issue**: Fatal errors in HAL  
**Solution**: Review synthesis reports, check for design rule violations

## Future Enhancements

- Multiple scan chains for reduced test time
- Adaptive LFSR reseeding during test
- Built-in test pattern generation (ATPG)
- On-chip diagnosis capabilities
- Power-aware BIST scheduling

## References

- IEEE 1149.1 Standard (JTAG/Boundary Scan)
- IEEE 1500 Standard (Embedded Core Test)
- DFT best practices and methodologies
- Stuck-at fault models

---

**Last Updated**: January 2026  
**Status**: Functional with validated fault coverage results
