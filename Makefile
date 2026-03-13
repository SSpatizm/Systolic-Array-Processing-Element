# ============================================
# Makefile for PE testbench (Icarus Verilog)
# ============================================

# Tools
IVERILOG = iverilog
VVP      = vvp

# Directories
SRC_DIR  = src
TEST_DIR = tests
BUILD_DIR = build

# Files
SRC_FILES = $(wildcard src/*.v)
TB_FILES  = tests/tb_systolic_array_4x4.v

# Output executable
OUT = $(BUILD_DIR)/pe_tb.out

# Default target
all: run

# Create build directory if it doesn't exist
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Compile
$(OUT): $(SRC_FILES) $(TB_FILES) | $(BUILD_DIR)
	$(IVERILOG) -g2012 -o $(OUT) $(SRC_FILES) $(TB_FILES)

# Run simulation
run: $(OUT)
	$(VVP) $(OUT)

# Optional waveform view (requires GTKWave)
wave: run
	gtkwave dump.vcd

# Clean build artifacts
clean:
	rm -rf $(BUILD_DIR) *.vcd

.PHONY: all run clean wave