set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets Clk_IBUF] 

set_property -dict {PACKAGE_PIN H2 IOSTANDARD LVCMOS33} [get_ports {Clk}]

set_property -dict {PACKAGE_PIN K1 IOSTANDARD LVCMOS33} [get_ports {A[3]}]
set_property -dict {PACKAGE_PIN K2 IOSTANDARD LVCMOS33} [get_ports {A[2]}]
set_property -dict {PACKAGE_PIN L1 IOSTANDARD LVCMOS33} [get_ports {A[1]}]
set_property -dict {PACKAGE_PIN M1 IOSTANDARD LVCMOS33} [get_ports {A[0]}]

set_property -dict {PACKAGE_PIN M2 IOSTANDARD LVCMOS33} [get_ports {B[3]}]
set_property -dict {PACKAGE_PIN N1 IOSTANDARD LVCMOS33} [get_ports {B[2]}]
set_property -dict {PACKAGE_PIN N2 IOSTANDARD LVCMOS33} [get_ports {B[1]}]
set_property -dict {PACKAGE_PIN P1 IOSTANDARD LVCMOS33} [get_ports {B[0]}]

set_property -dict {PACKAGE_PIN V2 IOSTANDARD LVCMOS33} [get_ports {Cin}]
set_property -dict {PACKAGE_PIN U2 IOSTANDARD LVCMOS33} [get_ports {Reset}]


#set_property -dict {PACKAGE_PIN G1 IOSTANDARD LVCMOS33} [get_ports {Sum_out[0]}]
#set_property -dict {PACKAGE_PIN G2 IOSTANDARD LVCMOS33} [get_ports {Sum_out[1]}]
#set_property -dict {PACKAGE_PIN F1 IOSTANDARD LVCMOS33} [get_ports {Sum_out[2]}]
#set_property -dict {PACKAGE_PIN F2 IOSTANDARD LVCMOS33} [get_ports {Sum_out[3]}]
#set_property -dict {PACKAGE_PIN E1 IOSTANDARD LVCMOS33} [get_ports {Cout_out}]

set_property -dict {PACKAGE_PIN E12 IOSTANDARD LVCMOS33} [get_ports {Sum_out[0]}]
set_property -dict {PACKAGE_PIN B13 IOSTANDARD LVCMOS33} [get_ports {Sum_out[1]}]
set_property -dict {PACKAGE_PIN D12 IOSTANDARD LVCMOS33} [get_ports {Sum_out[2]}]
set_property -dict {PACKAGE_PIN A13 IOSTANDARD LVCMOS33} [get_ports {Sum_out[3]}]
set_property -dict {PACKAGE_PIN C13 IOSTANDARD LVCMOS33} [get_ports {Cout_out}]