
# Remove the '#' to enable the graphical interface
#GUI = -gui -access +r

CIRCUIT = top_module

all:       circuit FS_concurrent
circuit:   SIM_rtl_circuit SYN_dft_circuit SIM_syn_scan_circuit

SIM_rtl_circuit:
	# Step 1: simulate the original circuit (behavioral simulation)
    # MULTIPLE STEP MODE
    #	xmvlog $(CIRCUIT).v tb_$(CIRCUIT).v
    #	xmelab -access +r tb_$(CIRCUIT):module
    #	xmsim -gui tb_$(CIRCUIT):module
    # SINGLE STEP MODE
	xrun $(GUI) sources/top_module.v testbenches/top_module_tb.v

SYN_dft_circuit:
	# Step 2: synthesize the circuit with scan chain
	genus -f scripts/synthesis_dft.tcl
	sed -i '1s/^/`timescale 1ns\/1ps /' top_module_scan_syn.v

SIM_syn_scan_circuit:
	# Step 3: simulate the original circuit with scan chain (gate-level simulation)
	xrun $(GUI) -define SCAN -l verilog.log\
		-v /opt/ic_tools/pdk/ams_c35_410/verilog/udp.v\
		-v /opt/ic_tools/pdk/ams_c35_410/verilog/c35b4/c35_CORELIB.v\
		top_module_scan_syn.v\
		testbenches/top_module_tb.v

HAL:
	# Step 4: check for good Verilog coding style 
	hal -gui sources/top_module.v

FS_concurrent:
	# Step 8: concurrent fault simulation
	# Elaborate
	xrun -define SCAN -clean -elaborate\
 		-define functional\
		-fault_file scripts/fault.file\
		-fault_top top_module\
		-fault_logfile fault_xrun_elab.log\
		-v /opt/ic_tools/pdk/ams_c35_410/verilog/udp.v\
		-v /opt/ic_tools/pdk/ams_c35_410/verilog/c35b4/c35_CORELIB.v\
		top_module_scan_syn.v\
		testbenches/top_module_tb.v
	# Generate the fault list
	xfsg -fault_type SA0+SA1\
		-fault_list fault_list\
		-fault_work fault_db
	# Remove UNCONNECTED signals (e.g. outputs of FFs)
	sed '/UNCONNECTED/d' -i fault_list.tcl
	# Perform fault simulation
	xrun -R -fault_concurrent\
		-nospecify -notimingchecks -delay_mode zero -run -exit\
		-define functional\
		-input scripts/strobes.tcl\
		-input fault_list.tcl\
		-fault_logfile fault_xrun_sim.log
	# Generate the report
	xfr -verbose\
		-fault_work fault_db\
		-fault_report fault_report.txt\
		-log xfr.log

clean:
	rm -rf fault_db fv xcelium.d top_module* genus.* dft_rules.report fault_* hal* .hal* .rs* verilog.* xf* xrun*
