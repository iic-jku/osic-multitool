v {xschem version=3.0.0 file_version=1.2 }
G {}
K {}
V {}
S {}
E {}
N 560 -1020 600 -1020 { lab=VDD}
N 560 -890 600 -890 { lab=in}
N 560 -760 600 -760 { lab=VSS}
N 840 -890 880 -890 { lab=out}
C {devices/ipin.sym} 560 -890 0 0 {name=p1 lab=in}
C {devices/opin.sym} 880 -890 0 0 {name=p3 lab=out
}
C {devices/ipin.sym} 560 -1020 0 0 {name=p5 lab=VDD
}
C {devices/ipin.sym} 560 -760 0 0 {name=p6 lab=VSS}
C {devices/noconn.sym} 840 -890 0 0 {name=l1}
C {devices/noconn.sym} 600 -1020 0 1 {name=l2}
C {devices/noconn.sym} 600 -890 0 1 {name=l3}
C {devices/noconn.sym} 600 -760 0 1 {name=l4}
C {devices/code.sym} 660 -930 0 0 {name=s1 only_toplevel=false value=".include inv.pex.spice"}
