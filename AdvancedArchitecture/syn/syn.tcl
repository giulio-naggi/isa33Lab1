analyze -f vhdl -library WORK ../src/register.vhd
analyze -f vhdl -library WORK ../src/reg_bit.vhd
analyze -f vhdl -library WORK ../src/adder.vhd
analyze -f vhdl -library WORK ../src/multiplier.vhd
analyze -f vhdl -library WORK ../src/adder.vhd
analyze -f vhdl -library WORK ../src/FIR.vhd
set period 9.2
set power_preserve_rtl_hier_names true
elaborate FIR -architecture MIXED -library WORK
create_clock -name "CLK" -period $period CLK
set_max_delay -from [all_inputs] -to [all_outputs] $period
set_dont_touch_network CLK
set_clock_uncertainty 0.07 [get_clocks CLK]
set_input_delay 0.5 -max -clock CLK [remove_from_collection [all_inputs] CLK]
set_output_delay 0.5 -max -clock CLK [all_outputs]
set OLOAD [load_of NangateOpenCellLibrary/BUF_X4/A]
set_load $OLOAD [all_outputs]
compile
report_timing > FIR_adv_timingx4.txt
report_area > FIR_adv_areax4.txt
ungroup -all -flatten
change_names -hierarchy -rules verilog
write_sdf ../netlist/FIR.sdf
write -f verilog -hierarchy -output ../netlist/FIR.v
write_sdc ../netlist/FIR.sdc
