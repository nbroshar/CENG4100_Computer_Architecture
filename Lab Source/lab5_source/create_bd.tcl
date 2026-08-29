# FALLBACK: build the CPU block design from Tcl (run after adding all 7 modules).
create_bd_design "cpu"
create_bd_cell -type module -reference slowtick u_tick
create_bd_cell -type module -reference pc       u_pc
create_bd_cell -type module -reference imem     u_im
create_bd_cell -type module -reference decoder  u_dec
create_bd_cell -type module -reference regfile4 u_rf
create_bd_cell -type module -reference alu      u_alu
create_bd_cell -type module -reference wbmux    u_wb
create_bd_port -dir I clk
create_bd_port -dir I rst
create_bd_port -dir O -from 3 -to 0 wdata
create_bd_port -dir O -from 3 -to 0 alu_y
create_bd_port -dir O -from 1 -to 0 pc_addr
# clock to everything sequential
connect_bd_net [get_bd_ports clk] [get_bd_pins u_tick/clk] [get_bd_pins u_pc/clk] [get_bd_pins u_rf/clk]
connect_bd_net [get_bd_ports rst] [get_bd_pins u_pc/rst]
# FETCH: tick advances pc; pc addresses imem
connect_bd_net [get_bd_pins u_tick/tick] [get_bd_pins u_pc/tick]
connect_bd_net [get_bd_pins u_pc/addr]   [get_bd_pins u_im/addr] [get_bd_ports pc_addr]
# DECODE: instruction -> control signals
connect_bd_net [get_bd_pins u_im/instr]  [get_bd_pins u_dec/instr]
connect_bd_net [get_bd_pins u_dec/rd]    [get_bd_pins u_rf/waddr]
connect_bd_net [get_bd_pins u_dec/rs1]   [get_bd_pins u_rf/raddr1]
connect_bd_net [get_bd_pins u_dec/rs2]   [get_bd_pins u_rf/raddr2]
connect_bd_net [get_bd_pins u_dec/we]    [get_bd_pins u_rf/we]
connect_bd_net [get_bd_pins u_dec/alu_op][get_bd_pins u_alu/alu_op]
connect_bd_net [get_bd_pins u_dec/imm]   [get_bd_pins u_wb/imm]
connect_bd_net [get_bd_pins u_dec/wbsel] [get_bd_pins u_wb/sel]
# EXECUTE + WRITEBACK
connect_bd_net [get_bd_pins u_rf/rdata1] [get_bd_pins u_alu/a]
connect_bd_net [get_bd_pins u_rf/rdata2] [get_bd_pins u_alu/b]
connect_bd_net [get_bd_pins u_alu/y]     [get_bd_pins u_wb/alu_y] [get_bd_ports alu_y]
connect_bd_net [get_bd_pins u_wb/wdata]  [get_bd_pins u_rf/wdata] [get_bd_ports wdata]
validate_bd_design
save_bd_design
make_wrapper -files [get_files cpu.bd] -top
puts "CPU block design built. Create/refresh the HDL wrapper, add cpu.xdc, build."
