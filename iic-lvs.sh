#!/bin/sh
# ==============================================================
# SKY130 LVS (Layout-vs-Schematic) Check
#
# (c) 2021 Harald Pretl
# Institute for Integrated Circuits
# Johannes Kepler University Linz
#
# Usage: iic-osic <cellname>
#
# The script expects the schematic <cellname>.sch in the current
# directory or in subfolder `sch`. The layout <cellname>.mag
# has to be located in the current directory or in the subfolder
# `lay`.
# ==============================================================

export ERR_LVS_MISMATCH=1
export ERR_FILE_NOT_FOUND=2
export ERR_NO_PARAM=3

if [ $# != 1 ]; then
	echo "Usage: $0 <cellname>"
	exit $ERR_NO_PARAM
fi

# Define useful variables
# -----------------------
export CELL_SCH="$1.sch"
export CELL_LAY="$1.mag"
export EXT_SCRIPT="ext_$1.tcl"
export NETLIST_SCH="$1.sch.sp"
export NETLIST_LAY="$1.ext.sp"
export LVS_REPORT="$1.comp.out"
export LVS_LOG="$1.comp.log"
export TOPCELL="$1"

# Check if files exist
# --------------------
if [ ! -f "$CELL_SCH" ]; then
	if [ ! -f "sch/$CELL_SCH" ]; then
		echo "Schematic $CELL_SCH not found!"
		exit $ERR_FILE_NOT_FOUND
	else
		export CELL_SCH="sch/$CELL_SCH"
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
echo "Running LVS of <$CELL_SCH> vs. <$CELL_LAY>."

# Extract SPICE netlist from schematic
# ------------------------------------
xschem -n -s -q --no_x "$CELL_SCH" -N "$NETLIST_SCH"

# Generate extract script for magic
# ---------------------------------
echo "load $CELL_LAY" 			> $EXT_SCRIPT
echo "extract all" 			>> $EXT_SCRIPT
echo "ext2spice lvs" 			>> $EXT_SCRIPT
echo "ext2spice subcircuits off" 	>> $EXT_SCRIPT
echo "ext2spice -o $NETLIST_LAY" 	>> $EXT_SCRIPT
echo "quit" 				>> $EXT_SCRIPT

# Extract SPICE netlist from layout with magic
# --------------------------------------------
magic -dnull "$EXT_SCRIPT" 

# Now run the lvs using netgen
# ----------------------------
netgen -batch lvs "$NETLIST_SCH" "$NETLIST_LAY" "$PDK_ROOT/sky130A/libs.tech/netgen/sky130A_setup.tcl" \
	"$LVS_REPORT" > "$LVS_LOG"

# Finished
# --------
echo "Result of LVS:"
echo "--------------"
tail -5 "$LVS_REPORT"
echo ""
echo "For details please check <$LVS_REPORT>."

