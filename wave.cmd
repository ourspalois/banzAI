add wave -r /testbench/axi_port/*
add wave /testbench/dut/*
add wave sim:/testbench/dut/registers
add wave sim:/testbench/dut/chip/DATA_next

run -all