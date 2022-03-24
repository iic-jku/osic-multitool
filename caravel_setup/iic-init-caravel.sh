#!/bin/sh
#
# (c) 2022 Harald Pretl
# Institute for Integrated Circuits
# Johannes Kepler University Linz
#
# Correct tool and environement installation instructions can be found at
# https://github.com/efabless/caravel_user_project/blob/main/docs/source/roundtrip.rst
#
export CARAVEL_ENV_ROOT="$HOME/caravel_mpw5"
#
export PDK_ROOT="$CARAVEL_ENV_ROOT/pdks"
export OPENLANE_ROOT="$CARAVEL_ENV_ROOT/openlane"
export PRECHECK_ROOT="$CARAVEL_ENV_ROOT/precheck"
export OPEN_PDKS_COMMIT=c5730b574461889c82858b08d12ba42423d9c2cb
export CARAVEL_ROOT="$CARAVEL_ENV_ROOT/iic-audiodac-v1/caravel"
#
export STD_CELL_LIBRARY=sky130_fd_sc_hd
