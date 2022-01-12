#!/bin/sh
# ==================================================================
# SKY130 PEX (Parasitic Extraction)
#
# (c) 2021-2022 Harald Pretl
# Institute for Integrated Circuits, Johannes Kepler University Linz
#
# Usage: iic-pex <cellname> [mode]
#
# The script expects the layout <cellname>.mag in the current
# directory.
#
# Supported PEX modes:
#   1 = C-decoupled
#   2 = C-coupled (default)
#   3 = full-RC
# ==================================================================

# ERR_TBD=1 reserved
ERR_FILE_NOT_FOUND=2
ERR_NO_PARAM=3
ERR_WRONG_MODE=4

# Check for number of correct arguments
if [ $# -eq 1 ]; then
	# default extraction mode
	EXT_MODE=2;
else
	if [ $# -eq 2 ]; then
		EXT_MODE=$2
	else
		echo "Usage: $0 <cellname> [mode]"
		echo ""
		echo "       PEX mode=1 C-decoupled"
		echo "       PEX mode=2 C-coupled (default)"
		echo "       PEX mode=3 full-RC"
        	exit $ERR_NO_PARAM
	fi
fi

# Check that mode is an integer and in valid range
if [ -n "$EXT_MODE" ] && [ "$EXT_MODE" -eq "$EXT_MODE" ] 2>/dev/null; then
	if [ "$EXT_MODE" -lt 1 ] || [ "$EXT_MODE" -gt 3 ]; then
        	echo "Error: Unknown extraction mode!"
        	exit $ERR_WRONG_MODE
	fi
else
        echo "Error: Extraction mode must be an integer!"
        exit $ERR_WRONG_MODE
fi


# Define useful variables
# -----------------------
CELL_LAY="$1.mag"
EXT_SCRIPT="pex_$1.tcl"
NETLIST_PEX="$1.pex.spice"
TOPCELL="$1"


# Check if file exists
# --------------------
if [ ! -f "$CELL_LAY" ]; then
	echo "Layout $CELL_LAY not found!"
	exit $ERR_FILE_NOT_FOUND
fi


# Generate extract script for magic
# ---------------------------------
if [ "$EXT_MODE" -eq 1 ]; then
	# Extraction moe C-decoupled
	EXT_MODE_TEXT="C-decoupled"
	{
		echo "load $CELL_LAY"
		echo "select top cell"
		echo "extract no coupling"
		echo "extract all"
		echo "ext2spice cthresh 0.01"
		echo "ext2spice rthresh 1"
		echo "ext2spice subcircuit top off"
		echo "ext2spice format ngspice"
		echo "ext2spice -o $NETLIST_PEX"
		echo "quit"
	} > "$EXT_SCRIPT"
fi


if [ "$EXT_MODE" -eq 2 ]; then
	# Extraction mode C-coupled
	EXT_MODE_TEXT="C-coupled"
	{
		echo "load $CELL_LAY"
        	echo "select top cell"
        	echo "extract all"
        	echo "ext2spice cthresh 0.01"
        	echo "ext2spice rthresh 1"
        	echo "ext2spice subcircuit top off"
        	echo "ext2spice format ngspice"
        	echo "ext2spice -o $NETLIST_PEX"
        	echo "quit"
	} > "$EXT_SCRIPT"
fi


if [ "$EXT_MODE" -eq 3 ]; then
	# Extraction mode RC
	EXT_MODE_TEXT="full-RC"
	{
        	echo "load $CELL_LAY"
        	echo "select top cell"
        	echo "extract do resistance"
        	echo "extract all"
        	echo "ext2sim labels on"
        	echo "ext2sim"
        	echo "extresist all"
        	echo "ext2spice extresist on"
        	echo "ext2spice cthresh 0.01"
        	echo "ext2spice rthresh 100"
        	echo "ext2spice subcircuit top off"
        	echo "ext2spice format ngspice"
        	echo "ext2spice -o $NETLIST_PEX"
        	echo "quit"
	} > "$EXT_SCRIPT"
fi


# Extract SPICE netlist from layout with magic
# --------------------------------------------
magic -dnull -noconsole "$EXT_SCRIPT" > /dev/null 


# Cleanup
# -------
rm -f "$TOPCELL.ext"
if [ "$EXT_MODE" -eq 3 ]; then
	rm -f "$TOPCELL.nodes"
	rm -f "$TOPCELL.sim"
	rm -f "$TOPCELL.res.ext"
fi


# Finished
# --------
echo "PEX ($EXT_MODE_TEXT) done, extracted SPICE netlist is <$NETLIST_PEX>."
