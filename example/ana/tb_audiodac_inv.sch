v {xschem version=3.0.0 file_version=1.2 }
G {}
K {}
V {}
S {}
E {}
T {(c) 2021 Harald Pretl, JKU, IIC

Inverter Testbench

Here a simple inverter (cell "audiodac_inv") is instantiated as a symbol, and this
can be simulated.} 140 -690 0 0 0.4 0.4 {}
N 240 -100 240 -40 { lab=GND}
N 240 -40 360 -40 { lab=GND}
N 360 -100 360 -40 { lab=GND}
N 360 -200 360 -160 { lab=in}
N 240 -380 240 -160 { lab=vdd_hi}
N 360 -40 600 -40 { lab=GND}
N 360 -200 620 -200 { lab=in}
N 600 -180 620 -180 { lab=GND}
N 600 -180 600 -40 { lab=GND}
N 600 -220 620 -220 { lab=vdd_hi}
N 600 -380 600 -220 { lab=vdd_hi}
N 240 -380 600 -380 { lab=vdd_hi}
N 240 -40 240 -20 { lab=GND}
N 600 -40 1020 -40 { lab=GND}
N 1020 -100 1020 -40 { lab=GND}
N 1020 -220 1020 -160 { lab=out}
N 920 -220 1020 -220 { lab=out}
C {devices/code.sym} -230 -190 0 0 {name=TT_MODELS
only_toplevel=true
format="tcleval( @value )"
value="** manual skywater pdks install (with patches applied)
* .lib \\\\$::SKYWATER_MODELS\\\\/models/sky130.lib.spice tt

** opencircuitdesign pdks install
.lib \\\\$::SKYWATER_MODELS\\\\/sky130.lib.spice.tt.red tt

.param mc_mm_switch=0
.param mc_pr_switch=0
"
spice_ignore=false}
C {devices/launcher.sym} -150 -30 0 0 {name=h2 
descr="Simulate" 
tclcommand="xschem netlist; xschem simulate"}
C {devices/vsource.sym} 240 -130 0 0 {name=V2 value=5
}
C {devices/lab_wire.sym} 310 -380 0 0 {name=l2 lab=vdd_hi}
C {devices/code_shown.sym} -250 -470 0 0 {name=NGSPICE
only_toplevel=true
value="
.control
set noaskquit
set filetype=ascii
save all

op
tran 0.1n 1u

write tb_audiodac_inv.raw
* exit

.endc
"}
C {devices/lab_wire.sym} 400 -200 0 0 {name=l3 lab=in}
C {devices/vsource.sym} 360 -130 0 0 {name=V5
value1="dc 5 "
value="dc 5 pulse 5 0 0 1n 1n 0.05u 0.1u"}
C {audiodac_inv.sym} 770 -200 0 0 {name=x1}
C {devices/gnd.sym} 240 -20 0 0 {name=l1 lab=GND}
C {devices/capa.sym} 1020 -130 0 0 {name=C1
m=1
value=10f

footprint=1206
device="ceramic capacitor"}
C {devices/lab_wire.sym} 990 -220 0 0 {name=l4 lab=out
}
