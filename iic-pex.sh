#!/bin/sh
# ==================================================================
# SKY130 PEX (Parasitic Extraction)
#
# (c) 2021 Harald Pretl
# Institute for Integrated Circuits, Johannes Kepler University Linz
#
# Usage: iic-pex <cellname>
#
# The script expects the layout <cellname>.mag in the current
# directory. 
# ==================================================================

ERR_TBD=1
ERR_FILE_NOT_FOUND=2
ERR_NO_PARAM=3

if [ $# != 1 ]; then
	echo "Usage: $0 <cellname>"
	exit $ERR_NO_PARAM
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
echo "load $CELL_LAY" 					> $EXT_SCRIPT
echo "select top cell" 					>> $EXT_SCRIPT
echo "extract all" 					>> $EXT_SCRIPT
echo "ext2spice cthresh 0.01"				>> $EXT_SCRIPT
echo "ext2spice rthresh 1"				>> $EXT_SCRIPT
echo "ext2spice subcircuit top on"			>> $EXT_SCRIPT
echo "ext2spice format ngspice" 			>> $EXT_SCRIPT
echo "ext2spice -o $NETLIST_PEX" 			>> $EXT_SCRIPT
echo "quit" 						>> $EXT_SCRIPT

# Extract SPICE netlist from layout with magic
# --------------------------------------------
magic -dnull -noconsole "$EXT_SCRIPT" > /dev/null 

# Finished
# --------
echo "PEX done, extracted SPICE netlist is <$NETLIST_PEX>."
