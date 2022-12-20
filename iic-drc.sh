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
# Usage: iic-drc [-d] [-m|-k|-b|-c] <cellname>
#
# The script expects the layout <cellname> in the current folder using
# either Magic-VLSI or Klayout.
# ========================================================================

ERR_DRC=1
ERR_FILE_NOT_FOUND=2
ERR_NO_PARAM=3
ERR_CMD_NOT_FOUND=4
ERR_UNKNOWN_FILE=5
ERR_PDK_NOT_SUPPORTED=6

if [ $# = 0 ]; then
	echo
	echo "IIC@JKU DRC script for Magic-VLSI and KLayout"
	echo
	echo "Usage: $0 [-d] [-m|-k|-b|-c] <cellname>"
	echo "       -m Run Magic DRC (default)"
	echo "       -k Run KLayout DRC"
	echo "       -b Run Magic and KLayout DRC"
	echo "       -c Clean output files"
	echo "       -d Enable debug information"
	echo
	exit $ERR_NO_PARAM
fi

# set the default behavior
# ------------------------

RUN_MAGIC=1
RUN_KLAYOUT=0
RUN_CLEAN=0
DEBUG=0
DRC_CLEAN=1

# check if the PDK is already supported by this script
# ----------------------------------------------------

if echo "$PDK" | grep -q -i "sky130"; then
	[ $DEBUG = 1 ] && echo "[INFO] sky130 PDK selected"
elif echo "$PDK" | grep -q -i "gf180mcuC"; then
	[ $DEBUG = 1 ] && echo "[INFO] gf180mcuC PDK selected"
else
	echo "[ERROR] The PDK $PDK is not yet supported!"
	exit $ERR_PDK_NOT_SUPPORTED
fi

# check flags
# -----------

while getopts "mkbcd" flag; do
	case $flag in
		m)
			[ $DEBUG = 1 ] && echo "[INFO] flag -m is set"
			RUN_MAGIC=1
			RUN_KLAYOUT=0
			;;
		k)
			[ $DEBUG = 1 ] && echo "[INFO] flag -k is set"
			RUN_MAGIC=0
			RUN_KLAYOUT=1
			;;
		b)	
			[ $DEBUG = 1 ] && echo "[INFO] flag -b is set"
			RUN_MAGIC=1
			RUN_KLAYOUT=1
			;;
		c)
			[ $DEBUG = 1 ] && echo "[INFO] flag -c is set"
			RUN_CLEAN=1
			;;
		d)
			echo "[INFO] DEBUG is enabled"
			DEBUG=1
			;;
		*)
			;;
    esac
done
shift $((OPTIND-1))

if [ $RUN_CLEAN = 1 ]; then
	rm -- -f *.magic.*.rpt
	rm -- -f *.klayout.*.xml
fi 

# define useful variables
# -----------------------

EXT_SCRIPT="drc_$1.tcl"

# check if the input file exists
# ------------------------------

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
	echo "[ERROR] Layout $CELL_LAY not found!"
    exit $ERR_FILE_NOT_FOUND
fi

[ $DEBUG = 1 ] && echo "[INFO] CELL_LAY=$CELL_LAY"

# check if commands exist in the path
# -----------------------------------

if [ $RUN_MAGIC = 1 ]; then
	if [ ! -x "$(command -v magic)" ]; then
    	echo "[ERROR] magic could not be found!"
    	exit $ERR_CMD_NOT_FOUND
	fi
fi

if [ $RUN_KLAYOUT = 1 ]; then
	if [ ! -x "$(command -v klayout)" ]; then
    	echo "[ERROR] KLayout could not be found!"
    	exit $ERR_CMD_NOT_FOUND
	fi
fi

# launch Magic DRC
# ----------------

