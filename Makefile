# ---------------------------------------------------------------------------
# openofdm - convenience wrappers around the tcl scripts in tools/.
#
#   make check     out-of-context synthesis of dot11 (fast setup smoke test)
#   make sim       simulate dot11_tb against the default reference vector
#   make sim VECTOR=simulated/ag_6M_len14_pre100_post200_openwifi.txt
#   make project   generate a Vivado GUI project under build/
#   make tb        openCMUL's complex_multiplier bench against the cmpy netlist
#   make regression            dot11 against every reference vector (11a+11n+sim)
#   make regression GROUP=11a  one group (11a | 11n | sim | all) or a vector path
#   make clean     remove build/
#
# Requires Vivado on $PATH (source <install>/settings64.sh) and a checkout of
# openViterbi next to this repository, or $OPENVITERBI pointing at one.
# ---------------------------------------------------------------------------
VIVADO ?= vivado
VFLAGS  = -mode batch -nojournal -nolog
VECTOR ?=

.PHONY: all check sim project clean

all: check

check:
	$(VIVADO) $(VFLAGS) -source tools/synth_check.tcl

sim:
	$(VIVADO) $(VFLAGS) -source tools/run_sim.tcl $(if $(VECTOR),-tclargs $(VECTOR),)

project:
	$(VIVADO) $(VFLAGS) -source tools/create_project.tcl

# --- unit testbench of the complex multiplier (lives in openCMUL) ----------
OPENCMUL ?= $(abspath ../openCMUL)

.PHONY: tb
tb:
	$(MAKE) -C $(OPENCMUL) tb CMPY_NETLIST=$(abspath ip_repo/complex_multiplier/complex_multiplier_sim_netlist.v)

# --- receiver regression (tools/run_regression.tcl) -------------------------
# One Vivado session, one launch_simulation per vector; verdict per vector in
# build/regression/results.txt, per-vector dumps under build/regression/dumps/.
GROUP ?= all

.PHONY: regression
regression:
	$(VIVADO) $(VFLAGS) -source tools/run_regression.tcl -tclargs $(GROUP)

clean:
	rm -rf build .Xil
