
# Remove the '#' to enable the graphical interface
#GUI = -gui -access +r

CIRCUIT = cut

all:       circuit_rtl circuit_bist FS_concurrent 
circuit_rtl:   SIM_rtl_circuit SYN_dft_circuit SIM_syn_scan_circuit
circuit_bist:  SIM_bist_circuit SYN_bist_circuit SIM_syn_bist_circuit

SIM_rtl_circuit:
	# Simulating CUT
	xrun $(GUI) sources/cut.v testbenches/tb_cut.v

SYN_dft_circuit:
	# Synthesizing CUT with scan chain
	genus -f scripts/synthesis_dft.tcl
	sed -i '1s/^/`timescale 1ns\/1ps /' cut_scan_syn.v

SIM_syn_scan_circuit:
	# Simulating CUT with scan chain
	xrun $(GUI) -define SCAN -l verilog.log\
		-v /opt/ic_tools/pdk/ams_c35_410/verilog/udp.v\
		-v /opt/ic_tools/pdk/ams_c35_410/verilog/c35b4/c35_CORELIB.v\
		cut_scan_syn.v\
		testbenches/tb_cut.v

SIM_bist_circuit:
	# Simulating CUT with BIST controller
	xrun $(GUI) sources/lfsr.v cut_scan_syn.v sources/controller.v sources/misr.v  sources/top_module.v testbenches/top_module_tb.v -v /opt/ic_tools/pdk/ams_c35_410/verilog/udp.v -v /opt/ic_tools/pdk/ams_c35_410/verilog/c35b4/c35_CORELIB.v

SYN_bist_circuit:
	# Synthesizing CUT with scan chain
	genus -f scripts/synthesis_bist.tcl
	sed -i '1s/^/`timescale 1ns\/1ps /' top_module_syn.v

SIM_syn_bist_circuit:
	# Simulating synthetized top level
	xrun $(GUI) -define SCAN -l verilog.log\
		-v /opt/ic_tools/pdk/ams_c35_410/verilog/udp.v\
		-v /opt/ic_tools/pdk/ams_c35_410/verilog/c35b4/c35_CORELIB.v\
		top_module_syn.v\
		testbenches/top_module_tb.v

HAL:
	# Checking Coding Style of CUT
	hal -gui sources/top_module.v

FS_concurrent:
	# Conducting fault simulation
	xrun -define SCAN -clean -elaborate\
 		-define functional\
		-fault_file scripts/fault.file\
		-fault_top top_module\
		-fault_logfile fault_xrun_elab.log\
		-v /opt/ic_tools/pdk/ams_c35_410/verilog/udp.v\
		-v /opt/ic_tools/pdk/ams_c35_410/verilog/c35b4/c35_CORELIB.v\
		top_module_syn.v sources/lfsr.v cut_scan_syn.v sources/controller.v sources/misr.v  testbenches/top_module_tb.v \
		testbenches/top_module_tb.v
	xfsg -fault_type SA0+SA1\
		-fault_list fault_list\
		-fault_work fault_db
	sed '/UNCONNECTED/d' -i fault_list.tcl
	xrun -R -fault_concurrent\
		-nospecify -notimingchecks -delay_mode zero -run -exit\
		-define functional\
		-input scripts/strobes.tcl\
		-input fault_list.tcl\
		-fault_logfile fault_xrun_sim.log
	xfr -verbose\
		-fault_work fault_db\
		-fault_report fault_report.txt\
		-log xfr.log

clean:
	# Cleaning directory
	rm -rf fault_db fv xcelium.d cut* genus.* dft_rules.report fault_* hal* .hal* .rs* verilog.* xf* xrun*
