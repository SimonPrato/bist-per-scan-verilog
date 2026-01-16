# BIST Top-Level Synthesis Script

set LIB_DIR "/opt/ic_tools/pdk/ams_c35_410/liberty/c35_3.3V"
set_db init_lib_search_path $LIB_DIR
set_db init_hdl_search_path {.}

read_libs c35_CORELIB_TYP.lib

# Read all BIST components
read_hdl sources/top_module.v
read_hdl sources/misr.v
read_hdl sources/lfsr.v
read_hdl sources/controller.v
read_hdl sources/cut_scan_syn.v

elaborate top_module
check_design

# Clock definition: 10000ns = 100kHz
create_clock -name clk -period 10000 [get_ports clock]

# Synthesis
set_db syn_global_effort high
syn_generic
syn_map

# Flatten design to single module
ungroup -all

# Generate reports
report qor
write_hdl -mapped > sources/top_module_syn.v 
write_sdc > reports/top_module.sdc
report gates > reports/top_module_gates.txt
report timing > reports/top_module_timing.txt
report power > reports/top_module_power.txt

exit