if [ $RUN_MAGIC = 1 ]; then
	echo "Launching Magic DRC..."

	# remove old result files
	rm -f "$CELL_LAY.magic.drc.rpt"

	# generate DRC script for Magic
	if echo "$CELL_LAY" | grep -q -i ".mag"; then
		[ $DEBUG = 1 ] && echo "[INFO] magic runs DRC on .mag file"
		echo "load $CELL_LAY" > "$EXT_SCRIPT"
	elif echo "$CELL_LAY" | grep -q -i ".gds"; then
		[ $DEBUG = 1 ] && echo "[INFO] magic runs DRC on .gds file"
		echo "gds read $CELL_LAY" > "$EXT_SCRIPT"
	else
		echo "[ERROR] Unknown file format for magic DRC!"
		exit $ERR_UNKNOWN_FILE
	fi
	{
		echo "set drc_rpt_path $CELL_LAY.magic.drc.rpt"
		# shellcheck disable=SC2016
		echo 'set fout [open $drc_rpt_path w]'
		echo 'set oscale [cif scale out]'
		echo "set cell_name $CELL_LAY"

		echo 'select top cell'
		echo 'drc euclidean on'
		echo 'drc style drc(full)'
		echo 'drc check'
		echo 'set drcresult [drc listall why]'

		echo 'set count 0'
		# shellcheck disable=SC2016
		echo 'puts $fout "$cell_name"'
		# shellcheck disable=SC2016
		echo 'puts $fout "----------------------------------------"'
		# shellcheck disable=SC2016
		echo 'foreach {errtype coordlist} $drcresult {'
		# shellcheck disable=SC2016
		echo '  puts $fout $errtype'
		# shellcheck disable=SC2016
		echo '  puts $fout "----------------------------------------"'
		# shellcheck disable=SC2016
		echo '  foreach coord $coordlist {'
		# shellcheck disable=SC2016
		echo '    set bllx [expr {$oscale * [lindex $coord 0]}]'
		# shellcheck disable=SC2016
		echo '    set blly [expr {$oscale * [lindex $coord 1]}]'
		# shellcheck disable=SC2016
		echo '    set burx [expr {$oscale * [lindex $coord 2]}]'
		# shellcheck disable=SC2016
		echo '    set bury [expr {$oscale * [lindex $coord 3]}]'
		# shellcheck disable=SC2016
		echo '    set coords [format " %.3fum %.3fum %.3fum %.3fum" $bllx $blly $burx $bury]'
		# shellcheck disable=SC2016
		echo '    puts $fout "$coords"'
		# shellcheck disable=SC2016
		echo '    set count [expr {$count + 1} ]'
		echo '  }'
		# shellcheck disable=SC2016
		echo '  puts $fout "----------------------------------------"'
		echo '}'
		# shellcheck disable=SC2016
		echo 'puts $fout "\[INFO\] COUNT: $count"'
		# shellcheck disable=SC2016
		echo 'puts $fout "\[INFO\] Should be divided by 3 or 4"'
		# shellcheck disable=SC2016
		echo 'puts $fout ""'
		# shellcheck disable=SC2016
		echo 'close $fout'
		# shellcheck disable=SC2016
		#echo 'puts stdout "$count DRC errors found! (should be divided by 3 or 4)"'
		echo 'exit 0'
	} >> "$EXT_SCRIPT"

	# run it 
	magic -dnull -noconsole \
		-rcfile "$PDKPATH/libs.tech/magic/$PDK.magicrc" \
		"$EXT_SCRIPT" \
		> /dev/null 2> /dev/null &
fi

# launch KLayout DRC
# ------------------

if [ $RUN_KLAYOUT = 1 ]; then
	echo "Launching KLayout DRC..."

	# remove old result files
	rm -f "$CELL_LAY".klayout.*.xml

	if echo "$PDK" | grep -q -i "sky130"; then
		klayout -b \
			-rd input="$CELL_LAY" \
			-rd feol=true \
			-rd beol=false \
			-rd offgrid=true \
			-rd report="$CELL_LAY.klayout.drc.feol.xml" \
			-r "$PDKPATH/libs.tech/klayout/drc/${PDK}_mr.drc" \
			> /dev/null 2> /dev/null &

		klayout -b \
			-rd input="$CELL_LAY" \
			-rd feol=false \
			-rd beol=true \
			-rd offgrid=false \
			-rd report="$CELL_LAY.klayout.drc.beol.xml" \
			-r "$PDKPATH/libs.tech/klayout/drc/${PDK}_mr.drc" \
			> /dev/null 2> /dev/null &

		klayout -b \
			-rd input="$CELL_LAY" \
			-rd report="$CELL_LAY.klayout.drc.density.xml" \
			-r "$PDKPATH/libs.tech/klayout/drc/met_min_ca_density.lydrc" \
			> /dev/null 2> /dev/null &

		klayout -b \
			-rd input="$CELL_LAY" \
			-rd threads="$(nproc --ignore 5)" \
			-rd flat_mode=true \
			-rd report="$CELL_LAY.klayout.drc.pincheck.xml" \
			-r "$PDKPATH/libs.tech/klayout/drc/pin_label_purposes_overlapping_drawing.rb.drc" \
			> /dev/null 2> /dev/null &

		klayout -b \
			-rd input="$CELL_LAY" \
			-rd report="$CELL_LAY.klayout.drc.zeroarea.xml" \
			-r "$PDKPATH/libs.tech/klayout/drc/zeroarea.rb.drc" \
			> /dev/null 2> /dev/null &
	fi

	if echo "$PDK" | grep -q -i "gf180mcuC"; then
		echo "[ERROR] KLayout DRC for $PDK not yet supported!"
		exit $ERR_PDK_NOT_SUPPORTED
	fi	
