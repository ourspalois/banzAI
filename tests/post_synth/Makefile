#conda env name with a running jax install 
# cause I need jax (because I am a crackhead)
MAMBA_ENV = EQUINOX_ENV

HOME := ../../

#post synth netlist and design kit files
DESIGN_FOLDER := $(HOME)../tapeout_outputs
POST_SYNTH_NETLIST := $(DESIGN_FOLDER)/simulation_netlist.v
DK_FILES := $(DESIGN_FOLDER)/PR9A.v $(DESIGN_FOLDER)/CORE9ALPULL.v

#RRAM behavioral files 
RRAM_FILE_VHDL := $(HOME)rtl_chip/MC_64x64_FULL_upd.vhd
RRAM_FILE_SV := $(HOME)rtl_chip/MC_64x64_FULL_upd.sv

#list of sv files : testbench.sv and everything in .sv in rtl/
SV_FOLDER := $(HOME)controls $(HOME)includes
SV_INCLUDE := $(foreach dir, $(SV_FOLDER), +incdir+$(dir))
SV_FILES := $(wildcard $(foreach dir, $(SV_FOLDER), $(dir)/*.sv)) 

#build directory
BUILD_DIR = work

# ModelSim options
VSIM_FLAGS = -voptargs="+acc" -suppress 3009 #-sdftyp $(DESIGN_FOLDER)/delays.sdf +sdf_verbose

all: gen_testbench $(BUILD_DIR) compile simulate

gen_testbench:
	mamba run -n $(MAMBA_ENV) python3 ../chip_control/gen_test.py

$(BUILD_DIR):
	vlib $(BUILD_DIR)

compile: $(BUILD_DIR)
#	vcom $(RRAM_FILE_VHDL)
	vlog $(RRAM_FILE_SV)
	vlog $(DK_FILES) $(POST_SYNTH_NETLIST) 
	vlog $(SV_INCLUDE) $(HOME)axi/src/axi_pkg.sv
	vlog $(SV_INCLUDE) +incdir+$(HOME)axi/include $(HOME)axi/src/axi_intf.sv $(HOME)includes/adam_cfg_pkg.sv
	vlog $(SV_INCLUDE) $(SV_FILES) post_synth_tb.sv

simulate: compile
	vsim $(VSIM_FLAGS) -do wave.cmd testbench &

clean:
	rm -r $(BUILD_DIR)

.PHONY: all clean compile simulate gen_testbench