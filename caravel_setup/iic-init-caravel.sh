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
# by Matt Venn in https://github.com/mattvenn/project0_test.
#
export STD_CELL_LIBRARY=sky130_fd_sc_hd
export MAGIC_VERSION=8.3.209
export CARAVEL_ENV_ROOT="$HOME/caravel_env"
export PDK_ROOT="$CARAVEL_ENV_ROOT/pdk"
export OPENLANE_ROOT="$CARAVEL_ENV_ROOT/openlane"
export CARAVEL_ROOT="$CARAVEL_ENV_ROOT/caravel_user_project/caravel"
# export CARAVEL_LITE=0
export PRECHECK_ROOT="$CARAVEL_ENV_ROOT/precheck"
export USER_PROJECT_COMMIT=mpw-3
export SKYWATER_COMMIT=c094b6e83a4f9298e47f696ec5a7fd53535ec5eb
export OPEN_PDKS_COMMIT=14db32aa8ba330e88632ff3ad2ff52f4f4dae1ad
export CARAVEL_COMMIT=5712871d27c08900d18edc72a7f534cc8be1b2dd
export OPENLANE_TAG=mpw-3a
export OPENLANE_IMAGE_NAME=efabless/openlane:mpw-3a
