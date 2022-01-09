# IIC-OSIC Tools

**(c) 2021 Harald Pretl, Johannes Kepler University Linz, Institute for Integrated Circuits**

This repo contains various tools and examples for **Open-Source IC (OSIC) Design**. At this point only the open-source PDK [SKY130](https://github.com/google/skywater-pdk) from **SkyWater Technologies** and **Google** is supported.

This flow is using for the digital components
* [OpenLane](https://github.com/The-OpenROAD-Project/OpenLane) for the digital design flow,
* [Icarus Verilog](http://iverilog.icarus.com) and [Verilator](https://www.veripool.org/verilator/) for linting and digital simulation, and
* [gtkwave](http://gtkwave.sourceforge.net) for digital waveform viewing.

The analog/full custom components are using
* [xschem](https://github.com/StefanSchippers/xschem) for schematic capture,
* [ngspice](http://ngspice.sourceforge.net) for simulation,
* [gaw](https://github.com/StefanSchippers/xschem-gaw) for analog waveform viewing,
* [magic](https://github.com/RTimothyEdwards/magic) for custom layout generation, DRC and PEX, and
* [netgen](https://github.com/RTimothyEdwards/netgen) for netlist compare (LVS).

A viable alternative to `gaw` is to use `Python` for waveform viewing, using [spyci](https://github.com/gmagno/spyci).

For GDS file viewing and manipulation [klayout](https://www.klayout.de) is used.

## Initialization of SKY130 PDK and tools

Use `iic-osic-setup.sh` to setup or update a complete analog/digital IC design environment in Ubuntu/Xubuntu. Please see the (documented) script for usage and the installed tools.

The setup script creates also an initialization script in the user's home directory. Use it to setup the environment by running

```shell
source ./iic-init.sh
```

## LVS script

A fully-automatic LVS script is prepared. Run the LVS by using 

```shell
./iic-lvs.sh cellname
```

where `cellname` is the name of the schematic/verilog and layout cell. For further documentation and usage of this script please look into the file.

## DRC script

A fully-automatic DRC script is prepared. Run the DRC by using 

```shell
./iic-drc.sh cellname
```

where `cellname` is the name of the layout cell `cellname.mag`. 

_Note that this DRC can show additional errors compared to the (fast) DRC during layout generation, as this DRC runs in CIF/GDS mode!_

## PEX script

A fully-automatic PEX script for parasitic extraction is prepared. Run the PEX by using 

```shell
./iic-pex.sh cellname
```

where `cellname` is the name of the layout cell `cellname.mag`.

The resulting `SPICE` netlist including parasitic wiring components is called `cellname.pex.spice`.

## Cleanup of temporary files

The various temporary and results files and outputs can be easily removed from a directory by running

```shell
./iic-clean.sh
```

## Cheatsheet for Magic VLSI

In the folder `magic-cheatsheet` you can find a summary of important macros, keybindings, and mouse button operations for `magic` VLSI, relating to version 8.3.

## Example analog and digital designs

In the folder `example` an analog design example (an inverter in subfolder `example/ana`) and a simple digital design example (a counter in subfolder `example/dig`) are prepared for testing the environment. In the folder `example/dig/rtl` the result of the digital flow `OpenLane` is presented, as a powered Verilog file and a layout view.

## SPICE model file reducer

This Python script traverses through a SPICE model file, removes empty lines and comments, and extracts the
specified model corner (default is `tt`). It further produces a flat single model file for use with e.g. `ngspice`.

On my Unix machine, the time to simulation (`ngspice` start to actual simulation start) is 80sec using the
original SPICE model files from the SKY130A PDK created by [open_pdks](https://github.com/RTimothyEdwards/open_pdks).
Using this model file reducer, the ngspice startup is improved to 5sec!

This script can also be used to check the original model file, as it reports warnings when include files
are not found.

Usage:
```shell
./iic-spice-model-red.py input_file [section]
```

It reads the `input_file` and writes an output file called `input_file.<section>.red`. If called without parameters
the script displays a help screen.

Exemplary use on the SKY130A model file:
```shell
./iic-spice-model-red.py sky130.lib.spice tt
```

## Verilog to schematic/symbol conversion

The script `iic-v2sch.awk` is a link to Stefan Schippers' conversion script `make_sky130_sch_from_verilog.awk`, see [xschem_sky130](https://github.com/StefanSchippers/xschem_sky130). It creates a symbol and schematic view for `xschem` from a Powered-Verilog file. The schematic can be used to run a transistor-level simulation of a Verilog design, or to run an LVS on transistor-level of a synthesized digital design.

Usage:
```shell
./iic-v2sch.awk input_file.v
```

The `input_file` is the Powered-Verilog `.v` file. The symbol `input_file.sym` and the corresponding schematic `input_file.sch` are then created.

## Todo and Known Bugs

* SPICE model file reducer: Add better control of output during run, maybe add a `--verbose` switch.
* PEX: Add extraction of parasitic resistors.
