MODULE_DIR := $(shell pwd)

CPU_TOP = $(MODULE_DIR)/rtl/cpu_top.v
CORE = $(MODULE_DIR)/rtl/core.v
ALU = $(MODULE_DIR)/rtl/alu.v
REG_FILE = $(MODULE_DIR)/rtl/reg_file.v
CONTROL = $(MODULE_DIR)/rtl/control.v
SIGN_EXT = $(MODULE_DIR)/rtl/sign_ext.v
ROM = $(MODULE_DIR)/rtl/rom.v
RAM = $(MODULE_DIR)/rtl/ram.v

CPU_TB = $(MODULE_DIR)/tb/testbench.v
ALU_TB = $(MODULE_DIR)/tb/alu_tb.v
CONTROL_TB = $(MODULE_DIR)/tb/control_tb.v
REG_FILE_TB = $(MODULE_DIR)/tb/reg_file_tb.v

SRC = $(CPU_TB) + $(CPU_TOP) + $(CORE) + $(ALU) + $(REG_FILE) + $(CONTROL) + $(ROM) + $(RAM)
ALU_TEST = $(ALU_TB) + $(ALU)
CONTROL_TEST = $(CONTROL_TB) + $(CONTROL)
REG_FILE_TEST = $(REG_FILE_TB) + $(REG_FILE)

alu:
	cd $(MODULE_DIR)/sim && rm -rf alu && mkdir alu
	cd $(MODULE_DIR)/sim/alu && xrun -64bit -sv -access +rwc \
		-linedebug -timescale 1ns/10ps -gui $(ALU_TEST)

control:
	cd $(MODULE_DIR)/sim && rm -rf control && mkdir control
	cd $(MODULE_DIR)/sim/control && xrun -64bit -sv -access +rwc \
		-linedebug -timescale 1ns/10ps -gui $(CONTROL_TEST)

reg_file:
	cd $(MODULE_DIR)/sim && rm -rf reg_file && mkdir reg_file
	cd $(MODULE_DIR)/sim/reg_file && xrun -64bit -sv -access +rwc \
		-linedebug -timescale 1ns/10ps -gui $(REG_FILE_TEST)

cpu:
	cd $(MODULE_DIR)/sim && rm -rf cpu && mkdir cpu
	cd $(MODULE_DIR)/sim/cpu && xrun -64bit -sv -access +rwc \
		-linedebug -timescale 1ns/10ps $(SRC) > $(MODULE_DIR)/sim/cpu/cpu.log && vim $(MODULE_DIR)/sim/cpu/cpu.log

cpu_gui:
	cd $(MODULE_DIR)/sim && rm -rf cpu && mkdir cpu
	cd $(MODULE_DIR)/sim/cpu && xrun -64bit -sv -access +rwc \
		-linedebug -timescale 1ns/10ps -gui $(SRC) &

clean:
	cd $(MODULE_DIR)/sim && rm -rf ./*
