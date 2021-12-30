#!/bin/sh
# ==================================================================
# SKY130 DRC (Design Rule Check)
#
# (c) 2021 Harald Pretl
# Institute for Integrated Circuits, Johannes Kepler University Linz
#
# Usage: iic-drc <cellname>
#
# The script expects the layout <cellname.mag> in the current folder.
# ==================================================================

ERR_DRC=1
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
echo "load $CELL_LAY" 					> $EXT_SCRIPT
echo 'select top cell'					>> $EXT_SCRIPT
echo 'drc euclidean on'					>> $EXT_SCRIPT
echo 'drc style drc(full)'				>> $EXT_SCRIPT
echo 'drc check'					>> $EXT_SCRIPT
echo 'set drc_cnt [drc list count]'			>> $EXT_SCRIPT
echo 'puts stdout "No of DRC errors: $drc_cnt"'		>> $EXT_SCRIPT
echo 'set drc_res [drc listall why]'			>> $EXT_SCRIPT
echo 'puts stdout "Error details:"'			>> $EXT_SCRIPT
echo 'puts stdout "-------------:"'			>> $EXT_SCRIPT
echo 'foreach {errtype coordlist} $drc_res {'		>> $EXT_SCRIPT
echo '  puts stdout $errtype }'				>> $EXT_SCRIPT
echo 'quit' 						>> $EXT_SCRIPT

# Run DRC with magic
# ------------------
magic -dnull -noconsole "$EXT_SCRIPT"

