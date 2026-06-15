# Local RTL simulation of the Tiny Tapeout project.
#
# This is a simplified, RTL-only Makefile for running the cocotb test locally.
# The official ttsky-verilog-template ships a richer test/Makefile that also
# supports gate-level simulation (GATES=yes); keep that one when you clone the
# template, and just point PROJECT_SOURCES at these files.
SIM           ?= icarus
TOPLEVEL_LANG ?= verilog

# Keep PROJECT_SOURCES in sync with source_files in ../info.yaml
PROJECT_SOURCES  = project.v rv32i.v tt_rom.v
VERILOG_SOURCES += $(addprefix $(PWD)/../src/,$(PROJECT_SOURCES))
VERILOG_SOURCES += $(PWD)/tb.v

TOPLEVEL = tb
MODULE   = test

include $(shell cocotb-config --makefiles)/Makefile.sim
