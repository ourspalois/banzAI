#conda env name with a running jax install 
# cause I need jax (because I am a crackhead)
CONDA_ENV = EQUINOX_ENV

HOME := ../../

#list of sv files : testbench.sv and everything in .sv in rtl/
SV_FOLDER := $(HOME)rtl_chip $(HOME)controls $(HOME)includes
SV_INCLUDE := $(foreach dir, $(SV_FOLDER), +incdir+$(dir))
SV_FILES := $(wildcard $(foreach dir, $(SV_FOLDER), $(dir)/*.sv)) 

#build directory
BUILD_DIR = work

# ModelSim options
VSIM_FLAGS = -voptargs="+acc" 

all: gen_testbench $(BUILD_DIR) compile simulate

gen_testbench:
	conda run -n $(CONDA_ENV) python3 gen_test.py

$(BUILD_DIR):
	vlib $(BUILD_DIR)

compile: $(BUILD_DIR)
	vcom $(HOME)/rtl_chip/MC_64x64_FULL_upd.vhd
	vlog $(SV_INCLUDE) $(HOME)axi/src/axi_pkg.sv
	vlog $(SV_INCLUDE) +incdir+$(HOME)axi/include $(HOME)axi/src/axi_intf.sv $(HOME)includes/adam_cfg_pkg.sv
	vlog $(SV_INCLUDE) $(SV_FILES) chip_control_tb.sv

simulate: compile
	vsim -c -suppress 3009 $(VSIM_FLAGS) -do wave.cmd testbench

clean:
	rm test.txt transcript vsim.wlf
	rm -r $(BUILD_DIR)

.PHONY: all clean compile simulate gen_testbench