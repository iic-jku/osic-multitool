#!/bin/sh
# ========================================================================
# Verilog Linting helper script
#
# SPDX-FileCopyrightText: 2022 Harald Pretl, Johannes Kepler 
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
# Usage: iic-vlint [-i|-v|-b] [-g1995|-g2001|-g2005|-g2005-sv|-g2009|-g2012]
#        <file.v>
#
# The script runs linting on <file.v>
# ========================================================================

ERR_FILE_NOT_FOUND=2
ERR_NO_PARAM=3
ERR_PROG_NOT_AVAILABLE=4

# print out usage
# ---------------

if [ $# = 0 ]; then
	echo
	echo "Verilog linting using Icarus Verilog and Verilator"
	echo
	echo "Usage: $0 [-i|-v|-b] [-g1995|-g2001|-g2005|-g2005-sv|-g2009|-g2012] <file.v>"
	echo "       -i Run <iverilog>"
	echo "       -v Runs <verilator>"
	echo "       -b Run <iverilog> followed by <verilator> (default)"
	echo "       -g VERSION Sets the Verilog standard for <iverilog> (default 2005)"
	echo
	exit $ERR_NO_PARAM
fi

# set the default behavior
# ------------------------

RUN_ICARUS=1
RUN_VERILATOR=1
VERILOG_VERSION=2005
DEBUG=0

# check flags
# -----------

while getopts "ivbg:d" flag; do
	case $flag in
		i)
			#echo "-i set"
			RUN_ICARUS=1
			RUN_VERILATOR=0
			;;
		v)
			#echo "-v set"
			RUN_VERILATOR=1
			RUN_ICARUS=0
			;;
		b)
			#echo "-b set"
			RUN_ICARUS=1
			RUN_VERILATOR=1
			;;
		g)
			#echo "-g set"
			VERILOG_VERSION=${OPTARG}
			;;
		d)
			#echo "DEBUG set"
			DEBUG=1
			;;
		*)
			;;
    esac
done
shift $((OPTIND-1))

FILE_NAME=$1

if [ $DEBUG = 1 ]; then
	echo "RUN_ICARUS=$RUN_ICARUS"
	echo "RUN_VERILATOR=$RUN_VERILATOR"
	echo "VERILOG_VERSION=$VERILOG_VERSION"
	echo "FILE_NAME=$FILE_NAME"
fi

# Check if the input file exists
# ------------------------------
if [ ! -f "$FILE_NAME" ]; then
	echo "ERROR: File $FILE_NAME not found!"
    exit $ERR_FILE_NOT_FOUND
fi

# Run the linting
# ---------------

if [ $RUN_ICARUS = 1 ]; then
	if [ -x "$(command -v iverilog)" ]; then
		echo "RUN iverilog linting on $FILE_NAME..."
		iverilog -g"$VERILOG_VERSION" -tnull "$FILE_NAME"
	else
		echo "ERROR: iverilog not available!"
		exit $ERR_PROG_NOT_AVAILABLE
	fi
fi

if [ $RUN_VERILATOR = 1 ]; then
	if [ -x "$(command -v verilator)" ]; then
		echo "RUN verilator linting on $FILE_NAME..."
		verilator --lint-only -Wall "$FILE_NAME"
	else
		echo "ERROR: verilator not available!"
		exit $ERR_PROG_NOT_AVAILABLE
	fi
fi

echo "... done, bye!"
