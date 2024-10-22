## This file is a general .xdc for the Basys3 rev B board
## To use it in a project:
## - uncomment the lines corresponding to used pins
## - rename the used ports (in each line, after get_ports) according to the top level signal names in the project

## Clock signal
set_property -dict { PACKAGE_PIN W5   IOSTANDARD LVCMOS33 } [get_ports i_clk]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports i_clk]


## Switches
set_property -dict { PACKAGE_PIN V17   IOSTANDARD LVCMOS33 } [get_ports {i_sw_contFrame}]
#set_property -dict { PACKAGE_PIN V16   IOSTANDARD LVCMOS33 } [get_ports {sw[1]}]
#set_property -dict { PACKAGE_PIN W16   IOSTANDARD LVCMOS33 } [get_ports {sw[2]}]
#set_property -dict { PACKAGE_PIN W17   IOSTANDARD LVCMOS33 } [get_ports {sw[3]}]
#set_property -dict { PACKAGE_PIN W15   IOSTANDARD LVCMOS33 } [get_ports {sw[4]}]
#set_property -dict { PACKAGE_PIN V15   IOSTANDARD LVCMOS33 } [get_ports {sw[5]}]
#set_property -dict { PACKAGE_PIN W14   IOSTANDARD LVCMOS33 } [get_ports {sw[6]}]
#set_property -dict { PACKAGE_PIN W13   IOSTANDARD LVCMOS33 } [get_ports {sw[7]}]
#set_property -dict { PACKAGE_PIN V2    IOSTANDARD LVCMOS33 } [get_ports {sw[8]}]
#set_property -dict { PACKAGE_PIN T3    IOSTANDARD LVCMOS33 } [get_ports {sw[9]}]
#set_property -dict { PACKAGE_PIN T2    IOSTANDARD LVCMOS33 } [get_ports {sw[10]}]
#set_property -dict { PACKAGE_PIN R3    IOSTANDARD LVCMOS33 } [get_ports {sw[11]}]
#set_property -dict { PACKAGE_PIN W2    IOSTANDARD LVCMOS33 } [get_ports {sw[12]}]
#set_property -dict { PACKAGE_PIN U1    IOSTANDARD LVCMOS33 } [get_ports {sw[13]}]
#set_property -dict { PACKAGE_PIN T1    IOSTANDARD LVCMOS33 } [get_ports {sw[14]}]
#set_property -dict { PACKAGE_PIN R2    IOSTANDARD LVCMOS33 } [get_ports {sw[15]}]


## LEDs
set_property -dict { PACKAGE_PIN U16   IOSTANDARD LVCMOS33 } [get_ports {o_led_present_state[0]}]; #
set_property -dict { PACKAGE_PIN E19   IOSTANDARD LVCMOS33 } [get_ports {o_led_present_state[1]}]
set_property -dict { PACKAGE_PIN U19   IOSTANDARD LVCMOS33 } [get_ports {o_led_present_state[2]}]
set_property -dict { PACKAGE_PIN V19   IOSTANDARD LVCMOS33 } [get_ports {o_led_present_state[3]}]
set_property -dict { PACKAGE_PIN W18   IOSTANDARD LVCMOS33 } [get_ports {o_led_present_state[4]}]
set_property -dict { PACKAGE_PIN U15   IOSTANDARD LVCMOS33 } [get_ports {o_led_present_state[5]}]
#set_property -dict { PACKAGE_PIN U14   IOSTANDARD LVCMOS33 } [get_ports {data_wire[6]}]
#set_property -dict { PACKAGE_PIN V14   IOSTANDARD LVCMOS33 } [get_ports {data_wire[7]}]
#set_property -dict { PACKAGE_PIN V13   IOSTANDARD LVCMOS33 } [get_ports {led[8]}]
#set_property -dict { PACKAGE_PIN V3    IOSTANDARD LVCMOS33 } [get_ports {led[9]}]
#set_property -dict { PACKAGE_PIN W3    IOSTANDARD LVCMOS33 } [get_ports {led[10]}]
#set_property -dict { PACKAGE_PIN U3    IOSTANDARD LVCMOS33 } [get_ports {led[11]}]
#set_property -dict { PACKAGE_PIN P3    IOSTANDARD LVCMOS33 } [get_ports {led[12]}]
#set_property -dict { PACKAGE_PIN N3    IOSTANDARD LVCMOS33 } [get_ports {led[13]}]
#set_property -dict { PACKAGE_PIN P1    IOSTANDARD LVCMOS33 } [get_ports {led[14]}]
set_property -dict { PACKAGE_PIN L1    IOSTANDARD LVCMOS33 } [get_ports {o_led_configure_done}]


