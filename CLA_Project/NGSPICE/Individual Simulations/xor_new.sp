.include TSMC_180nm.txt
.param LAMBDA = 0.09u
.param Wn = 1.8u
.param Wp = 3.6u
.param SUPPLY = 1.8
.global gnd vdd

Vdd	vdd	gnd	'SUPPLY'
vin_a a 0 pulse 0 1.8 0ns 0ns 0ns 5ns 10ns
vin_b b 0 pulse 0 1.8 0ns 0ns 0ns 10ns 20ns

.subckt xor_new n2 x1 x2 vdd gnd
M1 n1 x2 vdd vdd CMOSP W={Wp} L={2*LAMBDA}
+ AS={5*Wp*LAMBDA} PS={10*LAMBDA+2*Wp}
+ AD={5*Wp*LAMBDA} PD={10*LAMBDA+2*Wp}

M2 n1 x2 gnd gnd CMOSN W={Wn} L={2*LAMBDA}
+ AS={5*Wp*LAMBDA} PS={10*LAMBDA+2*Wp}
+ AD={5*Wp*LAMBDA} PD={10*LAMBDA+2*Wp}

M3 n2 x1 x2 vdd CMOSP W={Wp} L={2*LAMBDA}
+ AS={5*Wp*LAMBDA} PS={10*LAMBDA+2*Wp}
+ AD={5*Wp*LAMBDA} PD={10*LAMBDA+2*Wp}

M4 n2 x1 n1 gnd CMOSN W={Wn} L={2*LAMBDA}
+ AS={5*Wp*LAMBDA} PS={10*LAMBDA+2*Wp}
+ AD={5*Wp*LAMBDA} PD={10*LAMBDA+2*Wp}

M5 n3 x1 n1 vdd CMOSP W={Wp} L={2*LAMBDA}
+ AS={5*Wp*LAMBDA} PS={10*LAMBDA+2*Wp}
+ AD={5*Wp*LAMBDA} PD={10*LAMBDA+2*Wp}

M6 n3 x1 x2 gnd CMOSN W={Wn} L={2*LAMBDA}
+ AS={5*Wp*LAMBDA} PS={10*LAMBDA+2*Wp}
+ AD={5*Wp*LAMBDA} PD={10*LAMBDA+2*Wp}

M7 x1 x2 n2 vdd CMOSP W={Wp} L={2*LAMBDA}
+ AS={5*Wp*LAMBDA} PS={10*LAMBDA+2*Wp}
+ AD={5*Wp*LAMBDA} PD={10*LAMBDA+2*Wp}

M8 n3 x2 x1 gnd CMOSN W={Wn} L={2*LAMBDA}
+ AS={5*Wp*LAMBDA} PS={10*LAMBDA+2*Wp}
+ AD={5*Wp*LAMBDA} PD={10*LAMBDA+2*Wp}

M9 n3 n2 vdd vdd CMOSP W={Wp} L={2*LAMBDA}
+ AS={5*Wp*LAMBDA} PS={10*LAMBDA+2*Wp}
+ AD={5*Wp*LAMBDA} PD={10*LAMBDA+2*Wp}

M10 n2 n3 gnd gnd CMOSN W={Wn} L={2*LAMBDA}
+ AS={5*Wp*LAMBDA} PS={10*LAMBDA+2*Wp}
+ AD={5*Wp*LAMBDA} PD={10*LAMBDA+2*Wp}
.ends xor_new

.option brief=0

xn1 c a b vdd gnd xor_new


.tran 0.1n 40n
.measure tran rise_time_c 
+ TRIG v(c) VAL='0.1*SUPPLY' RISE=1
+ TARG v(c) VAL='0.9*SUPPLY' RISE=1
.measure tran fall_time_c
+ TRIG v(c) VAL='0.9*SUPPLY' FALL=1
+ TARG v(c) VAL='0.1*SUPPLY' FALL=1
.measure tran tpd param='(rise_time_c + fall_time_c)/2'
.measure tran delay_a_to_c
+ TRIG v(a) VAL='SUPPLY/2' FALL=1  
+ TARG v(c) VAL='SUPPLY/2' RISE=1 

.control
set hcopypscolor = 1
set color0=white
set color1=black
set color2=red
set color3=blue
set color4=darkgreen

run
plot v(c) v(a)+2 v(b)+4 

.endc