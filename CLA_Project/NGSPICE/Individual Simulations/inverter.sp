.include TSMC_180nm.txt
.param LAMBDA=0.09u
.param Wpl={40*LAMBDA}
.param Wnl={20*LAMBDA}
.param Wn={20*LAMBDA}
.param k = 2
.param Wp={k*Wn}
.param SUPPLY=1.8
.global gnd vdd

Vdd vdd gnd 'SUPPLY'

vin_a1 a1 0 pulse 0 1.8 0ns 10ps 10ps 05ns 10ns

.subckt inv y x vdd gnd
M1 y x gnd gnd CMOSN W={Wn} L={2*LAMBDA}
+ AS={5*Wn*LAMBDA} PS={10*LAMBDA+2*Wn} 
+ AD={5*Wn*LAMBDA} PD={10*LAMBDA+2*Wn}

M2 y x vdd vdd CMOSP W={Wp} L={2*LAMBDA}
+ AS={5*Wp*LAMBDA} PS={10*LAMBDA+2*Wp}
+ AD={5*Wp*LAMBDA} PD={10*LAMBDA+2*Wp}
.ends inv

xn1 a1_bar a1 vdd gnd inv

.tran 0.1n 20n

.measure tran rise_time
+ TRIG v(a1_bar) VAL='0.1*SUPPLY' RISE=1
+ TARG v(a1_bar) VAL='0.9*SUPPLY' RISE=1
.measure tran fall_time
+ TRIG v(a1_bar) VAL='0.9*SUPPLY' FALL=1
+ TARG v(a1_bar) VAL='0.1*SUPPLY' FALL=1
.measure tran tpd param='(rise_time + fall_time)/2'
.measure tran a1_to_a1_bar
+ TRIG v(a1) VAL='SUPPLY/2' RISE=1  
+ TARG v(a1_bar)   VAL='SUPPLY/2' FALL=1 

.control
set hcopypscolor = 1
set color0=white
set color1=black
set color2=red
set color3=blue
set color4=darkgreen

run
plot v(a1)+2 v(a1_bar)

.endc