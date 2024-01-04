#Step1: Set library paths
rm designs/*
set_attr init_lib_search_path ../lib/
set_attr init_hdl_search_path ../rtl_omkar/sigmoid_rtl/
set_attr library slow_vdd1v0_basicCells.lib
set_attribute hdl_parameter_naming_style _%s%d
#To check DRC
set_attribute drc_first true

#To set attributes
set_attribute optimize_constant_0_flops false
set_attribute delete_unloaded_insts false
set_attribute optimize_merge_flops false
set_attribute optimize_merge_latches false
set_attribute auto_ungroup none


#Step 2: Read netlist
read_hdl sig_4_hw.v



#Step 3: Elaborate/connect all modules //elaborate <design>
elaborate sig_4_hw

#check for unresolved references
check_design -unresolved   > ../tanhx_report/reports/area_opt/design_check.txt 


#set_top_module counter
#Step 4: Read constraints
read_sdc ../constraints/constraints_top.sdc


###################################################################################
## Define cost groups (clock-clock only. We can also define clock-output, input-clock, input-output)


  define_cost_group -name I2C -design sig_4_hw
  define_cost_group -name C2O -design sig_4_hw
  define_cost_group -name C2C -design sig_4_hw
  path_group -from [all::all_seqs] -to [all::all_seqs] -group C2C -name C2C 
  path_group -from [all::all_seqs] -to [all::all_outs] -group C2O -name C2O
  path_group -from [all::all_inps]  -to [all::all_seqs] -group I2C -name I2C


define_cost_group -name I2O -design sig_4_hw
path_group -from [all::all_inps]  -to [all::all_outs] -group I2O -name I2O
foreach cg [find / -cost_group *] {
  report timing -cost_group [list $cg] >> ../tanhx_report/reports/area_opt/sig_4_hw_all_pretim.rpt
}

#Step 4: Synthesise the  design to generic gates and set the effort level
set_attr syn_generic_effort medium
syn_generic

#write_snapshot -outdir ./reports/area_opt -tag generic
#report datapath > ./reports/area_opt/sig_4_hw_datapath.rpt
#report_summary -outdir ./reports/area_opt/report_generic



#syn_map: Maps  the  design  to  the  cells  described in the supplied technology library and performs logic optimization.
syn_map

#Step 5: Report results before optimisation

#suspend

#Step 6: Optimise and run synthesis- key step
#Performs  gate  level  optimization to improve timing on critical paths
#set_attr syn_opt_effort high

#syn_opt -incr

#This command prints out all paths 
write_snapshot -outdir ./reports/area_opt -tag syn_opt_no_incr
report_summary -outdir ./reports/area_opt/report_opt

#Report design rules
report_design_rules > ./reports/area_opt/des-Rules.rpt

foreach cg [find / -cost_group *] {
  report timing -cost_group [list $cg] >> ../tanhx_report/reports/area_opt/sig_4_hw_post_opt.rpt
}

#suspend

#Step 9: Write out synthesised netlist and constraints- important output
write_hdl > ../tanhx_report/reports/area_opt/hdl_synthesis.v
write_sdc > ../tanhx_report/reports/area_opt/sig_4_hw_sdc.sdc  

report_area > ../tanhx_report/reports/area_opt/area.txt
report_power > ../tanhx_report/reports/area_opt/power.txt
report_timing -gtd -num_paths 100 > ../tanhx_report/reports/area_opt/timing.gtd
#gui_show


#suspend
#write_template -simple -outfile simple_template.txt
#write_template -power -outfile template_power.tcl
#write_template -area -outfile template_area.tcl
#write_template -full -outfile template_full.tcl
#write_template -retime -outfile template_retime.tcl

#exit genus
#quit