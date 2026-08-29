# ============================================================================
#  create_bd.tcl  --  FALLBACK: build the ALU block design from Tcl.
#  Run from the Vivado Tcl Console AFTER the five shells are added as sources.
#  (Validate on your machine before class -- BD Tcl can vary by version.)
# ============================================================================
create_bd_design "alu"

create_bd_cell -type module -reference op_add u_add
create_bd_cell -type module -reference op_sub u_sub
create_bd_cell -type module -reference op_and u_and
create_bd_cell -type module -reference op_or  u_or
create_bd_cell -type module -reference alu_mux u_mux

create_bd_port -dir I -from 3 -to 0 a
create_bd_port -dir I -from 3 -to 0 b
create_bd_port -dir I -from 1 -to 0 alu_op
create_bd_port -dir O -from 3 -to 0 y

# a and b fan out to ALL FOUR operation blocks (parallel compute)
connect_bd_net [get_bd_ports a] [get_bd_pins u_add/a] [get_bd_pins u_sub/a] \
                                 [get_bd_pins u_and/a] [get_bd_pins u_or/a]
connect_bd_net [get_bd_ports b] [get_bd_pins u_add/b] [get_bd_pins u_sub/b] \
                                 [get_bd_pins u_and/b] [get_bd_pins u_or/b]

# each operation result feeds one mux input (0=ADD 1=SUB 2=AND 3=OR)
connect_bd_net [get_bd_pins u_add/y] [get_bd_pins u_mux/in0]
connect_bd_net [get_bd_pins u_sub/y] [get_bd_pins u_mux/in1]
connect_bd_net [get_bd_pins u_and/y] [get_bd_pins u_mux/in2]
connect_bd_net [get_bd_pins u_or/y]  [get_bd_pins u_mux/in3]

# opcode selects; mux output to LEDs
connect_bd_net [get_bd_ports alu_op] [get_bd_pins u_mux/sel]
connect_bd_net [get_bd_pins u_mux/y] [get_bd_ports y]

validate_bd_design
save_bd_design
make_wrapper -files [get_files alu.bd] -top
puts "ALU block design built. Create/refresh the HDL wrapper, add alu.xdc, then build."
