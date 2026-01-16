"""
BIST Seed Optimization Script

Automatically finds optimal LFSR seeds to maximize fault coverage.
Iteratively tests random seeds until target coverage is achieved.
"""

import subprocess
import re
import random
import os
from datetime import datetime

TARGET_COVERAGE = 0.95
LFSR_FILE = 'sources/lfsr.v'
LFSR_LINE_NUM = 18
MISR_FILE = 'sources/misr.v'
MISR_LINE_NUM = 19
GOLDEN_SIGNATURE_FILE = 'reports/golden-signature.txt'
LOG_FILE = 'reports/bist_coverage_log.txt'

def clear_console():
    """Clear the console screen."""
    os.system('cls' if os.name == 'nt' else 'clear')

def replace_line_in_file(filename, line_num, new_content):
    """Replace a specific line in a file with new content."""
    with open(filename, 'r') as file:
        lines = file.readlines()
    
    if 1 <= line_num <= len(lines):
        lines[line_num - 1] = new_content + '\n'
    
    with open(filename, 'w') as file:
        file.writelines(lines)

def generate_random_seed():
    """Generate a random 16-bit integer (0 to 65535)."""
    return random.getrandbits(16)

def update_lfsr_seed(seed):
    """Update the LFSR file with a new seed value."""
    line_content = "	shift_reg <= {seed};".format(seed=seed)
    replace_line_in_file(LFSR_FILE, LFSR_LINE_NUM, line_content)

def run_simulation():
    """Run the RTL simulation."""
    subprocess.call(['make', 'SIM_rtl_top_level_bist'], shell=True)

def read_golden_signature():
    """Read and return the golden signature from file."""
    with open(GOLDEN_SIGNATURE_FILE, 'r') as f:
        return f.read().replace('\n', '')

def update_misr_signature(golden_signature):
    """Update the MISR file with the golden signature."""
    line_content = "	localparam [15:0] GOLDEN_SIGNATURE = {golden_signature};".format(golden_signature=golden_signature)
    replace_line_in_file(MISR_FILE, MISR_LINE_NUM, line_content)

def run_seed_finding():
    """Run the seed finding process and return the output."""
    subprocess.check_output(['make', 'SYN_final'], stderr=subprocess.STDOUT)
    return subprocess.check_output(['make', 'FS_concurrent'], stderr=subprocess.STDOUT)

def parse_fault_coverage(output):
    """Parse fault coverage statistics from the simulation output."""
    decoded_output = output.decode()

    table_marker = "Stuck-At (0/1) Fault Table"
    marker_pos = decoded_output.find(table_marker)

    if marker_pos == -1:
        raise ValueError("Could not find 'Stuck-At (0/1) Fault Table' in output")

    output_trimmed = decoded_output[marker_pos:]

    pattern = (
        r'Detected\s+(\d+)\s+(\d+)\s*\n'
        r'\s*Potentially_detected\s+(\d+)\s+(\d+)\s*\n'
        r'\s*Undetected\s+(\d+)\s+(\d+)'
    )

    match = re.search(pattern, output_trimmed)
    if not match:
        raise ValueError("Could not parse fault coverage statistics")

    detected_total = float(match.group(1))
    detected_prime = float(match.group(2))
    pot_detected_total = float(match.group(3))
    pot_detected_prime = float(match.group(4))
    undetected_total = float(match.group(5))
    undetected_prime = float(match.group(6))
    matched_text = match.group(0)

    return (detected_total, detected_prime, pot_detected_total,
            pot_detected_prime, undetected_total, undetected_prime, match, matched_text)

def calculate_coverage(detected, potentially_detected, undetected):
    """Calculate the fault coverage percentage."""
    total = detected + potentially_detected + undetected
    if total == 0:
        return 0.0
    return (detected + potentially_detected) / total

