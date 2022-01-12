#!/bin/sh
# ==================================================================
# SKY130 DRC (Design Rule Check)
#
# (c) 2021-2022 Harald Pretl
# Institute for Integrated Circuits, Johannes Kepler University Linz
#
# Usage: iic-drc <cellname>
#
# The script expects the layout <cellname.mag> in the current folder.
# ==================================================================

# ERR_DRC=1 reserved
ERR_FILE_NOT_FOUND=2
ERR_NO_PARAM=3

if [ $# != 1 ]; then
	echo "Usage: $0 <cellname>"
	exit $ERR_NO_PARAM
fi

# Define useful variables
# -----------------------
CELL_LAY="$1.mag"
EXT_SCRIPT="drc_$1.tcl"

# Check if file exists
# --------------------
if [ ! -f "$CELL_LAY" ]; then
	echo "Layout $CELL_LAY not found!"
        exit $ERR_FILE_NOT_FOUND
fi

# Generate DRC script for magic
# -----------------------------
{
	echo "load $CELL_LAY"
	echo 'select top cell'
	echo 'drc euclidean on'
	echo 'drc style drc(full)'
	echo 'drc check'
	echo 'set drc_res [drc listall why]'
	echo 'puts stdout "--------------"'
	echo 'drc count'
	echo 'puts stdout "Error details:"'
	echo 'puts stdout "--------------"'
	echo 'foreach {errtype coordlist} $drc_res {'
	echo '  puts stdout $errtype }'
	echo 'quit'
} > "$EXT_SCRIPT"

# Run DRC with magic
# ------------------
magic -dnull -noconsole "$EXT_SCRIPT"

