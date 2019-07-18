echo "********** CS552 Reading files begin ********************"
set my_verilog_files [list alu_old.v alu.v barrelShifter.v branch_deci.v branch_forwarding.v cache_control.v cache.v cla_16b.v cla_4b.v control.v dff.v EXMEM_ff.v ff_16b.v final_memory.syn.v forwarding_unit.v four_bank_mem.v fullAdder_1b.v hazard_detect.v IDEX_ff.v IFID_ff.v memc.syn.v mem_system.v memv.syn.v MEMWB_ff.v nand2.v nand3.v nor2.v nor3.v not1.v oneReg.v proc.v rf_bypass.v rf.v xor2.v xor3.v  ]
set my_toplevel proc
define_design_lib WORK -path ./WORK
analyze -f verilog $my_verilog_files
elaborate $my_toplevel -architecture verilog
echo "********** CS552 Reading files end ********************"
echo "********** CS552 Linking all modules begin ********************"
link
echo "********** CS552 Linking all modules end **********************"
echo "********** CS552 Checking design of all modules begin**********"
check_design -summary
echo "********** CS552 Checking design of all modules end************"
report_hierarchy > synth/hierarchy.txt
set filename [format "%s%s"  $my_toplevel ".syn.v"]
write -f verilog $my_toplevel -output synth/$filename -hierarchy
quit
