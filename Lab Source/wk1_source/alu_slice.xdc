## ============================================================================
##  alu_slice.xdc  --  Basys 3 pins for the IP Integrator ALU-slice lab.
##  External block-design ports:  a[3:0], b[3:0], sel, y[3:0]
##    a[3:0] -> switches SW0..SW3      b[3:0] -> switches SW4..SW7
##    sel    -> switch  SW15           y[3:0] -> LEDs  LD0..LD3
## ============================================================================

## a[3:0] = SW0..SW3
set_property -dict {PACKAGE_PIN V17 IOSTANDARD LVCMOS33} [get_ports {a[0]}]
set_property -dict {PACKAGE_PIN V16 IOSTANDARD LVCMOS33} [get_ports {a[1]}]
set_property -dict {PACKAGE_PIN W16 IOSTANDARD LVCMOS33} [get_ports {a[2]}]
set_property -dict {PACKAGE_PIN W17 IOSTANDARD LVCMOS33} [get_ports {a[3]}]

## b[3:0] = SW4..SW7
set_property -dict {PACKAGE_PIN W15 IOSTANDARD LVCMOS33} [get_ports {b[0]}]
set_property -dict {PACKAGE_PIN V15 IOSTANDARD LVCMOS33} [get_ports {b[1]}]
set_property -dict {PACKAGE_PIN W14 IOSTANDARD LVCMOS33} [get_ports {b[2]}]
set_property -dict {PACKAGE_PIN W13 IOSTANDARD LVCMOS33} [get_ports {b[3]}]

## sel = SW15
set_property -dict {PACKAGE_PIN R2  IOSTANDARD LVCMOS33} [get_ports sel]

## y[3:0] = LD0..LD3
set_property -dict {PACKAGE_PIN U16 IOSTANDARD LVCMOS33} [get_ports {y[0]}]
set_property -dict {PACKAGE_PIN E19 IOSTANDARD LVCMOS33} [get_ports {y[1]}]
set_property -dict {PACKAGE_PIN U19 IOSTANDARD LVCMOS33} [get_ports {y[2]}]
set_property -dict {PACKAGE_PIN V19 IOSTANDARD LVCMOS33} [get_ports {y[3]}]

## silence the CFGBVS/CONFIG_VOLTAGE DRC
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO      [current_design]
