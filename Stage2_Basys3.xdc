# Clock signal (100MHz on Basys3)
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]

# Reset switch (SW[0])
set_property PACKAGE_PIN V17 [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports rst]

# Buttons
set_property PACKAGE_PIN T18 [get_ports btnU]
set_property IOSTANDARD LVCMOS33 [get_ports btnU]
set_property PACKAGE_PIN U17 [get_ports btnD]
set_property IOSTANDARD LVCMOS33 [get_ports btnD]
set_property PACKAGE_PIN W19 [get_ports btnL]
set_property IOSTANDARD LVCMOS33 [get_ports btnL]
set_property PACKAGE_PIN T17 [get_ports btnR]
set_property IOSTANDARD LVCMOS33 [get_ports btnR]
set_property PACKAGE_PIN U18 [get_ports btnC]
set_property IOSTANDARD LVCMOS33 [get_ports btnC]

# Switch for clear canvas (SW[15])
set_property PACKAGE_PIN R2 [get_ports sw15]
set_property IOSTANDARD LVCMOS33 [get_ports sw15]

# VGA Signals - Red (4 bits)
set_property PACKAGE_PIN G19 [get_ports {R[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {R[0]}]
set_property PACKAGE_PIN H19 [get_ports {R[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {R[1]}]
set_property PACKAGE_PIN J19 [get_ports {R[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {R[2]}]
set_property PACKAGE_PIN N19 [get_ports {R[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {R[3]}]

# VGA Signals - Green (4 bits)
set_property PACKAGE_PIN J17 [get_ports {G[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {G[0]}]
set_property PACKAGE_PIN H17 [get_ports {G[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {G[1]}]
set_property PACKAGE_PIN G17 [get_ports {G[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {G[2]}]
set_property PACKAGE_PIN D17 [get_ports {G[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {G[3]}]

# VGA Signals - Blue (4 bits)
set_property PACKAGE_PIN N18 [get_ports {B[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {B[0]}]
set_property PACKAGE_PIN L18 [get_ports {B[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {B[1]}]
set_property PACKAGE_PIN K18 [get_ports {B[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {B[2]}]
set_property PACKAGE_PIN J18 [get_ports {B[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {B[3]}]

# Sync signals
set_property PACKAGE_PIN P19 [get_ports hSYNC]
set_property IOSTANDARD LVCMOS33 [get_ports hSYNC]
set_property PACKAGE_PIN R19 [get_ports vSYNC]
set_property IOSTANDARD LVCMOS33 [get_ports vSYNC]

# Configuration for Basys3
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]