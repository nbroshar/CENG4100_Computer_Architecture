## ============================================================================
##  cpu.xdc  --  Basys 3 pins for the IP Integrator CPU lab.
##  Inputs:  clk (100 MHz, W5), rst (center button BTNC)
##  Outputs: wdata[3:0]=LD0..3 (value written each step: watch 5,3,8)
##           alu_y[3:0]=LD8..11 (ALU output)   pc_addr[1:0]=LD14..15 (which instr)
## ============================================================================
set_property -dict {PACKAGE_PIN W5  IOSTANDARD LVCMOS33} [get_ports clk]
create_clock -name sys_clk -period 10.000 [get_ports clk]
set_property -dict {PACKAGE_PIN U18 IOSTANDARD LVCMOS33} [get_ports rst]

set_property -dict {PACKAGE_PIN U16 IOSTANDARD LVCMOS33} [get_ports {wdata[0]}]
set_property -dict {PACKAGE_PIN E19 IOSTANDARD LVCMOS33} [get_ports {wdata[1]}]
set_property -dict {PACKAGE_PIN U19 IOSTANDARD LVCMOS33} [get_ports {wdata[2]}]
set_property -dict {PACKAGE_PIN V19 IOSTANDARD LVCMOS33} [get_ports {wdata[3]}]
set_property -dict {PACKAGE_PIN V13 IOSTANDARD LVCMOS33} [get_ports {alu_y[0]}]
set_property -dict {PACKAGE_PIN V3  IOSTANDARD LVCMOS33} [get_ports {alu_y[1]}]
set_property -dict {PACKAGE_PIN W3  IOSTANDARD LVCMOS33} [get_ports {alu_y[2]}]
set_property -dict {PACKAGE_PIN U3  IOSTANDARD LVCMOS33} [get_ports {alu_y[3]}]
set_property -dict {PACKAGE_PIN P1  IOSTANDARD LVCMOS33} [get_ports {pc_addr[0]}]
set_property -dict {PACKAGE_PIN L1  IOSTANDARD LVCMOS33} [get_ports {pc_addr[1]}]

set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO      [current_design]
