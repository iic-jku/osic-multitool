#!/bin/sh
# ==============================================================
# Initialization of IIC Open-Source EDA Environment for Caravel
#
# Caravel is the SoC harness for efabless.com MPW shuttles.
#
# (c) 2022 Harald Pretl
# Institute for Integrated Circuits
# Johannes Kepler University Linz
#
# ==============================================================

make openlane
make pdk
make precheck
