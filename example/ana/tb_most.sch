v {xschem version=3.0.0 file_version=1.2 }
G {}
K {}
V {}
S {}
E {}
T {(c) 2021 Harald Pretl, JKU, IIC

MOSFET Testbench

Use this to explore the dc and ac behavior of the various MOSFET devices.

CTRL-click on "Simulate" to create netlist and start the simulation.} 100 -720 0 0 0.4 0.4 {}
N 240 -100 240 -40 { lab=GND}
N 240 -40 560 -40 { lab=GND}
N 120 -100 120 -40 { lab=GND}
N 120 -40 240 -40 { lab=GND}
N 710 -40 900 -40 { lab=GND}
N 560 -200 630 -200 { lab=GND}
N 560 -170 560 -40 { lab=GND}
N 240 -200 240 -160 { lab=vgs}
N 240 -200 520 -200 { lab=vgs}
N 120 -300 120 -160 { lab=vds}
N 120 -300 560 -300 { lab=vds}
N 560 -420 560 -300 { lab=vds}
N 900 -420 900 -380 { lab=vds}
N 560 -40 630 -40 { lab=GND}
N 560 -420 820 -420 { lab=vds}
N 760 -420 760 -380 { lab=vds}
N 630 -40 710 -40 { lab=GND}
N 630 -200 640 -200 { lab=GND}
N 640 -200 640 -40 { lab=GND}
N 760 -320 760 -280 { lab=#net1}
N 760 -280 820 -280 { lab=#net1}
N 820 -350 820 -280 { lab=#net1}
N 820 -350 860 -350 { lab=#net1}
N 820 -420 900 -420 { lab=vds}
N 700 -330 720 -330 { lab=GND}
N 700 -330 700 -40 { lab=GND}
N 400 -370 400 -200 { lab=vgs}
N 400 -370 720 -370 { lab=vgs}
N 900 -350 1000 -350 { lab=vds}
N 1000 -420 1000 -350 { lab=vds}
N 900 -420 1000 -420 { lab=vds}
N 560 -300 560 -290 { lab=vds}
N 900 -260 900 -40 { lab=GND}
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
C {devices/vsource.sym} 240 -130 0 0 {name=Vg value=5
}
C {devices/code_shown.sym} -240 -590 0 0 {name=NGSPICE only_toplevel=true value="
.control

set noaskquit
set filetype=ascii
save all

op
dc Vd 0 5 0.01 Vg 0 5 1

write tb_most.raw

plot i(Vnid)
plot i(Vpid)

* exit

.endc
"}
C {devices/vsource.sym} 120 -130 0 0 {name=Vd
 value=5
}
C {sky130_fd_pr/nfet_g5v0d10v5.sym} 540 -200 0 0 {name=M1
L=0.5
W=5
nf=1 mult=1
model=nfet_g5v0d10v5
spiceprefix=X
}
C {sky130_fd_pr/pfet_g5v0d10v5.sym} 880 -350 0 0 {name=M9
L=0.5
W=5
nf=1 mult=1
model=pfet_g5v0d10v5
spiceprefix=X
}
C {devices/lab_wire.sym} 470 -200 0 0 {name=l2 lab=vgs}
C {devices/lab_wire.sym} 470 -300 0 0 {name=l3 lab=vds}
C {devices/vcvs.sym} 760 -350 0 0 {name=E1 value=1}
C {devices/gnd.sym} 160 -40 0 0 {name=l4 lab=GND}
C {devices/ammeter.sym} 900 -290 0 0 {name=Vpid}
C {devices/ammeter.sym} 560 -260 0 0 {name=Vnid}
