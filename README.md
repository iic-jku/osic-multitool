# IIC-OSIC Tools

**(c) 2021-2022 Harald Pretl, Johannes Kepler University Linz, Institute for Integrated Circuits**

This repo contains various tools and examples for **Open-Source IC (OSIC) Design**. At this point, only the open-source PDK [SKY130](https://github.com/google/skywater-pdk) from **SkyWater Technologies** and **Google** is supported.

This flow is used for the digital components
* [OpenLane/OpenROAD](https://github.com/The-OpenROAD-Project/OpenLane) for the digital RTL2GDS flow,
* [Icarus Verilog](http://iverilog.icarus.com) and [Verilator](https://www.veripool.org/verilator/) for linting and digital simulation, and
* [GTKWave](http://gtkwave.sourceforge.net) for digital waveform viewing.

The analog/full custom components are using
* [Xschem](https://github.com/StefanSchippers/xschem) for schematic capture,
* [ngspice](http://ngspice.sourceforge.net) for simulation,
* [gaw3](https://github.com/StefanSchippers/xschem-gaw) for analog waveform viewing,
* [Magic](https://github.com/RTimothyEdwards/magic) for custom layout generation, DRC, extraction, and PEX, and
* [Netgen](https://github.com/RTimothyEdwards/netgen) for netlist compare (LVS).

A viable alternative to `gaw` is to use `Python` for waveform viewing, using [Spyci](https://github.com/gmagno/spyci).

For `GDS` file viewing and manipulation [KLayout](https://www.klayout.de) is used.

## Initialization of SKY130 PDK and tools

Use `iic-osic-setup.sh` to set up or update a complete analog/digital IC design environment in Ubuntu/Xubuntu. Please see the (documented) script for usage and the installed tools.

The setup script creates also an initialization script in the user's home directory. Use it to set up the environment by running

```shell
source ./iic-init.sh
```

## Initialization of efabless.com Caravel SoC harness

Instructions for the setup of the efabless.com Caravel SoC harness can be found at https://github.com/efabless/caravel_user_project/blob/main/docs/source/roundtrip.rst.

In the directory `caravel_setup` a script can be found to set up the environment variables as needed with: 

```shell
source ./iic-init-caravel.sh
```

## LVS script

A fully-automatic LVS script is prepared. Run the LVS by using 

```shell
./iic-lvs.sh cellname
```

where `cellname` is the name of the schematic/Verilog and layout cell. For further documentation and usage of this script please look into the file.

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
./iic-pex.sh cellname [mode]
```

where `cellname` is the name of the layout cell `cellname.mag`. The PEX script support 3 different extraction modes: 1=C-decoupled, 2=C-coupled, 3=full-RC. If the parameter `mode` is not supplied then the default mode 2 (C-coupled) will be used.

The resulting `SPICE` netlist including parasitic wiring components is called `cellname.pex.spice`.

## Cleanup of temporary files

The various temporary and result files and outputs can be easily removed from a directory by running

```shell
./iic-clean.sh
```

## Cheatsheet for Magic

In the folder `magic-cheatsheet` you can find a summary of important macros, keybindings, and mouse button operations for `Magic`, relating to version 8.3.

## Example analog and digital designs

In the folder `example`, an analog design example (an inverter in subfolder `example/ana`) and a simple digital design example (a counter in subfolder `example/dig`) are prepared for testing the environment. In the folder `example/dig/rtl` the result of the digital flow `OpenLane` is presented, as a powered Verilog file and a layout view.

## SPICE model file reducer

This Python script traverses through a SPICE model file, removes empty lines and comments, and extracts the
specified model corner (default is `tt`). It further produces a flat single model file for use with e.g. `ngspice`.

On my Unix machine, the time to simulation (`ngspice` start to actual simulation start) is 80sec using the
original SPICE model files from the SKY130A PDK created by [open_pdks](https://github.com/RTimothyEdwards/open_pdks).
Using this model file reducer, the ngspice startup is improved to 5sec!

This script can also be used to check the original model file, as it reports warnings when included files are not found.

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

## DFFRAM support scripts

Two scripts support the usage of [DFFRAM](https://github.com/AUCOHL/DFFRAM), especially when used with the [IIC-OSIC-TOOLS](https://github.com/hpretl/iic-osic-tools).

With `iic-dffram-install.sh [install_dir]` the DFFRAM GitHub repository is cloned into `install_dir` (if this optional parameter is not provided then the default `dffram` is used).

Using `iic-dffram.sh [parameter list]` provides a wrapper script to set a few parameters correctly (running `iic-dffram.sh` without parameters displays the help screen).

Here is an example for creating a 32b-wide RAM with 32 entries:

```shell
iic-dffram-install.sh test1
cd test1
iic-dffram.sh -s 32x32
```

## GDS3D viewer

The wrapper script `gds3d.sh` is provided to simplify the usage of [GDS3D](https://github.com/trilomix/GDS3D), which is part of the [IIC-OSIC-TOOLS](https://github.com/hpretl/iic-osic-tools) collection.

Usage for 3D-viewing a GDS layout in SKY130 technology (`gds3d.sh -h` shows available options):

```shell
gds3d.sh -i file.gds
```

## CHIP_ART support scripts

Two scripts support the usage of [CHIP_ART](https://github.com/jazvw/chip_art.git), especially when used with the [IIC-OSIC-TOOLS](https://github.com/hpretl/iic-osic-tools).

With `iic-chipart-install.sh [install_dir]` the CHIP_ART GitHub repository is cloned into `install_dir` (if this optional parameter is not provided then the default `chip_art` is used).

Using `iic-chipart.sh [parameter list]` provides a wrapper script to set a few parameters correctly (running `iic-chipart.sh` without parameters displays the help screen).

Here is an example for creating a GDS from the provided example (`chip_art.png`):

```shell
iic-chipart-install.sh test1
cd test1
iic-chipart.sh chip_art.png 50
```

## Verilog to schematic/symbol conversion

The script `iic-v2sch.awk` is a link to Stefan Schippers' conversion script `make_sky130_sch_from_verilog.awk`, see [xschem_sky130](https://github.com/StefanSchippers/xschem_sky130). It creates a symbol and schematic view for `xschem` from a Powered-Verilog file. The schematic can be used to run a transistor-level simulation of a Verilog design or to run an LVS on the transistor level of a synthesized digital design.

Usage:
```shell
./iic-v2sch.awk input_file.v
```

The `input_file` is the Powered-Verilog `.v` file. The symbol `input_file.sym` and the corresponding schematic `input_file.sch` are then created.

## Todo and Known Bugs

* SPICE model file reducer: Add better control of output during a run, maybe add a `--verbose` switch.
* Inductor/trafo flow: (Semi)automatic generation of an inductor and trafo layout, extraction of a SPICE model, adaption and support in LVS and PEX
* A (simple) GUI to set up and run verification campaigns (like DRC, LVS, PEX on several cells, with summarized run status)? Not sure about that, as open-source tooling is generally script-heavy and GUI-light.