##7 Segment Display
# set_property -dict { PACKAGE_PIN W7   IOSTANDARD LVCMOS33 } [get_ports {seg_7[7]}]; #seg_A
# set_property -dict { PACKAGE_PIN W6   IOSTANDARD LVCMOS33 } [get_ports {seg_7[6]}]; #seg_B
# set_property -dict { PACKAGE_PIN U8   IOSTANDARD LVCMOS33 } [get_ports {seg_7[5]}]; #seg_C
# set_property -dict { PACKAGE_PIN V8   IOSTANDARD LVCMOS33 } [get_ports {seg_7[4]}]; #seg_D
# set_property -dict { PACKAGE_PIN U5   IOSTANDARD LVCMOS33 } [get_ports {seg_7[3]}]; #seg_E
# set_property -dict { PACKAGE_PIN V5   IOSTANDARD LVCMOS33 } [get_ports {seg_7[2]}]; #seg_F
# set_property -dict { PACKAGE_PIN U7   IOSTANDARD LVCMOS33 } [get_ports {seg_7[1]}]; #seg_G
# set_property -dict { PACKAGE_PIN V7   IOSTANDARD LVCMOS33 } [get_ports {seg_7[0]}]; #seg_DP

# set_property -dict { PACKAGE_PIN U2   IOSTANDARD LVCMOS33 } [get_ports {com[0]}]; #LSB (right)
# set_property -dict { PACKAGE_PIN U4   IOSTANDARD LVCMOS33 } [get_ports {com[1]}]; #
# set_property -dict { PACKAGE_PIN V4   IOSTANDARD LVCMOS33 } [get_ports {com[2]}]; #
# set_property -dict { PACKAGE_PIN W4   IOSTANDARD LVCMOS33 } [get_ports {com[3]}]; #MSB (left)


###Buttons
set_property -dict { PACKAGE_PIN U18   IOSTANDARD LVCMOS33 } [get_ports {reset}]; #btnC
set_property -dict { PACKAGE_PIN T18   IOSTANDARD LVCMOS33 } [get_ports {i_btn_start}]; #btnU
#set_property -dict { PACKAGE_PIN W19   IOSTANDARD LVCMOS33 } [get_ports {btn[1]}]; #btnL
#set_property -dict { PACKAGE_PIN T17   IOSTANDARD LVCMOS33 } [get_ports {btn[2]}]; #btnR
set_property -dict { PACKAGE_PIN U17   IOSTANDARD LVCMOS33 } [get_ports {i_btn_configure}]; #btnD


##Pmod Header JA
set_property -dict { PACKAGE_PIN J1   IOSTANDARD LVCMOS33 } [get_ports {o_PCLK}];#Sch name = JA1
set_property -dict { PACKAGE_PIN L2   IOSTANDARD LVCMOS33 } [get_ports {o_HS}];#Sch name = JA2
set_property -dict { PACKAGE_PIN J2   IOSTANDARD LVCMOS33 } [get_ports {o_VS}];#Sch name = JA3
#set_property -dict { PACKAGE_PIN G2   IOSTANDARD LVCMOS33 } [get_ports {JA[3]}];#Sch name = JA4
#set_property -dict { PACKAGE_PIN H1   IOSTANDARD LVCMOS33 } [get_ports {JA[4]}];#Sch name = JA7
#set_property -dict { PACKAGE_PIN K2   IOSTANDARD LVCMOS33 } [get_ports {JA[5]}];#Sch name = JA8
#set_property -dict { PACKAGE_PIN H2   IOSTANDARD LVCMOS33 } [get_ports {JA[6]}];#Sch name = JA9
#set_property -dict { PACKAGE_PIN G3   IOSTANDARD LVCMOS33 } [get_ports {JA[7]}];#Sch name = JA10