def log_iteration_data(log_file, iteration, seed, detected_total, detected_prime, 
                       pot_detected_total, pot_detected_prime, undetected_total, 
                       undetected_prime, coverage_total, coverage_prime, match_obj, matched_text):
    """Write iteration data to log file."""
    with open(log_file, 'a') as f:
        f.write("=" * 80 + "\n")
        f.write("Iteration: {}\n".format(iteration))
        f.write("Seed: {}\n".format(seed))
        f.write("Timestamp: {}\n".format(datetime.now().strftime("%Y-%m-%d %H:%M:%S")))
        f.write("-" * 80 + "\n")
        f.write("Matched Table Lines:\n")
        if matched_text:
            f.write(matched_text + "\n")
        else:
            f.write("  No matched text available\n")
        f.write("-" * 80 + "\n")
        f.write("Regex Match Groups:\n")
        if match_obj:
            f.write("  Group 1 (Detected Total):           {}\n".format(match_obj.group(1)))
            f.write("  Group 2 (Detected Prime):           {}\n".format(match_obj.group(2)))
            f.write("  Group 3 (Pot Detected Total):       {}\n".format(match_obj.group(3)))
            f.write("  Group 4 (Pot Detected Prime):       {}\n".format(match_obj.group(4)))
            f.write("  Group 5 (Undetected Total):         {}\n".format(match_obj.group(5)))
            f.write("  Group 6 (Undetected Prime):         {}\n".format(match_obj.group(6)))
        else:
            f.write("  No match object available\n")
        f.write("-" * 80 + "\n")
        f.write("Fault Statistics:\n")
        f.write("  Detected Total:           {}\n".format(detected_total))
        f.write("  Detected Prime:           {}\n".format(detected_prime))
        f.write("  Potentially Detected Total: {}\n".format(pot_detected_total))
        f.write("  Potentially Detected Prime: {}\n".format(pot_detected_prime))
        f.write("  Undetected Total:         {}\n".format(undetected_total))
        f.write("  Undetected Prime:         {}\n".format(undetected_prime))
        f.write("-" * 80 + "\n")
        f.write("Coverage:\n")
        f.write("  Total Coverage: {:.2%}\n".format(coverage_total))
        f.write("  Prime Coverage: {:.2%}\n".format(coverage_prime))
        f.write("=" * 80 + "\n\n")

def main():
    """Main function to find optimal BIST seed for target fault coverage."""
    with open(LOG_FILE, 'w') as f:
        f.write("BIST Seed Finding Log\n")
        f.write("Started: {}\n".format(datetime.now().strftime("%Y-%m-%d %H:%M:%S")))
        f.write("Target Coverage: {:.2%}\n".format(TARGET_COVERAGE))
        f.write("\n")
    
    detected_total = 0.0
    detected_prime = 0.0
    pot_detected_total = 0.0
    pot_detected_prime = 0.0
    undetected_total = 1.0
    undetected_prime = 1.0
    match_obj = None
    matched_text = None
    
    iteration = 0
    seed = 0
    
    while True:
        clear_console()
        
        coverage_total = calculate_coverage(detected_total, pot_detected_total, undetected_total)
        coverage_prime = calculate_coverage(detected_prime, pot_detected_prime, undetected_prime)
        
        print("Iteration {}: Coverage - Total: {:.2%}, Prime: {:.2%}".format(
            iteration, coverage_total, coverage_prime))
        
        log_iteration_data(LOG_FILE, iteration, seed, detected_total, detected_prime,
                          pot_detected_total, pot_detected_prime, undetected_total,
                          undetected_prime, coverage_total, coverage_prime, match_obj, matched_text)
        
        if coverage_total >= TARGET_COVERAGE or coverage_prime >= TARGET_COVERAGE:
            print("\nTarget coverage achieved!")
            print("Final - Total: {:.2%}, Prime: {:.2%}".format(coverage_total, coverage_prime))
            
            with open(LOG_FILE, 'a') as f:
                f.write("=" * 80 + "\n")
                f.write("TARGET COVERAGE ACHIEVED!\n")
                f.write("Final Iteration: {}\n".format(iteration))
                f.write("Final Seed: {}\n".format(seed))
                f.write("Final Total Coverage: {:.2%}\n".format(coverage_total))
                f.write("Final Prime Coverage: {:.2%}\n".format(coverage_prime))
                f.write("Completed: {}\n".format(datetime.now().strftime("%Y-%m-%d %H:%M:%S")))
                f.write("=" * 80 + "\n")
            break
        
        seed = generate_random_seed()
        print("Testing seed: {}".format(seed))
        update_lfsr_seed(seed)
        
        run_simulation()
        
        golden_signature = read_golden_signature()
        update_misr_signature(golden_signature)
        
        output = run_seed_finding()
        (detected_total, detected_prime, pot_detected_total, 
         pot_detected_prime, undetected_total, undetected_prime, match_obj, matched_text) = parse_fault_coverage(output)
        
        iteration += 1

if __name__ == "__main__":
    main()
