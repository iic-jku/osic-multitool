# IIC-OSIC Tools

**(c) 2021 Harald Pretl, Johannes Kepler University Linz, Institute for Integrated Circuits**

This repo contains various tools and examples for Open-Source IC (OSIC) Design. At this point only the open-source PDK `SKY130` from SkyWater Technologies is supported.

## Initialization of SKY130 PDK and tools

Use `iic-osic-setup.sh` to setup or update a complete analog/digital IC design environment in Ubuntu/Xubuntu. Please see the (documented) script for usage and the installed tools.

The setup script creates also an initialization script in the user's home directory. Use it to setup the environment by running

`source ~/iic-init.sh`

## LVS script

A fully-automatic LVS script is prepared. Run the LVS by using `iic-lvs.sh <cellname>`, where `<cellname>` is the name of the schematic/verilog and layout cell. For further documentation and usage of this script please look into the file.

## DRC script

A fully-automatic DRC script is prepared. Run the DRC by using `iic-drc.sh <cellname>`, where `<cellname>` is the name of the layout cell <cellname>.mag. 

_Note that this DRC can show additional errors compared to the (fast) DRC during layout generation, as this DRC runs in CIF/GDS mode._

## PEX script

A fully-automatic PEX script for parasitic extraction is prepared. Run the PEX by using `iic-pex.sh <cellname>`, where `<cellname>` is the name of the layout cell <cellname>.mag.

The resulting SPICE netlist including parasitic wiring components is called <cellname>.pex.spice.

## Cleanup of temporary files

The various temporary and results files and outputs can be removed from a directory by running `iic-clean.sh`.

## Cheatsheet for magic

In the folder `magic-cheatsheet` there is a summary of important macros, keybindings, and mouse button operations for `magic` VLSI, relating to version 8.3.

## Example analog and digital designs

In the folder `example` an analog design example (an inverter in subfolder `example/ana`) and a simple digital design example (a counter in subfolder `example/dig`) are prepared for testing the environment. In the folder `example/dig/rtl` the result of the digital flow `OpenLane` is presented, as a powered Verilog file and a layout view.

## SPICE model file reducer

This Python script traverses through a SPICE model file, removes empty lines and comments, and extracts the
specified model corner (default is `tt`). It further produces a flat single model file for use with e.g. `ngspice`.

On my Unix machine, the time to simulation (`ngspice` start to actual simulation start) is 80sec using the
original SPICE model files from the SKY130A PDK created by open_pdks (https://github.com/RTimothyEdwards/open_pdks).
Using this model file reducer, the ngspice startup is improved to 5sec!

This script can also be used to check the original model file, as it reports warnings when include files
are not found.

**Usage:**

```
iic-spice-model-red.py input_file [section]
```

It reads the `input_file` and writes an output file called `input_file.<section>.red`. If called without parameters
the script displays a help screen.

Exemplary use on the SKY130A model file:

```
iic-spice-model-red.py sky130.lib.spice tt
```

## Todo:

* SPICE model file reducer: Add better control of output during run, maybe add a `--verbose` switch.
* PEX: Add extraction of parasitic resistors
