# Create work library
vlib work

# Compile Verilog
#     All Verilog files that are part of this design should have
#     their own "vlog" line below.
vlog "piece_animation.sv"
vlog "up_counter.sv"
vlog "clock_divider.sv"
vlog "check_column.sv"
vlog "game_logic.sv"
vlog "DE1_SoC.sv"
vlog "LED_test.sv"
vlog "LEDDriver.sv"
vlog "userIn.sv"
vlog "user_input.sv"
vlog "dff2.sv"
vlog "hexes_display.sv"
vlog "find_win.sv"

# Call vsim to invoke simulator
#     Make sure the last item on the line is the name of the
#     testbench module you want to execute.
vsim -voptargs="+acc" -t 1ps -lib work piece_animation_testbench

# Source the wave do file
#     This should be the file that sets up the signal window for
#     the module you are testing.
do piece_animation_wave.do

# Set the window types
view wave
view structure
view signals

# Run the simulation
run -all

# End
