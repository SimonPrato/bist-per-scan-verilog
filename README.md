# Project num. 2
## Design Test and Reliability of Electronic Systems

This project refers to a BIST-per-scan circuit, which implements a auto-test of a predefined circuit (CUT). 
    The top_leve.v will contain following components:
        + CUT (predefined circuit)
        + BIST Controller (designed in previous project)
        + LFSR (Linear Shift Register, which will generate pseudo-random sequence for a test control)
        + Scan (inserted inside of a CUT, all flip-flops inside of the circuit will have to be modified to scan flip-flops)
        + MISR (Multiple Input Signature Register, collects CUT outputs and compresses them into a signature - represents the behaviour of the circuit)
        + Signature (Golden Signature, correct, expected, fault-free final value of the MISR after the complete BIST execution)
        + Comparator (Compares the current value of a MISR to a Golden Signature and outputs a single bit, reffering to a pass or fail)

Current circuit diagram:
<img width="1285" height="944" alt="image" src="https://github.com/user-attachments/assets/392c7d6a-63c0-4b72-a5be-91f2c596236b" />
