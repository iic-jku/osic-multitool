# IIC-OSIC Tools

## (c) 2021 Harald Pretl, Johannes Kepler University Linz, Institute for Integrated Circuits

This repo contains various tools and examples for Open-Source IC Design. At this point only the open-source PDK `SKY130` from SkyWater Technologies is supported.

### Initialization of SKY130 PDK and tools

Use `iic-osic-setup.sh` to setup or update a complete analog/digital IC design environment in Ubuntu/Xubuntu. Please see the script for usage and the installed tools.

The setup script creates an initialization script in the user's home directory. Use it to setup the environment by running

`source ~/iic-init.sh`

### LVS script

A fully-automatic LVS script is prepared. Run the LVS by using `iic-lvs.sh <cellname>`, where `<cellname>` is the name of the schematic and layout cell. For further documentation and usage of this script please look into the file.

### Cleanup of temporary files

The various temporary files and outputs can be removed from a directory by running `iic-clean.sh`.

### Example analog and digital designs

In the folder `example` an analog design example (an inverter in subfolder `example/ana`) and a simple digital design example (a counter in subfolder `example/dig`) are prepared for testing the environment.
