# DFT Synthesis Script for CUT with Scan Chain Insertion

set LIB_DIR "/opt/ic_tools/pdk/ams_c35_410/liberty/c35_3.3V"
set_db init_lib_search_path $LIB_DIR
set_db init_hdl_search_path {.}

read_libs c35_CORELIB_TYP.lib
read_hdl sources/cut.v

elaborate cut
check_design

# Clock definition: 10000ns = 100kHz
create_clock -name clk -period 10000 [get_ports clock]

# DFT configuration
set_db dft_scan_style muxed_scan

define_dft shift_enable -active high -create_port scan_en
define_dft test_clock -name scan_clk clock

check_dft_rules > dft_rules.report

# Synthesis
set_db syn_global_effort high
syn_generic
syn_map

report dft_registers

# Scan chain creation
define_dft scan_chain -name chain1 -create_ports -sdi scan_in -sdo scan_out
connect_scan_chains -auto_create_chains -preview
connect_scan_chains -auto_create_chains

# Generate reports
report qor
write_hdl -mapped > sources/cut_scan_syn.v 
write_sdc > reports/cut_scan.sdc
write_scandef > reports/cut_scan_chain.txt
write_atpg -stil > reports/cut_scan.stil
report gates > reports/cut_scan_gates.txt
report timing > reports/cut_scan_timing.txt
report power > reports/cut_power.txt

exit
