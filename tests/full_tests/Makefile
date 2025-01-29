#QUESTA
HOME := ../../
#list of sv files : testbench.sv and everything in .sv in rtl/
SV_FOLDER := $(HOME)rtl_chip $(HOME)controls $(HOME)includes
SV_INCLUDE := $(foreach dir, $(SV_FOLDER), +incdir+$(dir)/)
SV_FILES := $(wildcard $(foreach dir, $(SV_FOLDER), $(dir)/*.sv)) 

SVH_FILES := $(wildcard $(foreach dir, $(SV_FOLDER), $(dir)/*.svh))

#build directory
BUILD_DIR = work

# ModelSim options -voptargs="+acc=rnb"
VSIM_FLAGS = -voptargs="+acc -debug"

all: $(BUILD_DIR) compile simulate

$(BUILD_DIR):
	vlib $(BUILD_DIR)

compile: $(BUILD_DIR)
	vlog $(SV_INCLUDE) $(HOME)axi/src/axi_pkg.sv
	vlog $(SV_INCLUDE) +incdir+$(HOME)axi/include $(HOME)axi/src/axi_intf.sv $(HOME)includes/adam_cfg_pkg.sv
	vlog $(SV_INCLUDE) +incdir+$(SVH_FILES) $(SV_FILES) banzai_tb.sv

simulate: compile
	vsim $(VSIM_FLAGS) -do wave.cmd testbench & 

clean:
	rm test.txt transcript vsim.wlf
	rm -r $(BUILD_DIR)

.PHONY: all clean compile simulate gen_testbench