##Pmod Header JB
# set_property -dict { PACKAGE_PIN A14   IOSTANDARD LVCMOS33 } [get_ports {i_DATA[0]}];#Sch name = JB1
# set_property -dict { PACKAGE_PIN A16   IOSTANDARD LVCMOS33 } [get_ports {i_DATA[1]}];#Sch name = JB2
# set_property -dict { PACKAGE_PIN B15   IOSTANDARD LVCMOS33 } [get_ports {i_DATA[2]}];#Sch name = JB3
# set_property -dict { PACKAGE_PIN B16   IOSTANDARD LVCMOS33 } [get_ports {i_DATA[3]}];#Sch name = JB4
# set_property -dict { PACKAGE_PIN A15   IOSTANDARD LVCMOS33 } [get_ports {i_DATA[4]}];#Sch name = JB7
# set_property -dict { PACKAGE_PIN A17   IOSTANDARD LVCMOS33 } [get_ports {i_DATA[5]}];#Sch name = JB8
# set_property -dict { PACKAGE_PIN C15   IOSTANDARD LVCMOS33 } [get_ports {i_DATA[6]}];#Sch name = JB9
# set_property -dict { PACKAGE_PIN C16   IOSTANDARD LVCMOS33 } [get_ports {i_DATA[7]}];#Sch name = JB10
set_property -dict { PACKAGE_PIN A14   IOSTANDARD LVCMOS33 } [get_ports {i_DATA[7]}];#Sch name = JB1
set_property -dict { PACKAGE_PIN A16   IOSTANDARD LVCMOS33 } [get_ports {i_DATA[5]}];#Sch name = JB2
set_property -dict { PACKAGE_PIN B15   IOSTANDARD LVCMOS33 } [get_ports {i_DATA[3]}];#Sch name = JB3
set_property -dict { PACKAGE_PIN B16   IOSTANDARD LVCMOS33 } [get_ports {i_DATA[1]}];#Sch name = JB4
set_property -dict { PACKAGE_PIN A15   IOSTANDARD LVCMOS33 } [get_ports {i_DATA[6]}];#Sch name = JB7
set_property -dict { PACKAGE_PIN A17   IOSTANDARD LVCMOS33 } [get_ports {i_DATA[4]}];#Sch name = JB8
set_property -dict { PACKAGE_PIN C15   IOSTANDARD LVCMOS33 } [get_ports {i_DATA[2]}];#Sch name = JB9
set_property -dict { PACKAGE_PIN C16   IOSTANDARD LVCMOS33 } [get_ports {i_DATA[0]}];#Sch name = JB10

##Pmod Header JC
set_property -dict { PACKAGE_PIN K17   IOSTANDARD LVCMOS33 PULLUP true} [get_ports {io_SDA}];#Sch name = JC1
set_property -dict { PACKAGE_PIN M18   IOSTANDARD LVCMOS33 PULLUP true} [get_ports {o_SCL}];#Sch name = JC2
set_property -dict { PACKAGE_PIN N17   IOSTANDARD LVCMOS33 } [get_ports {i_HS}];#Sch name = JC3
set_property -dict { PACKAGE_PIN P18   IOSTANDARD LVCMOS33 } [get_ports {i_VS}];#Sch name = JC4
set_property -dict { PACKAGE_PIN L17   IOSTANDARD LVCMOS33 } [get_ports {i_PCLK}];#Sch name = JC7
set_property -dict { PACKAGE_PIN M19   IOSTANDARD LVCMOS33 } [get_ports {o_XCLK}];#Sch name = JC8
# set_property -dict { PACKAGE_PIN P17   IOSTANDARD LVCMOS33 } [get_ports {}];#Sch name = JC9
# set_property -dict { PACKAGE_PIN R18   IOSTANDARD LVCMOS33 } [get_ports {}];#Sch name = JC10

