# Stage3_Basys3.xdc - Complete constraints with all ports defined

# Clock signal (100MHz on Basys3)
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]

# Reset button/switch 
set_property PACKAGE_PIN V17 [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports rst]

# Game control switches
set_property PACKAGE_PIN V16 [get_ports sw0]
set_property IOSTANDARD LVCMOS33 [get_ports sw0]

set_property PACKAGE_PIN R2 [get_ports sw15]
set_property IOSTANDARD LVCMOS33 [get_ports sw15]

# Direction buttons
set_property PACKAGE_PIN T18 [get_ports btnU]
set_property IOSTANDARD LVCMOS33 [get_ports btnU]

set_property PACKAGE_PIN U17 [get_ports btnD]
set_property IOSTANDARD LVCMOS33 [get_ports btnD]

set_property PACKAGE_PIN W19 [get_ports btnL]
set_property IOSTANDARD LVCMOS33 [get_ports btnL]

set_property PACKAGE_PIN T17 [get_ports btnR]
set_property IOSTANDARD LVCMOS33 [get_ports btnR]

# Center button - ensure exact name match
set_property PACKAGE_PIN U18 [get_ports btnC]
set_property IOSTANDARD LVCMOS33 [get_ports btnC]

# VGA Red channel
set_property PACKAGE_PIN G19 [get_ports {vgaRed[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vgaRed[0]}]
set_property PACKAGE_PIN H19 [get_ports {vgaRed[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vgaRed[1]}]
set_property PACKAGE_PIN J19 [get_ports {vgaRed[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vgaRed[2]}]
set_property PACKAGE_PIN N19 [get_ports {vgaRed[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vgaRed[3]}]

# VGA Green channel
set_property PACKAGE_PIN J17 [get_ports {vgaGreen[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vgaGreen[0]}]
set_property PACKAGE_PIN H17 [get_ports {vgaGreen[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vgaGreen[1]}]
set_property PACKAGE_PIN G17 [get_ports {vgaGreen[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vgaGreen[2]}]
set_property PACKAGE_PIN D17 [get_ports {vgaGreen[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vgaGreen[3]}]

# VGA Blue channel
set_property PACKAGE_PIN N18 [get_ports {vgaBlue[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vgaBlue[0]}]
set_property PACKAGE_PIN L18 [get_ports {vgaBlue[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vgaBlue[1]}]
set_property PACKAGE_PIN K18 [get_ports {vgaBlue[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vgaBlue[2]}]
set_property PACKAGE_PIN J18 [get_ports {vgaBlue[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vgaBlue[3]}]

# VGA Sync signals
set_property PACKAGE_PIN P19 [get_ports hSync]
set_property IOSTANDARD LVCMOS33 [get_ports hSync]

set_property PACKAGE_PIN R19 [get_ports vSync]
set_property IOSTANDARD LVCMOS33 [get_ports vSync]

# Timing constraints
# Create derived clock for VGA pixel clock
create_generated_clock -name vga_clk -source [get_ports clk] -divide_by 4 [get_pins -hier -filter {NAME =~ */pixelClk*}]

# Input delay constraints
set_input_delay -clock [get_clocks sys_clk_pin] -min 0 [all_inputs]
set_input_delay -clock [get_clocks sys_clk_pin] -max 2 [all_inputs]

# Output delay constraints for VGA signals
set_output_delay -clock [get_clocks vga_clk] -min -1 [get_ports {vgaRed* vgaGreen* vgaBlue* hSync vSync}]
set_output_delay -clock [get_clocks vga_clk] -max 1 [get_ports {vgaRed* vgaGreen* vgaBlue* hSync vSync}]

# False paths for asynchronous signals
set_false_path -from [get_ports rst] -to [all_clocks]
set_false_path -from [get_ports {btnU btnD btnL btnR btnC sw0 sw15}] -to [all_clocks]

# Set max delay for combinatorial logic
set_max_delay -from [get_clocks sys_clk_pin] -to [get_clocks vga_clk] 5.0
set_max_delay -from [get_clocks vga_clk] -to [get_clocks sys_clk_pin] 5.0

# Configuration properties
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

# Bitstream settings
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]