## Generated SDC file "stick.sdc"

## Copyright (C) 1991-2014 Altera Corporation
## Your use of Altera Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Altera Program License 
## Subscription Agreement, Altera MegaCore Function License 
## Agreement, or other applicable license agreement, including, 
## without limitation, that your use is for the sole purpose of 
## programming logic devices manufactured by Altera and sold by 
## Altera or its authorized distributors.  Please refer to the 
## applicable agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus II"
## VERSION "Version 13.1.4 Build 182 03/12/2014 SJ Web Edition"

## DATE    "Wed Nov 10 11:51:28 2021"

##
## DEVICE  "EP4CE55F23I7"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {clk} -period 40.000 -waveform { 0.000 20.000 } [get_ports {clk}]
create_clock -name {rxclk_1x} -period 1.000 -waveform { 0.000 0.500 } [get_ports {rxclk_1x}]
create_clock -name {txclk_1x} -period 1.000 -waveform { 0.000 0.500 } [get_ports {txclk_1x}]
create_clock -name {txclk_2x} -period 1.000 -waveform { 0.000 0.500 } [get_ports {txclk_2x}]
create_clock -name {rxclk_2x} -period 1.000 -waveform { 0.000 0.500 } [get_ports {rxclk_2x}]


#**************************************************************
# Create Generated Clock
#**************************************************************

create_generated_clock -name {main_pll_unit|altpll_component|auto_generated|pll1|clk[0]} -source [get_pins {main_pll_unit|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 4 -master_clock {clk} [get_pins {main_pll_unit|altpll_component|auto_generated|pll1|clk[0]}] 
create_generated_clock -name {main_pll_unit|altpll_component|auto_generated|pll1|clk[1]} -source [get_pins {main_pll_unit|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 8 -master_clock {clk} [get_pins {main_pll_unit|altpll_component|auto_generated|pll1|clk[1]}] 

#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

set_clock_uncertainty -rise_from [get_clocks {rxclk_2x}] -rise_to [get_clocks {rxclk_2x}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {rxclk_2x}] -fall_to [get_clocks {rxclk_2x}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {rxclk_2x}] -rise_to [get_clocks {rxclk_2x}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {rxclk_2x}] -fall_to [get_clocks {rxclk_2x}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {txclk_2x}] -rise_to [get_clocks {txclk_2x}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {txclk_2x}] -fall_to [get_clocks {txclk_2x}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {txclk_2x}] -rise_to [get_clocks {txclk_2x}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {txclk_2x}] -fall_to [get_clocks {txclk_2x}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {rxclk_1x}] -rise_to [get_clocks {rxclk_1x}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {rxclk_1x}] -fall_to [get_clocks {rxclk_1x}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {rxclk_1x}] -rise_to [get_clocks {rxclk_1x}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {rxclk_1x}] -fall_to [get_clocks {rxclk_1x}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {txclk_1x}] -rise_to [get_clocks {txclk_1x}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {txclk_1x}] -fall_to [get_clocks {txclk_1x}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {txclk_1x}] -rise_to [get_clocks {txclk_1x}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {txclk_1x}] -fall_to [get_clocks {txclk_1x}]  0.020  


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

set_false_path -to [get_keepers {*altera_std_synchronizer:*|din_s1}]
set_false_path -to [get_registers {*altera_tse_a_fifo_34:*|wr_g_rptr*}]
set_false_path -from [get_registers {*|altera_tse_register_map_small:U_REG|command_config[9]}] -to [get_registers {*|altera_tse_mac_tx:U_TX|*}]
set_false_path -from [get_registers {*|altera_tse_register_map_small:U_REG|mac_0[*]}] -to [get_registers {*|altera_tse_mac_tx:U_TX|*}]
set_false_path -from [get_registers {*|altera_tse_register_map_small:U_REG|mac_1[*]}] -to [get_registers {*|altera_tse_mac_tx:U_TX|*}]
set_false_path -from [get_registers {*|altera_tse_register_map_small:U_REG|mac_0[*]}] -to [get_registers {*|altera_tse_mac_rx:U_RX|*}]
set_false_path -from [get_registers {*|altera_tse_register_map_small:U_REG|mac_1[*]}] -to [get_registers {*|altera_tse_mac_rx:U_RX|*}]
set_false_path -to [get_pins -nocase -compatibility_mode {*|altera_tse_reset_synchronizer:*|altera_tse_reset_synchronizer_chain*|clrn}]


#**************************************************************
# Set Multicycle Path
#**************************************************************

set_multicycle_path -setup -end -from [get_registers {*|altera_tse_top_w_fifo:U_MAC|altera_tse_tx_min_ff:U_TXFF|altera_tse_altsyncram_dpm_fifo:U_RTSM|altsyncram*}] -to [get_registers *] 5
set_multicycle_path -setup -end -from [get_registers {*|altera_tse_top_w_fifo:U_MAC|altera_tse_tx_min_ff:U_TXFF|altera_tse_retransmit_cntl:U_RETR|*}] -to [get_registers *] 5
set_multicycle_path -setup -end -from [get_registers *] -to [get_registers {*|altera_tse_top_w_fifo:U_MAC|altera_tse_tx_min_ff:U_TXFF|altera_tse_retransmit_cntl:U_RETR|*}] 5
set_multicycle_path -hold -end -from [get_registers {*|altera_tse_top_w_fifo:U_MAC|altera_tse_tx_min_ff:U_TXFF|altera_tse_altsyncram_dpm_fifo:U_RTSM|altsyncram*}] -to [get_registers *] 5
set_multicycle_path -hold -end -from [get_registers {*|altera_tse_top_w_fifo:U_MAC|altera_tse_tx_min_ff:U_TXFF|altera_tse_retransmit_cntl:U_RETR|*}] -to [get_registers *] 5
set_multicycle_path -hold -end -from [get_registers *] -to [get_registers {*|altera_tse_top_w_fifo:U_MAC|altera_tse_tx_min_ff:U_TXFF|altera_tse_retransmit_cntl:U_RETR|*}] 5


#**************************************************************
# Set Maximum Delay
#**************************************************************

set_max_delay -from [get_registers {*|altera_tse_top_w_fifo:U_MAC|altera_tse_tx_min_ff:U_TXFF|dout_reg_sft*}] -to [get_registers {*|altera_tse_top_w_fifo:U_MAC|altera_tse_top_1geth:U_GETH|altera_tse_mac_tx:U_TX|*}] 7.000
set_max_delay -from [get_registers {*|altera_tse_top_w_fifo:U_MAC|altera_tse_tx_min_ff:U_TXFF|eop_sft*}] -to [get_registers {*|altera_tse_top_w_fifo:U_MAC|altera_tse_top_1geth:U_GETH|altera_tse_mac_tx:U_TX|*}] 7.000
set_max_delay -from [get_registers {*|altera_tse_top_w_fifo:U_MAC|altera_tse_tx_min_ff:U_TXFF|sop_reg*}] -to [get_registers {*|altera_tse_top_w_fifo:U_MAC|altera_tse_top_1geth:U_GETH|altera_tse_mac_tx:U_TX|*}] 7.000


#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

