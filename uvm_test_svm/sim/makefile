TEST?=base_test
SEED=2
#SEED=random

ifeq ($(OS),Windows_NT)
	RM_CMD = powershell if (Test-Path $(TEST)) { Remove-Item -Recurse -Force -ErrorAction SilentlyContinue $(TEST) }
else
	RM_CMD = rm -rf $(TEST)
endif

all: clean run_sim

run_sim: clean
	mkdir $(TEST)
	qrun -uvmhome "uvm-1.2" +UVM_TESTNAME=$(TEST) +UVM_NO_RELNOTES -verbose -lint=default -parallel -coverage +cover=sbteft -vlog.sv -vlog.timescale 1ns/1ps -vopt.access=rw+/. -vsim.sv_seed $(SEED) -f dut.f -f top.f -top top -outdir $(TEST) -l $(TEST)/qrun.log -designfile $(TEST)/$(TEST).bin -qwavedb=+memory=all+assertion+cell+signal+class+wavefile=$(TEST)/$(TEST).db

clean:
	$(RM_CMD)

.PHONY: all clean
