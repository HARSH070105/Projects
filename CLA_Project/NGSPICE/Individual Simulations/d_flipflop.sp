.include TSMC_180nm.txt
.param SUPPLY=1.8
.param VGG=1.5
.param LAMBDA=0.09u
.param width_N={10*LAMBDA}
.param width_P={20*LAMBDA}
.global gnd vdd

Vimp vdd gnd 1.8V

V1  clk gnd PULSE(0V 1.8V 0 0 0 5ns  10ns)
V2  d   gnd PULSE(1.8V 0V 37.5ps 0 0 10ns 20ns)

.subckt lllatch d clk lout vdd gnd
M1 vdd d n1 vdd CMOSP W={2*width_P} L={2*LAMBDA}
+ AS={5*2*width_P*LAMBDA} PS={10*LAMBDA+2*2*width_P} 
+ AD={5*2*width_P*LAMBDA} PD={10*LAMBDA+2*2*width_P}

M2 n1 clk n2 vdd CMOSP W={2*width_P} L={2*LAMBDA}
+ AS={5*2*width_P*LAMBDA} PS={10*LAMBDA+2*2*width_P} 
+ AD={5*2*width_P*LAMBDA} PD={10*LAMBDA+2*2*width_P}

M3 n2 d gnd gnd CMOSN W={width_N} L={2*LAMBDA}
+ AS={5*width_N*LAMBDA} PS={10*LAMBDA+2*width_N}
+ AD={5*width_N*LAMBDA} PD={10*LAMBDA+2*width_N}

M4 vdd n2 n3 vdd CMOSP W={2*width_P} L={2*LAMBDA}
+ AS={5*2*width_P*LAMBDA} PS={10*LAMBDA+2*2*width_P}
+ AD={5*2*width_P*LAMBDA} PD={10*LAMBDA+2*2*width_P}

M5 n3 clk lout vdd CMOSP W={2*width_P} L={2*LAMBDA}
+ AS={5*2*width_P*LAMBDA} PS={10*LAMBDA+2*2*width_P}
+ AD={5*2*width_P*LAMBDA} PD={10*LAMBDA+2*2*width_P}

M6 lout n2 gnd gnd CMOSN W={width_N} L={2*LAMBDA}
+ AS={5*width_N*LAMBDA} PS={10*LAMBDA+2*width_N}
+ AD={5*width_N*LAMBDA} PD={10*LAMBDA+2*width_N}
.ends lllatch

.subckt hllatch in clk q vdd gnd
M1 vdd in n1 vdd CMOSP W={width_P} L={2*LAMBDA}
+ AS={5*width_P*LAMBDA} PS={10*LAMBDA+2*width_P}
+ AD={5*width_P*LAMBDA} PD={10*LAMBDA+2*width_P}

M2 n1 clk n2 gnd CMOSN W={2*width_N} L={2*LAMBDA}
+ AS={5*2*width_N*LAMBDA} PS={10*LAMBDA+2*2*width_N}
+ AD={5*2*width_N*LAMBDA} PD={10*LAMBDA+2*2*width_N}

M3 n2 in gnd gnd CMOSN W={2*width_N} L={2*LAMBDA}
+ AS={5*2*width_N*LAMBDA} PS={10*LAMBDA+2*2*width_N}
+ AD={5*2*width_N*LAMBDA} PD={10*LAMBDA+2*2*width_N}

M4 vdd n1 q vdd CMOSP W={width_P} L={2*LAMBDA}
+ AS={5*width_P*LAMBDA} PS={10*LAMBDA+2*width_P}
+ AD={5*width_P*LAMBDA} PD={10*LAMBDA+2*width_P}

M5 q clk n3 gnd CMOSN W={2*width_N} L={2*LAMBDA}
+ AS={5*2*width_N*LAMBDA} PS={10*LAMBDA+2*2*width_N}
+ AD={5*2*width_N*LAMBDA} PD={10*LAMBDA+2*2*width_N}

M6 n3 n1 gnd gnd CMOSN W={2*width_N} L={2*LAMBDA}
+ AS={5*2*width_N*LAMBDA} PS={10*LAMBDA+2*2*width_N}
+ AD={5*2*width_N*LAMBDA} PD={10*LAMBDA+2*2*width_N}
.ends hllatch

.subckt dflipflop d clk q vdd gnd
x1 d clk lout vdd gnd lllatch
x2 lout clk q vdd gnd hllatch
.ends dflipflop

x1 d clk q vdd gnd dflipflop

.tran 0.1n 40n

.measure tran delay_clk_to_q
+ TRIG v(clk) VAL='SUPPLY/2' RISE=3  
+ TARG v(q) VAL='SUPPLY/2' RISE=1 

.control
set hcopypscolor = 1
set color0=white
set color1=black
set color2=red
set color3=blue
set color4=darkgreen

run

plot q d+2 clk+4
.endc