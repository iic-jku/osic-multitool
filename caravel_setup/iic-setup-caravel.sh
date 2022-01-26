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
#
# This script is based on Matt Venn's 
# https://github.com/mattvenn/project0_test
# ==============================================================

my_path=$(realpath "$0")
my_dir=$(dirname "$my_path")
export SCRIPT_DIR="$my_dir"

# Get the correct versions and install paths
"$SCRIPT_DIR/iic-init-caravel.sh"

# Install dependencies via package manager
sudo apt install -y tcsh csh tcl-dev tk-dev libcairo2-dev

set -eu

# Get caravel user project with the right version
if [ ! -d "$CARAVEL_ENV_ROOT" ]; then
	mkdir "$CARAVEL_ENV_ROOT"
fi
cd "$CARAVEL_ENV_ROOT" || exit

git clone https://github.com/efabless/caravel_user_project.git
cd caravel_user_project || exit
git checkout $CARAVEL_USER_PROJECT_COMMIT
make install

# Get caravel with the right version
cd caravel || exit
git checkout $CARAVEL_COMMIT
cd ..

# Build the correct PDK version for Caravel
make pdk
# Build the correct OpenLane version for Caravel
make openlane
# Build the mpw-precheck tool
make precheck

cd ..
