#!/bin/bash
# ========================================================================
# PEX (Parasitic Extraction) using Magic VLSI
#
# SPDX-FileCopyrightText: 2021-2023 Harald Pretl
# Johannes Kepler University, Institute for Integrated Circuits
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# SPDX-License-Identifier: Apache-2.0
#
# Usage: iic-pex.sh [-d] [-m mode] [-s mode] <cellname>
#
# The script expects the layout <cellname> in the current directory.
#
# Supported PEX modes:
#   1 = C-decoupled
#   2 = C-coupled (default)
#   3 = full-RC
# ========================================================================

ERR_GENERAL=1
ERR_FILE_NOT_FOUND=2
ERR_NO_PARAM=3
ERR_WRONG_MODE=4
ERR_CMD_NOT_FOUND=5
ERR_PDK_NOT_SUPPORTED=6

if [ $# = 0 ]; then
	echo
	echo "PEX script using Magic-VLSI (IIC@JKU)"
	echo
	echo "Usage: $0 [-d] [-m mode] [-s mode] <cellname>"
	echo
	echo "       -m Select PEX mode (1 = C-decoupled, 2 = C-coupled [default], 3 = full-RX)"
	echo "       -s Subcircuit definition in PEX netlist (1 = include subcircuit definition [default], 0 = no subcircuit)"
	echo "       -d Enable debug information"
	echo
	exit $ERR_NO_PARAM
fi

# Set the default behavior
# ------------------------

DEBUG=0
GDS_MODE=0
EXT_MODE=2
SUBCIRCUIT=1

# Check flags
# -----------

while getopts "m:s:d" flag; do
	case $flag in
		m)
			[ $DEBUG = 1 ] && echo "[INFO] Flag -m is set to $OPTARG."
			EXT_MODE=${OPTARG}
			;;
		s)
			[ $DEBUG = 1 ] && echo "[INFO] Flag -s is set to $OPTARG."
			SUBCIRCUIT=${OPTARG}
			;;
		d)
			echo "[INFO] DEBUG is enabled."
			DEBUG=1
			;;
		*)
			;;
    esac
done
shift $((OPTIND-1))

# Check that mode is an integer and in a valid range
# --------------------------------------------------

if [ -n "$EXT_MODE" ] && [ "$EXT_MODE" -eq "$EXT_MODE" ] 2>/dev/null; then
	if [ "$EXT_MODE" -lt 1 ] || [ "$EXT_MODE" -gt 3 ]; then
        echo "[ERROR] Unknown extraction mode!"
        exit $ERR_WRONG_MODE
	fi
else
        echo "[ERROR] Extraction mode must be an integer!"
        exit $ERR_WRONG_MODE
fi

if [ -n "$SUBCIRCUIT" ] && [ "$SUBCIRCUIT" -eq "$SUBCIRCUIT" ] 2>/dev/null; then
	if [ "$SUBCIRCUIT" -lt 0 ] || [ "$SUBCIRCUIT" -gt 1 ]; then
        echo "[ERROR] Illegal subcircuit mode!"
        exit $ERR_WRONG_MODE
	fi
else
        echo "[ERROR] Subcircuit mode must be an integer!"
        exit $ERR_WRONG_MODE
fi

# Check if the PDK is already supported by this script
# ----------------------------------------------------

if echo "$PDK" | grep -q -i "sky130"; then
	[ $DEBUG = 1 ] && echo "[INFO] sky130 PDK selected"
elif echo "$PDK" | grep -q -i "gf180mcuC"; then
	[ $DEBUG = 1 ] && echo "[INFO] gf180mcuC PDK selected"
else
	echo "[ERROR] The PDK $PDK is not yet supported!"
	exit $ERR_PDK_NOT_SUPPORTED
fi

# check if the input file exists
# ------------------------------

if [ -z "$1" ]; then
	echo "[ERROR] No cellname provided!"
	exit $ERR_FILE_NOT_FOUND
elif [ -f "$1" ]; then
	CELL_LAY="$1"
elif [ -f "$1.mag" ]; then
	CELL_LAY="$1.mag"
elif [ -f "$1.mag.gz" ]; then
	CELL_LAY="$1.mag.gz"
elif [ -f "$1.gds" ]; then
	CELL_LAY="$1.gds"
	GDS_MODE=1
else
	echo "[ERROR] Layout $CELL_LAY not found!"
    exit $ERR_FILE_NOT_FOUND
fi

[ $DEBUG = 1 ] && echo "[INFO] CELL_LAY=$CELL_LAY"

# Define useful variables
# -----------------------

