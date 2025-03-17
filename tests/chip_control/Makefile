#conda env name with a running jax install 
# cause I need jax (because I am a crackhead)
CONDA_ENV = .EQUINOX_ENV

HOME := ../../

#list of sv files : testbench.sv and everything in .sv in rtl/
SV_FOLDER := $(HOME)rtl_chip $(HOME)controls $(HOME)includes
SV_INCLUDE := $(foreach dir, $(SV_FOLDER), +incdir+$(dir))
SV_FILES := $(wildcard $(foreach dir, $(SV_FOLDER), $(dir)/*.sv)) 

#build directory
LIB = rtl

# ModelSim options
VSIM_FLAGS = -voptargs="+acc=rn +notimingchecks"

all: gen_testbench $(LIB) compile optimize simulate

gen_testbench:
	conda run -n $(CONDA_ENV) python3 gen_test.py

$(LIB):
	vlib $(LIB)

compile: $(LIB)
	vcom -work $(LIB) $(HOME)/rtl_chip/MC_64x64_FULL_upd.vhd
	vlog -work $(LIB) -sv $(SV_INCLUDE) $(HOME)axi/src/axi_pkg.sv
	vlog -work $(LIB) -sv $(SV_INCLUDE) +incdir+$(HOME)axi/include $(HOME)axi/src/axi_intf.sv $(HOME)includes/adam_cfg_pkg.sv
	vlog -work $(LIB) -sv $(SV_INCLUDE) $(SV_FILES) chip_control_tb.sv

optimize:
	vopt -work $(LIB) +acc=rn -o testbench_opt testbench

simulate: compile
	vsim -c -lib $(LIB) -suppress 3009 $(VSIM_FLAGS) -do wave.cmd testbench_opt

clean:
	rm -r $(LIB)
	rm test.txt transcript vsim.wlf

.PHONY: all clean compile simulate gen_testbench