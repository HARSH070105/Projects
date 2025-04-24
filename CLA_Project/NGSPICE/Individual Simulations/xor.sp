.include TSMC_180nm.txt
.param LAMBDA = 0.09u
.param Wn = 1.8u
.param Wp = 3.6u
.param SUPPLY = 1.8
.global gnd vdd

Vdd vdd gnd 'SUPPLY'

vin_a1 a1         0 pulse 0 1.8 0ns 10ps 10ps 05ns 10ns
vin_a1_bar a1_bar 0 pulse 1.8 0 0ns 10ps 10ps 05ns 10ns
vin_b1 b1         0 pulse 0 1.8 0ns 10ps 10ps 10ns 20ns
vin_b1_bar b1_bar 0 pulse 1.8 0 0ns 10ps 10ps 10ns 20ns

.subckt xor y x1 x1_bar x2 x2_bar vdd gnd
M1 n1 x1_bar vdd vdd CMOSP W={2*Wp} L={2*LAMBDA}
+ AS={10*Wp*LAMBDA} PS={10*LAMBDA+4*Wp}
+ AD={10*Wp*LAMBDA} PD={10*LAMBDA+4*Wp}

M2 y x2 n1 vdd CMOSP W={2*Wp} L={2*LAMBDA}
+ AS={10*Wp*LAMBDA} PS={10*LAMBDA+4*Wp}
+ AD={10*Wp*LAMBDA} PD={10*LAMBDA+4*Wp}

M3 n2 x1 vdd vdd CMOSP W={2*Wp} L={2*LAMBDA}
+ AS={10*Wp*LAMBDA} PS={10*LAMBDA+4*Wp}
+ AD={10*Wp*LAMBDA} PD={10*LAMBDA+4*Wp}

M4 y x2_bar n2 vdd CMOSP W={2*Wp} L={2*LAMBDA}
+ AS={10*Wp*LAMBDA} PS={10*LAMBDA+4*Wp}
+ AD={10*Wp*LAMBDA} PD={10*LAMBDA+4*Wp}

M5 y x2_bar n3 gnd CMOSN W={2*Wn} L={2*LAMBDA}
+ AS={10*Wn*LAMBDA} PS={10*LAMBDA+4*Wn}
+ AD={10*Wn*LAMBDA} PD={10*LAMBDA+4*Wn}

M6 n3 x1_bar gnd gnd CMOSN W={2*Wn} L={2*LAMBDA}
+ AS={10*Wn*LAMBDA} PS={10*LAMBDA+4*Wn}
+ AD={10*Wn*LAMBDA} PD={10*LAMBDA+4*Wn}

M7 y x2 n4 gnd CMOSN W={2*Wn} L={2*LAMBDA}
+ AS={10*Wn*LAMBDA} PS={10*LAMBDA+4*Wn}
+ AD={10*Wn*LAMBDA} PD={10*LAMBDA+4*Wn}

M8 n4 x1 gnd gnd CMOSN W={2*Wn} L={2*LAMBDA}
+ AS={10*Wn*LAMBDA} PS={10*LAMBDA+4*Wn}
+ AD={10*Wn*LAMBDA} PD={10*LAMBDA+4*Wn}
.ends xor

x1 c1 a1 a1_bar b1 b1_bar vdd gnd xor

.tran 0.1n 30n
.tran 0.1n 40n
.measure tran rise_time_c 
+ TRIG v(c1) VAL='0.1*SUPPLY' RISE=1
+ TARG v(c1) VAL='0.9*SUPPLY' RISE=1
.measure tran fall_time_c
+ TRIG v(c1) VAL='0.9*SUPPLY' FALL=1
+ TARG v(c1) VAL='0.1*SUPPLY' FALL=1
.measure tran tpd param='(rise_time_c + fall_time_c)/2'
.measure tran delay_a_to_c
+ TRIG v(a1) VAL='SUPPLY/2' FALL=1  
+ TARG v(c1) VAL='SUPPLY/2' RISE=1 
.control
set hcopypscolor = 1
set color0=white
set color1=black
set color2=red
set color3=blue
set color4=darkgreen

run
plot v(c1) v(a1)+2 v(b1)+4 

.endc