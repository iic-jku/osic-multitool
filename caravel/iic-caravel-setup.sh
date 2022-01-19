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
# This script installs OpenLane, SKY130 PDK, Caravel and the
# Caravel User Project template with the correct versions.
# ==============================================================

# Get the correct versions and install paths
source iic-init-caravel.sh

# Install dependencies via package manager
sudo apt install -y tcsh csh tcl-dev tk-dev libcairo2-dev

# not sure why this is needed: set -eu

# Get caravel user project with the right version
if [ ! -d "$HOME/caravel" ]; then
	mkdir "$HOME/caravel"
fi
cd "$HOME/caravel" || exit

git clone https://github.com/efabless/caravel_user_project.git
cd caravel_user_project || exit
git checkout "$USER_PROJECT_COMMIT"
make install

# Get caravel with the right version
cd caravel || exit
git checkout "$CARAVEL_COMMIT"
cd ..

# Build the correct PDK version for Caravel
make pdk
# Build the correct OpenLane version for Caravel
make openlane
# Build the mpw-precheck tool
make precheck

cd ..
