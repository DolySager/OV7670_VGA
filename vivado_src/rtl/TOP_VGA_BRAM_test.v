`timescale 1ns / 1ps


module TOP_VGA_BRAM_test (
    input clk, reset_p,
    output Hsync, Vsync,
    output [3:0] vgaRed, vgaGreen, vgaBlue
);

    wire [3:0] inter_vgaRed, inter_vgaGreen, inter_vgaBlue;
    wire [3:0] gen_vgaRed, gen_vgaGreen, gen_vgaBlue;
    wire [9:0] gen_addr_x, gen_addr_y;
    wire write_enable;
    wire display_on;
    wire [9:0] cur_pixel_coord_x, cur_pixel_coord_y;

    pixel_clock_generator pixel_clock_gen_module (
        .clk (clk),
        .reset_p (reset_p),
        
        .pixel_clock_pulse (pixel_clock_pulse)
    );

    
    pixel_coordinate_tracker pixel_coord_tracker_module (
        .clk (clk),
        .reset_p (reset_p),
        
        .Hsync          (Hsync),
        .Vsync          (Vsync),
        .pixel_clock_pusle  (pixel_clock_pulse),
        .in_display_on  (display_on),
        
        .pixel_coord_x  (cur_pixel_coord_x),
        .pixel_coord_y  (cur_pixel_coord_y)
    );

    VGA_controller vga_cntr_module(
        .clk (clk),
        .reset_p (reset_p),
        .pixel_clock_pulse (pixel_clock_pulse),
        
        .in_vgaRed (inter_vgaRed),
        .in_vgaGreen (inter_vgaGreen),
         .in_vgaBlue (inter_vgaBlue),
         
        .Hsync (Hsync),
        .Vsync (Vsync),
        .out_display_on (display_on),
        
        .out_vgaRed (vgaRed),
        .out_vgaGreen (vgaGreen),
        .out_vgaBlue (vgaBlue)
    );

    BRAM_320x240_controller BRAM_cntr_module(
        .clk (clk),
        .reset_p (reset_p),
        
       .write_enable (write_enable),
       
       .porta_addr_x (gen_addr_x),
       .porta_addr_y (gen_addr_y),
       .porta_vgaRed (gen_vgaRed),
       .porta_vgaGreen (gen_vgaGreen),
       .porta_vgaBlue (gen_vgaBlue),
       
       .portb_addr_x (cur_pixel_coord_x),
       .portb_addr_y (cur_pixel_coord_y),
       .portb_vgaRed (inter_vgaRed),
       .portb_vgaGreen (inter_vgaGreen),
       .portb_vgaBlue (inter_vgaBlue)
    );
    
    BRAM_test_generator BRAM_test_gen_module (
        .clk (clk),
        .reset_p (reset_p),
        .pixel_clock_pulse (pixel_clock_pulse),
        .in_hsync (Hsync),
        .in_vsync (Vsync),
        .in_display_on (display_on),
        
        .out_addr_x (gen_addr_x),
        .out_addr_y (gen_addr_y),
        .write_enable (write_enable),
        
        .vgaRed (gen_vgaRed),
        .vgaGreen (gen_vgaGreen),
        .vgaBlue (gen_vgaBlue)
    );
    
endmodule
