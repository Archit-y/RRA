# 1. Set up the library
vlib work

# 2. Compile the design and testbench
#    The '-sv' flag enables SystemVerilog features.
vlog -sv ../rtl/arbiter.sv
vlog -sv ../tb/top_tb.sv

# 3. Load the simulation
#    Selects the 'top_tb' module as the top level.
vsim work.top_tb

# 4. Add all signals to the wave window
add wave -r /*

# 5. Run the simulation until it finishes
run -all

# 6. Adjust the waveform view
wave zoom full

echo "Simulation complete."