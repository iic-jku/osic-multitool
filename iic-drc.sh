#!/bin/sh
# ========================================================================
# SKY130 DRC (Design Rule Check)
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
# Usage: iic-drc [-m|-k] <cellname>
#
# The script expects the layout <cellname> in the current folder.
# ========================================================================

# ERR_DRC=1 reserved
ERR_FILE_NOT_FOUND=2
ERR_NO_PARAM=3
ERR_EXE_NOT_FOUND=4

if [ $# = 0 ]; then
	echo
	echo "IIC DRC script for Magic and KLayout"
	echo
	echo "Usage: $0 [-m|-k] <cellname>"
	echo "       -m Run <magic> DRC (default)"
	echo "       -k Run <klayout> DRC"
	echo
	exit $ERR_NO_PARAM
fi

# set the default behavior
# ------------------------

RUN_MAGIC=1
RUN_KLAYOUT=0
DEBUG=0

# check flags
# -----------

while getopts "mkd" flag; do
	case $flag in
		m)
			#echo "-m set"
			RUN_MAGIC=1
			RUN_KLAYOUT=0
			;;
		k)
			#echo "-k set"
			RUN_MAGIC=0
			RUN_KLAYOUT=1
			;;
		d)
			echo "INFO: DEBUG is enabled"
			DEBUG=1
			;;
		*)
			;;
    esac
done
shift $((OPTIND-1))

# Define useful variables
# -----------------------
EXT_SCRIPT="drc_$1.tcl"

# Check if the file exists
# ------------------------
if [ -f "$1" ]; then
	CELL_LAY="$1"
elif [ -f "$1.mag" ]; then
	CELL_LAY="$1.mag"
elif [ -f "$1.mag.gz" ]; then
	CELL_LAY="$1.mag.gz"
elif [ -f "$1.gds" ]; then
	CELL_LAY="$1.gds"
elif [ -f "$1.gds.gz" ]; then
	CELL_LAY="$1.gds.gz"
else
	echo "ERROR: Layout $CELL_LAY not found!"
    exit $ERR_FILE_NOT_FOUND
fi

if [ $DEBUG = 1 ]; then
	echo "INFO: CELL_LAY=$CELL_LAY"
fi

if [ $RUN_MAGIC = 1 ]; then
	if [ ! -x "$(command -v magic)" ]; then
    	echo "ERROR: magic could not be found!"
    	exit $ERR_EXE_NOT_FOUND
	fi
fi

if [ $RUN_KLAYOUT = 1 ]; then
	if [ ! -x "$(command -v klayout)" ]; then
    	echo "ERROR: KLayout could not be found!"
    	exit $ERR_EXE_NOT_FOUND
	fi
fi


if [ $RUN_MAGIC = 1 ]; then
	if [ $DEBUG = 1 ]; then
		echo "INFO: magic DRC is selected"
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
		# shellcheck disable=SC2016
		echo 'foreach {errtype coordlist} $drc_res {'
		# shellcheck disable=SC2016	
		echo '  puts stdout $errtype }'
		echo 'quit'
	} > "$EXT_SCRIPT"

	# Run DRC with Magic
	# ------------------
	magic -dnull -noconsole "$EXT_SCRIPT"
fi

if [ $RUN_KLAYOUT = 1 ]; then
	if [ $DEBUG = 1 ]; then
		echo "INFO: Klayout DRC is selected"
	fi

	# Remove old result files
	# -----------------------
	rm -rf "$CELL_LAY".klayout.*.xml 

	# Run DRC with KLayout
	# --------------------
	klayout -b \
		-rd input="$CELL_LAY" \
		-rd feol=true \
		-rd beol=true \
		-rd offgrid=true \
		-rd report="$CELL_LAY.klayout.drc.xml" \
		-r "$PDKPATH/libs.tech/klayout/drc/${PDK}_mr.drc"

	klayout -b \
		-rd input="$CELL_LAY" \
		-rd report="$CELL_LAY.klayout.density.xml" \
		-r "$PDKPATH/libs.tech/klayout/drc/met_min_ca_density.lydrc"

	klayout -b \
		-rd input="$CELL_LAY" \
		-rd threads="$(nproc)" \
		-rd flat_mode=true \
		-rd report="$CELL_LAY.klayout.pincheck.xml" \
		-r "$PDKPATH/libs.tech/klayout/drc/pin_label_purposes_overlapping_drawing.rb.drc"

	klayout -b \
		-rd input="$CELL_LAY" \
		-rd report="$CELL_LAY.klayout.zeroarea.xml" \
		-r "$PDKPATH/libs.tech/klayout/drc/zeroarea.rb.drc"

	echo "---"

	DRC_CLEAN=1

	DRC_ERRORS=$(grep -c "edge-pair" "$CELL_LAY.klayout.drc.xml")
	if [ "$DRC_ERRORS" != 0 ]; then
		echo "$DRC_ERRORS DRC errors found! Check <$CELL_LAY.klayout.drc.xml>!"
		DRC_CLEAN=0
	else
		echo "DRC is clean!"
	fi

	DENSITY_ERRORS=$(grep -c "edge-pair" "$CELL_LAY.klayout.density.xml")
	if [ "$DENSITY_ERRORS" != 0 ]; then
		echo "$DENSITY_ERRORS density errors found! Check <$CELL_LAY.klayout.density.xml>!"
		DRC_CLEAN=0
	else
		echo "Metal density is clean!"
	fi

	PINCHECK_ERRORS=$(grep -c "edge-pair" "$CELL_LAY.klayout.pincheck.xml")
	if [ "$PINCHECK_ERRORS" != 0 ]; then
		echo "$PINCHECK_ERRORS pin errors found! Check <$CELL_LAY.klayout.pincheck.xml>!"
		DRC_CLEAN=0
	else
		echo "Pin check is clean!"
	fi

	ZEROAREA_ERRORS=$(grep -c "edge-pair" "$CELL_LAY.klayout.zeroarea.xml")
	if [ "$ZEROAREA_ERRORS" != 0 ]; then
		echo "$ZEROAREA_ERRORS zero-area errors found! Check <$CELL_LAY.klayout.zeroarea.xml>!"
		DRC_CLEAN=0
	else
		echo "Zero-area check is clean!"
	fi

	if [ "$DRC_CLEAN" = 1 ]; then
		echo "---"
		echo "CONGRATULATIONS! No DRC errors in <$CELL_LAY> found!"
	fi

	echo "---"
fi
