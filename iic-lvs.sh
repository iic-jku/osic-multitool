#!/bin/sh
# ========================================================================
# SKY130 LVS (Layout-vs-Schematic) Check
#
# SPDX-FileCopyrightText: 2021-2022 Harald Pretl, Johannes Kepler 
# University, Institute for Integrated Circuits
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
# Usage: iic-lvs <cellname>
#
# The script expects the schematic <cellname>.sch in the current
# directory or in subfolder `sch`. The layout <cellname>.mag
# has to be located in the current directory or in the subfolder
# `lay`.
#
# The script can also compare a powered Verilog netlist named
# <cellname.v> to a layout.
#
# The LVS script als can compare a netlist created from a 
# Powered-Verilog-to-xschem-schematic conversion using iic-v2sch.
# ========================================================================

# ERR_LVS_MISMATCH=1 reserved
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
NETLIST_SCH="$1.sch.spc"
NETLIST_LAY="$1.ext.spc"
LVS_REPORT="$1.lvs.out"
LVS_LOG="$1.lvs.log"
TOPCELL="$1"

# Check if files exist
# --------------------
if [ -f "$CELL_V" ]; then
	VERILOG_MODE=1
else
	VERILOG_MODE=0
	if [ -f "$CELL_SCH" ]; then
		export CELL_SCH="$CELL_SCH"
	elif [ -f "sch/$CELL_SCH" ]; then
		export CELL_SCH="sch/$CELL_SCH"
	elif [ -f "xschem/$CELL_SCH" ]; then
		export CELL_SCH="xschem/$CELL_SCH"
	else
		echo "Schematic $CELL_SCH not found!"
		exit $ERR_FILE_NOT_FOUND
	fi
fi

if [ -f "$CELL_LAY" ]; then
	export CELL_LAY="$CELL_LAY"
elif [ -f "lay/$CELL_LAY" ]; then
	export CELL_LAY="lay/$CELL_LAY"
elif [ -f "mag/$CELL_LAY" ]; then
	export CELL_LAY="mag/$CELL_LAY"
else
	echo "Layout $CELL_LAY not found!"
        exit $ERR_FILE_NOT_FOUND
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
	echo "... extracting netlist from schematic $CELL_SCH"
	xschem --rcfile "$PDK_ROOT/$PDK/libs.tech/xschem/xschemrc" -n -s -q --no_x --tcl 'set top_subckt 1' "$CELL_SCH" -N "$NETLIST_SCH" > /dev/null

	# Check if schematic netlist contains standard cells: if yes, include library with
	# SPICE netlists for the standard cells
	if [ ! $(grep -m 1 -e "$STD_CELL_LIBRARY" "$NETLIST_SCH" > /dev/null) ]; then
        	# Remove the .end
        	sed -i '/\.end\b/d' "$NETLIST_SCH"
        	# Append sky130 lib
        	cat "$PDK_ROOT/sky130A/libs.ref/$STD_CELL_LIBRARY/spice/$STD_CELL_LIBRARY.spice" >> "$NETLIST_SCH"
        	# Add .end
        	echo ".end" >> "$NETLIST_SCH"
	fi
fi

# Generate extract script for magic
# ---------------------------------
{
	echo "load $CELL_LAY"
	echo "select top cell"
	echo "extract all"
	echo "ext2spice lvs"
} > "$EXT_SCRIPT"
if [ $VERILOG_MODE -eq 1 ]; then
	# this is needed for the LVS in netgen, because the standard cells
	# are not instantiated in the (powered) .v file
	echo "ext2spice subcircuit descend off"		>> "$EXT_SCRIPT"
fi
{
	echo "ext2spice -o $NETLIST_LAY"
	echo "quit"
} >> "$EXT_SCRIPT"

# Extract SPICE netlist from layout with magic
# --------------------------------------------
echo "... extracting netlist from layout $CELL_LAY"
magic -dnull -noconsole "$EXT_SCRIPT" > /dev/null 

# Now run the lvs using netgen
# ----------------------------
echo "... run netgen"
if [ $VERILOG_MODE -eq 0 ]; then
	netgen -batch lvs "$NETLIST_LAY $TOPCELL" "$NETLIST_SCH $TOPCELL" \
		"$PDK_ROOT/sky130A/libs.tech/netgen/sky130A_setup.tcl" \
		"$LVS_REPORT" > "$LVS_LOG"
else
	# this is not needed if subcircuit descend off is applied during extract
	# UPDATE: still needed, the subcircuit descend off seems to not work
	export MAGIC_EXT_USE_GDS=1
	netgen -batch lvs "$NETLIST_LAY $TOPCELL" "$CELL_V $TOPCELL" \
                "$PDK_ROOT/sky130A/libs.tech/netgen/sky130A_setup.tcl" \
                "$LVS_REPORT" > "$LVS_LOG"
fi

# Finished
# --------
echo "Result of LVS:"
echo "--------------"
tail -3 "$LVS_REPORT"
echo ""
echo "For details please check <$LVS_REPORT>."