##Pmod Header JXADC
#set_property -dict { PACKAGE_PIN J3   IOSTANDARD LVCMOS33 } [get_ports {vauxp6}];#Sch name = XA1_P
#set_property -dict { PACKAGE_PIN L3   IOSTANDARD LVCMOS33 } [get_ports {JXADC[1]}];#Sch name = XA2_P
#set_property -dict { PACKAGE_PIN M2   IOSTANDARD LVCMOS33 } [get_ports {JXADC[2]}];#Sch name = XA3_P
#set_property -dict { PACKAGE_PIN N2   IOSTANDARD LVCMOS33 } [get_ports {vauxp15}];#Sch name = XA4_P
#set_property -dict { PACKAGE_PIN K3   IOSTANDARD LVCMOS33 } [get_ports {vauxn6}];#Sch name = XA1_N
#set_property -dict { PACKAGE_PIN M3   IOSTANDARD LVCMOS33 } [get_ports {JXADC[5]}];#Sch name = XA2_N
#set_property -dict { PACKAGE_PIN M1   IOSTANDARD LVCMOS33 } [get_ports {JXADC[6]}];#Sch name = XA3_N
#set_property -dict { PACKAGE_PIN N1   IOSTANDARD LVCMOS33 } [get_ports {vauxn15}];#Sch name = XA4_N


##VGA Connector
set_property -dict { PACKAGE_PIN G19   IOSTANDARD LVCMOS33 } [get_ports {o_vgaRed[0]}]
set_property -dict { PACKAGE_PIN H19   IOSTANDARD LVCMOS33 } [get_ports {o_vgaRed[1]}]
set_property -dict { PACKAGE_PIN J19   IOSTANDARD LVCMOS33 } [get_ports {o_vgaRed[2]}]
set_property -dict { PACKAGE_PIN N19   IOSTANDARD LVCMOS33 } [get_ports {o_vgaRed[3]}]
set_property -dict { PACKAGE_PIN N18   IOSTANDARD LVCMOS33 } [get_ports {o_vgaBlue[0]}]
set_property -dict { PACKAGE_PIN L18   IOSTANDARD LVCMOS33 } [get_ports {o_vgaBlue[1]}]
set_property -dict { PACKAGE_PIN K18   IOSTANDARD LVCMOS33 } [get_ports {o_vgaBlue[2]}]
set_property -dict { PACKAGE_PIN J18   IOSTANDARD LVCMOS33 } [get_ports {o_vgaBlue[3]}]
set_property -dict { PACKAGE_PIN J17   IOSTANDARD LVCMOS33 } [get_ports {o_vgaGreen[0]}]
set_property -dict { PACKAGE_PIN H17   IOSTANDARD LVCMOS33 } [get_ports {o_vgaGreen[1]}]
set_property -dict { PACKAGE_PIN G17   IOSTANDARD LVCMOS33 } [get_ports {o_vgaGreen[2]}]
set_property -dict { PACKAGE_PIN D17   IOSTANDARD LVCMOS33 } [get_ports {o_vgaGreen[3]}]
set_property -dict { PACKAGE_PIN P19   IOSTANDARD LVCMOS33 } [get_ports {o_Hsync}]
set_property -dict { PACKAGE_PIN R19   IOSTANDARD LVCMOS33 } [get_ports {o_Vsync}]


##USB-RS232 Interface
# set_property -dict { PACKAGE_PIN B18   IOSTANDARD LVCMOS33 } [get_ports RsRx]
#set_property -dict { PACKAGE_PIN A18   IOSTANDARD LVCMOS33 } [get_ports RsTx]


##USB HID (PS/2)
# set_property -dict { PACKAGE_PIN C17   IOSTANDARD LVCMOS33   PULLUP true } [get_ports data_clk]
# set_property -dict { PACKAGE_PIN B17   IOSTANDARD LVCMOS33   PULLUP true } [get_ports data]


##Quad SPI Flash
##Note that CCLK_0 cannot be placed in 7 series devices. You can access it using the
##STARTUPE2 primitive.
#set_property -dict { PACKAGE_PIN D18   IOSTANDARD LVCMOS33 } [get_ports {QspiDB[0]}]
#set_property -dict { PACKAGE_PIN D19   IOSTANDARD LVCMOS33 } [get_ports {QspiDB[1]}]
#set_property -dict { PACKAGE_PIN G18   IOSTANDARD LVCMOS33 } [get_ports {QspiDB[2]}]
#set_property -dict { PACKAGE_PIN F18   IOSTANDARD LVCMOS33 } [get_ports {QspiDB[3]}]
#set_property -dict { PACKAGE_PIN K19   IOSTANDARD LVCMOS33 } [get_ports QspiCSn]


## Configuration options, can be used for all designs
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]

## SPI configuration mode options for QSPI boot, can be used for all designs
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]