fi

# wait for all runs to finish
# ---------------------------

wait
echo "---"

# evaluate results of runs
# ------------------------

if [ $RUN_MAGIC = 1 ]; then
	[ $DEBUG = 0 ] && rm -f "$EXT_SCRIPT"

	if grep -q "COUNT: 0" "$CELL_LAY.magic.drc.rpt"; then
		echo "[INFO] Magic DRC is clean!"
	else
		echo "[INFO] Magic DRC errors found! Check <$CELL_LAY.magic.drc.rpt>!"
		DRC_CLEAN=0	
	fi
fi

if [ $RUN_KLAYOUT = 1 ]; then
	DRC_ERRORS=$(grep -c "edge-pair" "$CELL_LAY.klayout.drc.feol.xml")
	if [ "$DRC_ERRORS" != 0 ]; then
		echo "[INFO] KLayout $DRC_ERRORS DRC errors found! Check <$CELL_LAY.klayout.drc.feol.xml>!"
		DRC_CLEAN=0
	else
		echo "[INFO] KLayout FEOL DRC is clean!"
	fi

	DRC_ERRORS=$(grep -c "edge-pair" "$CELL_LAY.klayout.drc.beol.xml")
	if [ "$DRC_ERRORS" != 0 ]; then
		echo "[INFO] KLayout $DRC_ERRORS DRC errors found! Check <$CELL_LAY.klayout.drc.beol.xml>!"
		DRC_CLEAN=0
	else
		echo "[INFO] KLayout BEOL DRC is clean!"
	fi

	DENSITY_ERRORS=$(grep -c "edge-pair" "$CELL_LAY.klayout.drc.density.xml")
	if [ "$DENSITY_ERRORS" != 0 ]; then
		echo "[INFO] Klayout $DENSITY_ERRORS density errors found! Check <$CELL_LAY.klayout.drc.density.xml>!"
		DRC_CLEAN=0
	else
		echo "[INFO] KLayout metal density DRC is clean!"
	fi

	PINCHECK_ERRORS=$(grep -c "edge-pair" "$CELL_LAY.klayout.drc.pincheck.xml")
	if [ "$PINCHECK_ERRORS" != 0 ]; then
		echo "[INFO] KLayout $PINCHECK_ERRORS pin errors found! Check <$CELL_LAY.klayout.drc.pincheck.xml>!"
		DRC_CLEAN=0
	else
		echo "[INFO] KLayout pin check DRC is clean!"
	fi

	ZEROAREA_ERRORS=$(grep -c "edge-pair" "$CELL_LAY.klayout.drc.zeroarea.xml")
	if [ "$ZEROAREA_ERRORS" != 0 ]; then
		echo "[INFO] KLayout $ZEROAREA_ERRORS zero-area errors found! Check <$CELL_LAY.klayout.drc.zeroarea.xml>!"
		DRC_CLEAN=0
	else
		echo "[INFO] KLayout zero-area DRC is clean!"
	fi
fi

echo "---"

if [ "$DRC_CLEAN" = 1 ]; then
		echo "CONGRATULATIONS! No DRC errors in <$CELL_LAY> found!"
		echo "---"
else
		echo "DRC ERRORS FOUND! Please check the output files!"
		echo "---"
		exit $ERR_DRC
fi
