.include TSMC_180nm.txt
.param LAMBDA = 0.09u
.param Wn = 1.8u
.param Wp = 3.6u
.param SUPPLY = 1.8
.global gnd vdd

Vdd	vdd	gnd	'SUPPLY'
vin_a a1 0 pulse 0 1.8 0ns 0ns 0ns 5ns 10ns
vin_b b1 0 pulse 0 1.8 0ns 0ns 0ns 10ns 20ns

.subckt and_with_inv y x1 x2 vdd gnd
* NAND section
M1 n1 x1 vdd vdd CMOSP W={Wp} L={2*LAMBDA}
+ AS={5*Wp*LAMBDA} PS={10*LAMBDA+2*Wp}
+ AD={5*Wp*LAMBDA} PD={10*LAMBDA+2*Wp}

M2 n1 x2 vdd vdd CMOSP W={Wp} L={2*LAMBDA}
+ AS={5*Wp*LAMBDA} PS={10*LAMBDA+2*Wp}
+ AD={5*Wp*LAMBDA} PD={10*LAMBDA+2*Wp}

M3 n1 x1 n2 gnd CMOSN W={2*Wn} L={2*LAMBDA}
+ AS={10*Wn*LAMBDA} PS={10*LAMBDA+4*Wn}
+ AD={10*Wn*LAMBDA} PD={10*LAMBDA+4*Wn}

M4 n2 x2 gnd gnd CMOSN W={2*Wn} L={2*LAMBDA}
+ AS={10*Wn*LAMBDA} PS={10*LAMBDA+4*Wn}
+ AD={10*Wn*LAMBDA} PD={10*LAMBDA+4*Wn}

* Inverter section
M5 y n1 gnd gnd CMOSN W={2*Wn} L={2*LAMBDA}
+ AS={5*Wn*LAMBDA} PS={10*LAMBDA+2*Wn}
+ AD={5*Wn*LAMBDA} PD={10*LAMBDA+2*Wn}

M6 y n1 vdd vdd CMOSP W={2*Wp} L={2*LAMBDA}
+ AS={5*Wp*LAMBDA} PS={10*LAMBDA+2*Wp}
+ AD={5*Wp*LAMBDA} PD={10*LAMBDA+2*Wp}
.ends and_with_inv

xn1 c1 b1 a1 vdd gnd and_with_inv

.tran 0.1n 30n

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