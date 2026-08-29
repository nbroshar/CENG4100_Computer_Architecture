# FALLBACK: build the register lab BD from Tcl (run after adding alu.v + reg4.v).
create_bd_design "regdemo"
create_bd_cell -type module -reference alu  u_alu
create_bd_cell -type module -reference reg4 u_reg
create_bd_port -dir I clk
create_bd_port -dir I en
create_bd_port -dir I -from 3 -to 0 a
create_bd_port -dir I -from 3 -to 0 b
create_bd_port -dir I -from 1 -to 0 alu_op
create_bd_port -dir O -from 3 -to 0 q
create_bd_port -dir O -from 3 -to 0 live
connect_bd_net [get_bd_ports a]      [get_bd_pins u_alu/a]
connect_bd_net [get_bd_ports b]      [get_bd_pins u_alu/b]
connect_bd_net [get_bd_ports alu_op] [get_bd_pins u_alu/alu_op]
# ALU output fans out to the LIVE LEDs and to the register's data input
connect_bd_net [get_bd_pins u_alu/y] [get_bd_ports live] [get_bd_pins u_reg/d]
connect_bd_net [get_bd_ports clk] [get_bd_pins u_reg/clk]
connect_bd_net [get_bd_ports en]  [get_bd_pins u_reg/en]
connect_bd_net [get_bd_pins u_reg/q] [get_bd_ports q]
validate_bd_design
save_bd_design
make_wrapper -files [get_files regdemo.bd] -top
puts "Register demo BD built. Create/refresh the HDL wrapper, add reg.xdc, build."
