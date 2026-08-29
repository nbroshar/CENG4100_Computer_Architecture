# ============================================================================
#  create_bd.tcl  --  FALLBACK: build the ALU-slice block design from Tcl.
#  Use this only if a student gets stuck wiring by hand. Run it from the
#  Vivado Tcl Console AFTER the three shells (op_and/op_or/mux2) are added to
#  the project as design sources. (Validate on your machine before class -- BD
#  Tcl can vary slightly by Vivado version.)
# ============================================================================
create_bd_design "alu_slice"

# place the three student modules as referenced blocks
create_bd_cell -type module -reference op_and u_and
create_bd_cell -type module -reference op_or  u_or
create_bd_cell -type module -reference mux2   u_mux

# external ports (these names must match alu_slice.xdc)
create_bd_port -dir I -from 3 -to 0 a
create_bd_port -dir I -from 3 -to 0 b
create_bd_port -dir I sel
create_bd_port -dir O -from 3 -to 0 y

# a and b fan out to BOTH operation blocks (the parallelism, made explicit)
connect_bd_net [get_bd_ports a] [get_bd_pins u_and/a] [get_bd_pins u_or/a]
connect_bd_net [get_bd_ports b] [get_bd_pins u_and/b] [get_bd_pins u_or/b]

# AND -> mux in0 (sel=0), OR -> mux in1 (sel=1)
connect_bd_net [get_bd_pins u_and/y] [get_bd_pins u_mux/in0]
connect_bd_net [get_bd_pins u_or/y]  [get_bd_pins u_mux/in1]
connect_bd_net [get_bd_ports sel]    [get_bd_pins u_mux/sel]
connect_bd_net [get_bd_pins u_mux/y] [get_bd_ports y]

validate_bd_design
save_bd_design

# generate the HDL wrapper and make it top
make_wrapper -files [get_files alu_slice.bd] -top
add_files -norecurse [file join [get_property DIRECTORY [current_project]] alu_slice_wrapper.v]
set_property top alu_slice_wrapper [current_fileset]
puts "alu_slice block design built. Open alu_slice_wrapper.v to see the structural Verilog."
