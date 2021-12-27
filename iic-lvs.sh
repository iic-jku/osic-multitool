#!/bin/sh
# ==================================================================
# SKY130 LVS (Layout-vs-Schematic) Check
#
# (c) 2021 Harald Pretl
# Institute for Integrated Circuits, Johannes Kepler University Linz
#
# Usage: iic-lvs <cellname>
#
# The script expects the schematic <cellname>.sch in the current
# directory or in subfolder `sch`. The layout <cellname>.mag
# has to be located in the current directory or in the subfolder
# `lay`.
#
# The script can also compare a powered Verilog netlist named
# <cellname.v> to a layout.
# ==================================================================

ERR_LVS_MISMATCH=1
ERR_FILE_NOT_FOUND=2
ERR_NO_PARAM=3

if [ $# != 1 ]; then
	echo "Usage: $0 <cellname>"
	exit $ERR_NO_PARAM
fi

# Define useful variables
# -----------------------
CELL_SCH="$1.sch"
CELL_V="$1.v"
CELL_LAY="$1.mag"
EXT_SCRIPT="ext_$1.tcl"
NETLIST_SCH="$1.sch.sp"
NETLIST_LAY="$1.ext.sp"
LVS_REPORT="$1.lvs.out"
LVS_LOG="$1.lvs.log"
TOPCELL="$1"

# Check if files exist
# --------------------
if [ -f "$CELL_V" ]; then
	VERILOG_MODE=1
else
	VERILOG_MODE=0
	if [ ! -f "$CELL_SCH" ]; then
		if [ ! -f "sch/$CELL_SCH" ]; then
			echo "Schematic $CELL_SCH not found!"
			exit $ERR_FILE_NOT_FOUND
		else
			export CELL_SCH="sch/$CELL_SCH"
		fi
	fi
fi

if [ ! -f "$CELL_LAY" ]; then
        if [ ! -f "lay/$CELL_LAY" ]; then
                echo "Layout $CELL_LAY not found!"
                exit $ERR_FILE_NOT_FOUND
        else
                export CELL_LAY="lay/$CELL_LAY"
        fi
fi

# Initial checks passed, start working
# ------------------------------------
if [ $VERILOG_MODE -eq 0 ]; then
	echo "Running LVS of <$CELL_LAY> vs <$CELL_SCH>."
else
	echo "Running LVS of <$CELL_LAY> vs <$CELL_V>."
fi

# Extract SPICE netlist from schematic
# ------------------------------------
if [ $VERILOG_MODE -eq 0 ]; then
	xschem -n -s -q --no_x --tcl 'set top_subckt 1' "$CELL_SCH" -N "$NETLIST_SCH"
fi

# Generate extract script for magic
# ---------------------------------
echo "load $CELL_LAY" 			> $EXT_SCRIPT
echo "extract all" 			>> $EXT_SCRIPT
echo "ext2spice lvs" 			>> $EXT_SCRIPT
echo "ext2spice -o $NETLIST_LAY" 	>> $EXT_SCRIPT
echo "quit" 				>> $EXT_SCRIPT

# Extract SPICE netlist from layout with magic
# --------------------------------------------
magic -dnull -noconsole "$EXT_SCRIPT" > /dev/null 

# Now run the lvs using netgen
# ----------------------------
if [ $VERILOG_MODE -eq 0 ]; then
	netgen -batch lvs "$NETLIST_LAY $TOPCELL" "$NETLIST_SCH $TOPCELL" \
		$PDK_ROOT/sky130A/libs.tech/netgen/sky130A_setup.tcl \
		"$LVS_REPORT" > "$LVS_LOG"
else
	export MAGIC_EXT_USE_GDS=1
	netgen -batch lvs "$NETLIST_LAY $TOPCELL" "$CELL_V $TOPCELL" \
                $PDK_ROOT/sky130A/libs.tech/netgen/sky130A_setup.tcl \
                "$LVS_REPORT" > "$LVS_LOG"
fi

# Finished
# --------
echo "Result of LVS:"
echo "--------------"
tail -3 "$LVS_REPORT"
echo ""
echo "For details please check <$LVS_REPORT>."

