#conda env name with a running jax install 
# cause I need jax (because I am a crackhead)
CONDA_ENV = .EQUINOX

#QUESTA

#list of sv files : testbench.sv and everything in .sv in rtl/
SV_FOLDER := rtl_chip controls includes
SV_INCLUDE := $(foreach dir, $(SV_FOLDER), +incdir+$(dir))
SV_FILES := $(wildcard $(foreach dir, $(SV_FOLDER), $(dir)/*.sv)) 

#build directory
BUILD_DIR = work

#Verilator options 
VERILATOR_FLAGS = --binary --trace-fst --assert -j 14 --Irtl --trace-params --trace-max-array 1024 $(SV_INCLUDE)

# ModelSim options
VSIM_FLAGS = -voptargs="+acc" 

all: gen_testbench $(BUILD_DIR) compile simulate

gen_testbench:
	conda run -n $(CONDA_ENV) python3 gen_test.py

$(BUILD_DIR):
	vlib $(BUILD_DIR)

compile: $(BUILD_DIR)
	vlog $(SV_INCLUDE) axi/src/axi_pkg.sv
	vlog $(SV_INCLUDE) +incdir+axi/include axi/src/axi_intf.sv
	vlog $(SV_INCLUDE) $(SV_FILES) testbench.sv

simulate: compile
	vsim $(VSIM_FLAGS) -do wave.cmd testbench 

clean:
	rm test.txt transcript vsim.wlf
	rm -r $(BUILD_DIR)

.PHONY: all clean compile simulate gen_testbench