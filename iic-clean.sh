#!/bin/sh
# ==============================================================
# Cleanup of temporay files
#
# (c) 2021 Harald Pretl
# Institute for Integrated Circuits
# Johannes Kepler University Linz
# ==============================================================

echo "Cleaning up files."

rm -f *.spc
rm -f *.ext
rm -f *.log
rm -f *.out
rm -f *.raw
rm -f *.spice
rm -f *.vcd
rm -f ext*.tcl
rm -f drc*.tcl
rm -f pex*.tcl
