#!/bin/sh
# ==============================================================
# Cleanup of temporay files
#
# (c) 2021-2022 Harald Pretl
# Institute for Integrated Circuits
# Johannes Kepler University Linz
# ==============================================================

echo "Cleaning up files (hierarchically)."

rm -rf ./*.spc
rm -rf ./*.ext
rm -rf ./*.log
rm -rf ./*.out
rm -rf ./*.raw
rm -rf ./*.spice
rm -rf ./*.vcd
rm -rf ./ext_*.tcl
rm -rf ./drc_*.tcl
rm -rf ./pex_*.tcl
