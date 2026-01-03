# Remove the '#' to enable the graphical interface
#GUI = -gui -access +r

CIRCUIT = cut

all:       circuit top_level FS_concurrent
circuit:   SIM_rtl_circuit SYN_dft_circuit SIM_syn_scan_circuit
top_level: SIM_rtl_top_level_normal SIM_rtl_top_level_bist SIM_rtl_top_level_controller SYN_final \
	   SIM_syn_top_level_normal SIM_syn_top_level_bist SIM_syn_top_level_controller

SIM_rtl_circuit:
        # Step 1: simulate the original circuit (behavioral simulation)
	xrun $(GUI) \
		sources/$(CIRCUIT).v \
		testbenches/tb_cut.v

SYN_dft_circuit:
        # Step 2: synthesize the circuit with scan chain
	genus -f scripts/synthesis_dft.tcl
	sed -i '1s/^/`timescale 1ns\/1ps /' cut_scan_syn.v

SIM_syn_scan_circuit:	
	# Step 3 (OPTIONAL): simulate the original circuit with scan chain (gate-level simulation)
	xrun $(GUI) -define SCAN -l reports/verilog.log \
		-v /opt/ic_tools/pdk/ams_c35_410/verilog/udp.v \
                -v /opt/ic_tools/pdk/ams_c35_410/verilog/c35b4/c35_CORELIB.v \
                cut_scan_syn.v \
                testbenches/tb_cut.v

HAL:
        # Step 4: check for good Verilog coding style
	hal -gui cut_scan_syn.v sources/controller.v sources/lfsr.v sources/misr.v sources/top_module.v

SIM_rtl_top_level_normal:
        # Step 5a (OPTIONAL): simulate the whole design in "normal mode"
        # Top Level (behavioral) + circuit with scan chain (gate-level)
	xrun $(GUI) -define SCAN -l reports/verilog.log \
	-v /opt/ic_tools/pdk/ams_c35_410/verilog/udp.v \
	-v /opt/ic_tools/pdk/ams_c35_410/verilog/c35b4/c35_CORELIB.v \
		cut_scan_syn.v \
		sources/top_module.v sources/lfsr.v sources/misr.v sources/controller.v \
		testbenches/tb_top_level_normal.v

SIM_rtl_top_level_bist:
	# Step 5b (OPTIONAL): simulate the whole design in "bist mode"
	# Top Level (behavioral) + circuit with scan chain (gate-level)
	xrun $(GUI) -define SCAN -l reports/verilog.log \
	-v /opt/ic_tools/pdk/ams_c35_410/verilog/udp.v \
	-v /opt/ic_tools/pdk/ams_c35_410/verilog/c35b4/c35_CORELIB.v \
		cut_scan_syn.v \
		sources/top_module.v sources/lfsr.v sources/misr.v sources/controller.v \
                testbenches/tb_top_level_bist.v

SIM_rtl_top_level_controller:
	# Step 5c (OPTIONAL): simulate the whole design in "controller mode"
	# Top Level (behavioral) + circuit with scan chain (gate-level)
	xrun $(GUI) -define SCAN -l reports/verilog.log \
		-v /opt/ic_tools/pdk/ams_c35_410/verilog/udp.v \
		-v /opt/ic_tools/pdk/ams_c35_410/verilog/c35b4/c35_CORELIB.v \
		cut_scan_syn.v \
		sources/top_module.v sources/lfsr.v sources/misr.v sources/controller.v \
		testbenches/tb_top_level_controller.v

SYN_final:
	# Step 6: synthesize the Top Level
	# the circuit created in step 2 must be also included in this step
	genus -f scripts/synthesis_bist.tcl
	sed -i '1s/^/`timescale 1ns\/1ps /' top_module_syn.v

SIM_syn_top_level_normal:
	# Step 7a: simulate the whole design in "normal mode" (gate-level simulation)
	xrun $(GUI) -define SCAN -l reports/verilog.log \
		-v /opt/ic_tools/pdk/ams_c35_410/verilog/udp.v \
		-v /opt/ic_tools/pdk/ams_c35_410/verilog/c35b4/c35_CORELIB.v \
		top_module_syn.v \
		testbenches/tb_top_level_normal.v

SIM_syn_top_level_bist:
	# Step 7b: simulate the whole design in "bist mode" (gate-level simulation)
	xrun $(GUI) -define SCAN -l reports/verilog.log \
		-v /opt/ic_tools/pdk/ams_c35_410/verilog/udp.v \
		-v /opt/ic_tools/pdk/ams_c35_410/verilog/c35b4/c35_CORELIB.v \
		top_module_syn.v \
		testbenches/tb_top_level_bist.v

SIM_syn_top_level_controller:
	# Step 7c: simulate the whole design in "controller mode" (gate-level simulation)
	xrun $(GUI) -define SCAN -l reports/verilog.log \
		-v /opt/ic_tools/pdk/ams_c35_410/verilog/udp.v \
		-v /opt/ic_tools/pdk/ams_c35_410/verilog/c35b4/c35_CORELIB.v \
		top_module_syn.v \
		testbenches/tb_top_level_controller.v

FS_concurrent:
	# Step 8: concurrent fault simulation
	# Elaborate
	xrun -define SCAN -clean -elaborate \
		-define functional \
		-fault_file scripts/fault.file \
		-fault_top top_module \
		-fault_logfile reports/fault_xrun_elab.log \
		-v /opt/ic_tools/pdk/ams_c35_410/verilog/udp.v \
		-v /opt/ic_tools/pdk/ams_c35_410/verilog/c35b4/c35_CORELIB.v \
		top_module_syn.v \
		testbenches/tb_top_level_bist.v
	# Generate the fault list
	xfsg -fault_type SA0+SA1 \
		-fault_list fault_list \
		-fault_work fault_db
	# Remove UNCONNECTED signals (e.g. outputs of FFs)
	sed '/UNCONNECTED/d' -i fault_list.tcl
	# Perform fault simulation
	xrun -R -fault_concurrent \
		-nospecify -notimingchecks -delay_mode zero -run -exit \
		-define functional \
		-input scripts/strobes.tcl \
		-input fault_list.tcl \
		-fault_logfile reports/fault_xrun_sim.log
	# Generate the report
	xfr -verbose \
		-fault_work fault_db \
		-fault_report reports/fault_report.txt \
		-log reports/xfr.log

clean:
	# Cleaning directory
	rm -rf fault_db fv xcelium.d genus.* dft_rules.report fault_* hal* .hal* .rs* verilog.* xf* xrun* reports/*
