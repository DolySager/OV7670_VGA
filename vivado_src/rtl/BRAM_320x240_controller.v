`timescale 1ns / 1ps

// Port A always input, Port B always output
module BRAM_320x240_controller(
    input clk, reset_p,
    input write_enable,
    
    input [9:0] porta_addr_x, porta_addr_y,
    input [3:0] porta_vgaRed, porta_vgaGreen, porta_vgaBlue,
    
    input [9:0] portb_addr_x, portb_addr_y,
    output [3:0] portb_vgaRed, portb_vgaGreen, portb_vgaBlue
);
    // some unused memory spaces, but this will eliminate usage of multiplication
    wire [9:0] portb_addr_x_oneahead =  portb_addr_x[8:0] + 1;
    wire [16:0] porta_addr_1d = {porta_addr_y[7:0], porta_addr_x[8:0]};
    wire [16:0] portb_addr_1d = {portb_addr_y[7:0], portb_addr_x_oneahead[8:0]};   // read one pixel ahead due to one clock delay in BRAM
    
    BRAM_4bit_512x240 BRAM_red (
        .clka       (clk),
        .wea        (write_enable),
        .addra      (porta_addr_1d),
        .dina       (porta_vgaRed),
        
        .clkb       (clk),
        .addrb      (portb_addr_1d),
        .doutb      (portb_vgaRed)
    );
    
    BRAM_4bit_512x240 BRAM_green (
        .clka       (clk),
        .wea        (write_enable),
        .addra      (porta_addr_1d),
        .dina       (porta_vgaGreen),
        
        .clkb       (clk),
        .addrb      (portb_addr_1d),
        .doutb      (portb_vgaGreen)
    );
    
    BRAM_4bit_512x240 BRAM_blue (
        .clka       (clk),
        .wea        (write_enable),
        .addra      (porta_addr_1d),
        .dina       (porta_vgaBlue),
        
        .clkb       (clk),
        .addrb      (portb_addr_1d),
        .doutb      (portb_vgaBlue)
    );

endmodule