FILENAME=$(echo "$CELL_LAY" | cut -f 1 -d '.')
EXT_SCRIPT="pex_$FILENAME.tcl"
NETLIST_PEX="$FILENAME.pex.spice"

# check if GDS file
# -----------------

if [[ "$CELL_LAY" == *"gds.gz" ]]; then
	cp "$CELL_LAY" tmp.gds.gz
	[ -f tmp.gds ] && rm -f tmp.gds
	gunzip tmp.gds.gz > /dev/null
	CELL_LAY="tmp.gds"
fi
if [[ "$CELL_LAY" == *"gds" ]]; then
	GDS_MODE=1
	[ $DEBUG = 1 ] && echo "[INFO] GDS mode is selected."	
fi

# Generate extract script for magic
# ---------------------------------

{
	[ "$GDS_MODE" = 1 ] && echo "gds read $CELL_LAY"
	[ "$GDS_MODE" = 0 ] && echo "load $CELL_LAY"
	echo "select top cell"
	echo "flatten ${FILENAME}_flat"
	echo "load ${FILENAME}_flat"
	echo "select top cell"
} > "$EXT_SCRIPT"

if [ "$EXT_MODE" = 1 ] || [ "$EXT_MODE" = 2 ]; then
	if [ "$EXT_MODE" = 1 ]; then
		EXT_MODE_TEXT="C-decoupled"
	elif [ "$EXT_MODE" = 2 ]; then
		EXT_MODE_TEXT="C-coupled"
	else
		echo "[ERROR] Illegal branch!"
		exit $ERR_GENERAL
	fi
	
	{
		[ "$EXT_MODE" = 1 ] && echo "extract no coupling"
		echo "extract all"
		echo "ext2spice cthresh 0.01"
		[ "$SUBCIRCUIT" = 0 ] && echo "ext2spice subcircuit top off"
		echo "ext2spice format ngspice"
		echo "ext2spice -o _$NETLIST_PEX"
		echo "quit"
	} >> "$EXT_SCRIPT"
fi

if [ "$EXT_MODE" = 3 ]; then
	# Extraction mode RC
	EXT_MODE_TEXT="full-RC"
	{
		echo "extract do resistance"
		echo "extract all"
		echo "ext2sim labels on"
		echo "ext2sim"
		echo "extresist tolerance 10"
		echo "extresist all"
		echo "ext2spice lvs"
		echo "ext2spice cthresh 0.01"	
		echo "ext2spice rthresh 100"	
		echo "ext2spice extresist on"
		echo "ext2spice resistor tee on"
		[ "$SUBCIRCUIT" = 0 ] && echo "ext2spice subcircuit top off"
		echo "ext2spice format ngspice"
		echo "ext2spice -o _$NETLIST_PEX"
        echo "quit"
	} >> "$EXT_SCRIPT"
fi

# check if commands exist in the path
# -----------------------------------

if [ ! -x "$(command -v magic)" ]; then
   	echo "[ERROR] magic could not be found!"
   	exit $ERR_CMD_NOT_FOUND
fi

# Extract SPICE netlist from layout with magic
# --------------------------------------------
echo "[INFO] Running PEX using magic..."

if [ $DEBUG = 0 ]; then
	magic -dnull -noconsole \
		-rcfile "$PDKPATH/libs.tech/magic/$PDK.magicrc" \
		"$EXT_SCRIPT" "$NO_MESSAGE" \
		> /dev/null 2> /dev/null
else
	magic -dnull -noconsole \
		-rcfile "$PDKPATH/libs.tech/magic/$PDK.magicrc" \
		"$EXT_SCRIPT" "$NO_MESSAGE"
fi

if [ ! -f "_$NETLIST_PEX" ]; then
	echo "[ERROR] No PEX file produced, something went wrong!"
	exit $ERR_GENERAL
else
	DATE=$(date)
	HEADER="* PEX produced on $DATE using $0 with m=$EXT_MODE and s=$SUBCIRCUIT"
	{
		echo "$HEADER"
		cat "_$NETLIST_PEX"	
	} > "$NETLIST_PEX"
	rm -f "_$NETLIST_PEX"

	sed -i 's/_flat//g' "$NETLIST_PEX"
fi 

# Cleanup
# -------
rm -f ./*.ext
[ -f tmp.gds ] && rm -f tmp.gds
if [ "$EXT_MODE" = 3 ]; then
	rm -f ./*.nodes
	rm -f ./*.ext
	rm -f ./*.sim
	rm -f ./*.res.ext
fi
[ $DEBUG = 0 ] && rm -f "$EXT_SCRIPT"

# Finished
# --------
echo "[DONE] PEX ($EXT_MODE_TEXT) done, extracted SPICE netlist is <$NETLIST_PEX>."
