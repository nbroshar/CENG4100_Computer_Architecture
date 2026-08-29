# FALLBACK: build the datapath BD from Tcl (run after adding the 3 shells + alu.v).
create_bd_design "datapath"
create_bd_cell -type module -reference regfile4 u_rf
create_bd_cell -type module -reference alu      u_alu
create_bd_cell -type module -reference wbmux    u_wb
create_bd_port -dir I clk
create_bd_port -dir I we
create_bd_port -dir I wbsel
create_bd_port -dir I -from 3 -to 0 imm
create_bd_port -dir I -from 1 -to 0 rs1
create_bd_port -dir I -from 1 -to 0 rs2
create_bd_port -dir I -from 1 -to 0 rd
create_bd_port -dir I -from 1 -to 0 alu_op
create_bd_port -dir O -from 3 -to 0 rdata1
create_bd_port -dir O -from 3 -to 0 rdata2
create_bd_port -dir O -from 3 -to 0 alu_y
connect_bd_net [get_bd_ports clk] [get_bd_pins u_rf/clk]
connect_bd_net [get_bd_ports we]  [get_bd_pins u_rf/we]
connect_bd_net [get_bd_ports rs1] [get_bd_pins u_rf/raddr1]
connect_bd_net [get_bd_ports rs2] [get_bd_pins u_rf/raddr2]
connect_bd_net [get_bd_ports rd]  [get_bd_pins u_rf/waddr]
# read ports drive the ALU operands AND the display LEDs
connect_bd_net [get_bd_pins u_rf/rdata1] [get_bd_pins u_alu/a] [get_bd_ports rdata1]
connect_bd_net [get_bd_pins u_rf/rdata2] [get_bd_pins u_alu/b] [get_bd_ports rdata2]
connect_bd_net [get_bd_ports alu_op] [get_bd_pins u_alu/alu_op]
# ALU result -> write-back mux AND display
connect_bd_net [get_bd_pins u_alu/y] [get_bd_pins u_wb/alu_y] [get_bd_ports alu_y]
connect_bd_net [get_bd_ports imm]   [get_bd_pins u_wb/imm]
connect_bd_net [get_bd_ports wbsel] [get_bd_pins u_wb/sel]
# write-back data -> register file write port
connect_bd_net [get_bd_pins u_wb/wdata] [get_bd_pins u_rf/wdata]
validate_bd_design
save_bd_design
make_wrapper -files [get_files datapath.bd] -top
puts "Datapath BD built. Create/refresh the HDL wrapper, add datapath.xdc, build."
