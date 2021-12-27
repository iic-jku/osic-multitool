# User config
set ::env(DESIGN_NAME) counter

# Change if needed
set ::env(VERILOG_FILES) [glob $::env(DESIGN_DIR)/src/*.v]

set ::env(CLOCK_PORT) "clk_i"

set ::env(FP_SIZING) absolute
set ::env(DIE_AREA) "0 0 34.165 54.885"
set ::env(PL_TARGET_DENSITY) 0.75

set filename $::env(DESIGN_DIR)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}
