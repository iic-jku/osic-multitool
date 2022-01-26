#!/bin/sh
#
# (c) 2022 Harald Pretl
# Institute for Integrated Circuits
# Johannes Kepler University Linz
#
# Correct tool and environement versions can be found at
# https://caravel-harness.readthedocs.io/en/latest/tool-versioning.html
# 
# The versions from the docs seem outdated, we are using versions provided 
# by Marwan Abbas in Slack.
#
export STD_CELL_LIBRARY=sky130_fd_sc_hd
#
export CARAVEL_ENV_ROOT="$HOME/caravel_env"
export PDK_ROOT="$CARAVEL_ENV_ROOT/pdk"
export OPENLANE_ROOT="$CARAVEL_ENV_ROOT/openlane"
export CARAVEL_ROOT="$CARAVEL_ENV_ROOT/caravel_user_project/caravel"
export PRECHECK_ROOT="$CARAVEL_ENV_ROOT/precheck"
#
# export CARAVEL_LITE=0
#
export CARAVEL_USER_PROJECT_COMMIT=mpw-3
export CARAVEL_COMMIT=mpw-3
# use CARAVEL_COMMIT=mpw-4b when setting CARAVEL_LITE=0
export OPEN_PDKS_COMMIT=6c05bc48dc88784f9d98b89d6791cdfd91526676
export OPENLANE_TAG=2021.09.19_20.25.16
