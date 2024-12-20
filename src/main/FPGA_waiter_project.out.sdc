## Generated SDC file "FPGA_waiter_project.out.sdc"

## Copyright (C) 2020  Intel Corporation. All rights reserved.
## Your use of Intel Corporation's design tools, logic functions 
## and other software and tools, and any partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Intel Program License 
## Subscription Agreement, the Intel Quartus Prime License Agreement,
## the Intel FPGA IP License Agreement, or other applicable license
## agreement, including, without limitation, that your use is for
## the sole purpose of programming logic devices manufactured by
## Intel and sold by Intel or its authorized distributors.  Please
## refer to the applicable agreement for further details, at
## https://fpgasoftware.intel.com/eula.


## VENDOR  "Altera"
## PROGRAM "Quartus Prime"
## VERSION "Version 20.1.0 Build 711 06/05/2020 SJ Lite Edition"

## DATE    "Fri Nov 01 17:16:40 2024"

##
## DEVICE  "EP4CE115F29C7"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {CLOCK_50} -period 20.000 -waveform { 0.000 10.000 } [get_ports {CLOCK_50}]
create_clock -name {GPIO[21]} -period 20.000 -waveform { 0.000 10.000 } [get_ports { GPIO[21] }]
create_clock -name {AUD_BCLK} -period 54.300 -waveform { 0.000 27.150 } [get_ports { AUD_BCLK }]


#**************************************************************
# Create Generated Clock
#**************************************************************

