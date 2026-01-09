# Project num. 2
## Design Test and Reliability of Electronic Systems

This project refers to a BIST-per-scan circuit, which implements a auto-test of a predefined circuit (CUT). \
The top_leve.v will contain following components:

- CUT (predefined circuit)
- BIST Controller (designed in previous project)
- LFSR (Linear Shift Register, which will generate pseudo-random sequence for a test control)
- Scan (inserted inside of a CUT, all flip-flops inside of the circuit will have to be modified to scan flip-flops)
- MISR (Multiple Input Signature Register, collects CUT outputs and compresses them into a signature - represents the behaviour of the circuit) 
- Signature (Golden Signature, correct, expected, fault-free final value of the MISR after the complete BIST execution)
- Comparator (Compares the current value of a MISR to a Golden Signature and outputs a single bit, reffering to a pass or fail)
Current circuit diagram:
<img width="800" alt="image" src="https://github.com/user-attachments/assets/595f7e7c-63f1-4ae8-bf13-999164edc33e" />


### Obtained results

With this setup and after many different attempts of obtaining the correct result for CUT simulation compared to the top_level module in normal mode. Afterwards the simulation of the bist mode have been executed, which provided us the golden signature that was then used as a standart value for comparison. This created final part of the module and we could normally run a simulation, that gave us the final fault coverage result. 

To check that everything works as it should and that we don't have any major issues inside of the design, the HAL simulation had been executed. Here we were aware, that major issues were representing fatal errors, which didn't occur besides one, that we could just ingore. The rest were only warnings, that we didn't have to deal with.