create_generated_clock -name {cgt0|Inst_vga_pll|altpll_component|auto_generated|pll1|clk[0]} -source [get_pins {cgt0|Inst_vga_pll|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50/1 -multiply_by 1 -master_clock {CLOCK_50} [get_pins {cgt0|Inst_vga_pll|altpll_component|auto_generated|pll1|clk[0]}] 
create_generated_clock -name {cgt0|Inst_vga_pll|altpll_component|auto_generated|pll1|clk[1]} -source [get_pins {cgt0|Inst_vga_pll|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50/1 -multiply_by 1 -divide_by 2 -master_clock {CLOCK_50} [get_pins {cgt0|Inst_vga_pll|altpll_component|auto_generated|pll1|clk[1]}] 
create_generated_clock -name {FFT_TL|adc_pll_u|altpll_component|auto_generated|pll1|clk[0]} -source [get_pins {FFT_TL|adc_pll_u|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50/1 -multiply_by 80 -divide_by 217 -master_clock {CLOCK_50} [get_pins {FFT_TL|adc_pll_u|altpll_component|auto_generated|pll1|clk[0]}] 
create_generated_clock -name {FFT_TL|i2c_pll_u|altpll_component|auto_generated|pll1|clk[0]} -source [get_pins {FFT_TL|i2c_pll_u|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50/1 -multiply_by 1 -divide_by 2500 -master_clock {CLOCK_50} [get_pins {FFT_TL|i2c_pll_u|altpll_component|auto_generated|pll1|clk[0]}] 


#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

set_clock_uncertainty -rise_from [get_clocks {AUD_BCLK}] -rise_to [get_clocks {FFT_TL|adc_pll_u|altpll_component|auto_generated|pll1|clk[0]}] -setup 0.070  
set_clock_uncertainty -rise_from [get_clocks {AUD_BCLK}] -rise_to [get_clocks {FFT_TL|adc_pll_u|altpll_component|auto_generated|pll1|clk[0]}] -hold 0.100  
set_clock_uncertainty -rise_from [get_clocks {AUD_BCLK}] -fall_to [get_clocks {FFT_TL|adc_pll_u|altpll_component|auto_generated|pll1|clk[0]}] -setup 0.070  
set_clock_uncertainty -rise_from [get_clocks {AUD_BCLK}] -fall_to [get_clocks {FFT_TL|adc_pll_u|altpll_component|auto_generated|pll1|clk[0]}] -hold 0.100  
set_clock_uncertainty -fall_from [get_clocks {AUD_BCLK}] -rise_to [get_clocks {FFT_TL|adc_pll_u|altpll_component|auto_generated|pll1|clk[0]}] -setup 0.070  
set_clock_uncertainty -fall_from [get_clocks {AUD_BCLK}] -rise_to [get_clocks {FFT_TL|adc_pll_u|altpll_component|auto_generated|pll1|clk[0]}] -hold 0.100  
set_clock_uncertainty -fall_from [get_clocks {AUD_BCLK}] -fall_to [get_clocks {FFT_TL|adc_pll_u|altpll_component|auto_generated|pll1|clk[0]}] -setup 0.070  
set_clock_uncertainty -fall_from [get_clocks {AUD_BCLK}] -fall_to [get_clocks {FFT_TL|adc_pll_u|altpll_component|auto_generated|pll1|clk[0]}] -hold 0.100  
set_clock_uncertainty -rise_from [get_clocks {FFT_TL|i2c_pll_u|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {FFT_TL|i2c_pll_u|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {FFT_TL|i2c_pll_u|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {FFT_TL|i2c_pll_u|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {FFT_TL|i2c_pll_u|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {FFT_TL|i2c_pll_u|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {FFT_TL|i2c_pll_u|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {FFT_TL|i2c_pll_u|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {FFT_TL|adc_pll_u|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {AUD_BCLK}] -setup 0.100  
set_clock_uncertainty -rise_from [get_clocks {FFT_TL|adc_pll_u|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {AUD_BCLK}] -hold 0.070  
set_clock_uncertainty -rise_from [get_clocks {FFT_TL|adc_pll_u|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {AUD_BCLK}] -setup 0.100  
set_clock_uncertainty -rise_from [get_clocks {FFT_TL|adc_pll_u|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {AUD_BCLK}] -hold 0.070  
set_clock_uncertainty -rise_from [get_clocks {FFT_TL|adc_pll_u|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {FFT_TL|adc_pll_u|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {FFT_TL|adc_pll_u|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {FFT_TL|adc_pll_u|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {FFT_TL|adc_pll_u|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {CLOCK_50}] -setup 0.090  
set_clock_uncertainty -rise_from [get_clocks {FFT_TL|adc_pll_u|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {CLOCK_50}] -hold 0.070  
set_clock_uncertainty -rise_from [get_clocks {FFT_TL|adc_pll_u|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {CLOCK_50}] -setup 0.090  
set_clock_uncertainty -rise_from [get_clocks {FFT_TL|adc_pll_u|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {CLOCK_50}] -hold 0.070  
set_clock_uncertainty -fall_from [get_clocks {FFT_TL|adc_pll_u|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {AUD_BCLK}] -setup 0.100  
set_clock_uncertainty -fall_from [get_clocks {FFT_TL|adc_pll_u|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {AUD_BCLK}] -hold 0.070  
set_clock_uncertainty -fall_from [get_clocks {FFT_TL|adc_pll_u|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {AUD_BCLK}] -setup 0.100  
set_clock_uncertainty -fall_from [get_clocks {FFT_TL|adc_pll_u|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {AUD_BCLK}] -hold 0.070  
set_clock_uncertainty -fall_from [get_clocks {FFT_TL|adc_pll_u|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {FFT_TL|adc_pll_u|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {FFT_TL|adc_pll_u|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {FFT_TL|adc_pll_u|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {FFT_TL|adc_pll_u|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {CLOCK_50}] -setup 0.090  
set_clock_uncertainty -fall_from [get_clocks {FFT_TL|adc_pll_u|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {CLOCK_50}] -hold 0.070  
set_clock_uncertainty -fall_from [get_clocks {FFT_TL|adc_pll_u|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {CLOCK_50}] -setup 0.090  
set_clock_uncertainty -fall_from [get_clocks {FFT_TL|adc_pll_u|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {CLOCK_50}] -hold 0.070  
set_clock_uncertainty -rise_from [get_clocks {cgt0|Inst_vga_pll|altpll_component|auto_generated|pll1|clk[1]}] -rise_to [get_clocks {cgt0|Inst_vga_pll|altpll_component|auto_generated|pll1|clk[1]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {cgt0|Inst_vga_pll|altpll_component|auto_generated|pll1|clk[1]}] -fall_to [get_clocks {cgt0|Inst_vga_pll|altpll_component|auto_generated|pll1|clk[1]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {cgt0|Inst_vga_pll|altpll_component|auto_generated|pll1|clk[1]}] -rise_to [get_clocks {CLOCK_50}] -setup 0.100  
set_clock_uncertainty -rise_from [get_clocks {cgt0|Inst_vga_pll|altpll_component|auto_generated|pll1|clk[1]}] -rise_to [get_clocks {CLOCK_50}] -hold 0.070  
set_clock_uncertainty -rise_from [get_clocks {cgt0|Inst_vga_pll|altpll_component|auto_generated|pll1|clk[1]}] -fall_to [get_clocks {CLOCK_50}] -setup 0.100  
set_clock_uncertainty -rise_from [get_clocks {cgt0|Inst_vga_pll|altpll_component|auto_generated|pll1|clk[1]}] -fall_to [get_clocks {CLOCK_50}] -hold 0.070  
set_clock_uncertainty -fall_from [get_clocks {cgt0|Inst_vga_pll|altpll_component|auto_generated|pll1|clk[1]}] -rise_to [get_clocks {cgt0|Inst_vga_pll|altpll_component|auto_generated|pll1|clk[1]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {cgt0|Inst_vga_pll|altpll_component|auto_generated|pll1|clk[1]}] -fall_to [get_clocks {cgt0|Inst_vga_pll|altpll_component|auto_generated|pll1|clk[1]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {cgt0|Inst_vga_pll|altpll_component|auto_generated|pll1|clk[1]}] -rise_to [get_clocks {CLOCK_50}] -setup 0.100  
set_clock_uncertainty -fall_from [get_clocks {cgt0|Inst_vga_pll|altpll_component|auto_generated|pll1|clk[1]}] -rise_to [get_clocks {CLOCK_50}] -hold 0.070  
set_clock_uncertainty -fall_from [get_clocks {cgt0|Inst_vga_pll|altpll_component|auto_generated|pll1|clk[1]}] -fall_to [get_clocks {CLOCK_50}] -setup 0.100  
set_clock_uncertainty -fall_from [get_clocks {cgt0|Inst_vga_pll|altpll_component|auto_generated|pll1|clk[1]}] -fall_to [get_clocks {CLOCK_50}] -hold 0.070  
set_clock_uncertainty -rise_from [get_clocks {cgt0|Inst_vga_pll|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {cgt0|Inst_vga_pll|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {cgt0|Inst_vga_pll|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {cgt0|Inst_vga_pll|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {cgt0|Inst_vga_pll|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {cgt0|Inst_vga_pll|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {cgt0|Inst_vga_pll|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {cgt0|Inst_vga_pll|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {CLOCK_50}] -rise_to [get_clocks {GPIO[21]}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {CLOCK_50}] -fall_to [get_clocks {GPIO[21]}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {CLOCK_50}] -rise_to [get_clocks {CLOCK_50}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {CLOCK_50}] -fall_to [get_clocks {CLOCK_50}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {CLOCK_50}] -rise_to [get_clocks {GPIO[21]}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {CLOCK_50}] -fall_to [get_clocks {GPIO[21]}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {CLOCK_50}] -rise_to [get_clocks {CLOCK_50}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {CLOCK_50}] -fall_to [get_clocks {CLOCK_50}]  0.020  


#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************

set_false_path -from [get_keepers {*rdptr_g*}] -to [get_keepers {*ws_dgrp|dffpipe_re9:dffpipe15|dffe16a*}]
set_false_path -from [get_keepers {*delayed_wrptr_g*}] -to [get_keepers {*rs_dgwp|dffpipe_qe9:dffpipe12|dffe13a*}]


#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

