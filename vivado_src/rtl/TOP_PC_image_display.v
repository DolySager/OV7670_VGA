`timescale 1ns / 1ps

module TOP_PC_image_display(
    input clk, reset_p,
    input data,
    input data_clk,
    input RsRx,
    output Hsync, Vsync,
    output [3:0] V2M_Red, V2M_Green, V2M_Blue,
    output [3:0] com,
    output [7:0] seg_7);
    
    wire pixel_clock_pulse;
    pixel_clock_generator PCG (
        .clk(clk), .reset_p(reset_p),
        .pixel_clock_pulse(pixel_clock_pulse)
    );
    
    wire out_display_on;
    wire [3:0] B2V_Red, B2V_Green, B2V_Blue;
    wire [9:0] pixel_coord_x, pixel_coord_y;
    
    VGA_controller VC(
        .clk(clk), .reset_p(reset_p),
        .pixel_clock_pulse(pixel_clock_pulse),
        .in_vgaRed(B2V_Red), .in_vgaGreen(B2V_Green), .in_vgaBlue(B2V_Blue),
        .Hsync(Hsync), .Vsync(Vsync), .out_display_on(out_display_on),
        .out_vgaRed(V2M_Red), .out_vgaGreen(V2M_Green), .out_vgaBlue(V2M_Blue),
        .count_h (pixel_coord_x),
        .count_v (pixel_coord_y)
    );
    
    
    wire [9:0] addr_x_scaler, addr_y_scaler;
    pixel_coord_converter PCC(
        .addr_x(pixel_coord_x), .addr_y(pixel_coord_y),
        .addr_x_scaler(addr_x_scaler), .addr_y_scaler(addr_y_scaler)
    );
    
    wire write_enable;
    wire [9:0] gen_addr_x, gen_addr_y;
    wire [3:0] gen_vgaRed, gen_vgaGreen, gen_vgaBlue;
    BRAM_320x240_controller BC(
        .clk(clk), .reset_p(reset_p),
        .write_enable(write_enable),
        .porta_addr_x(gen_addr_x), .portb_addr_x(addr_x_scaler),
        .porta_addr_y(gen_addr_y), .portb_addr_y(addr_y_scaler),
        .porta_vgaRed(gen_vgaRed), .porta_vgaGreen(gen_vgaGreen), .porta_vgaBlue(gen_vgaBlue),
    
        .portb_vgaRed(B2V_Red), .portb_vgaGreen(B2V_Green), .portb_vgaBlue(B2V_Blue)
    );
    
    UART_Rx_pixel_data_addr_and_rgb image_receiver(
        .clk (clk),
        .reset_p (reset_p),
        
        .uart_rx (RsRx),
        
        .write_enable (write_enable),
        
        .pixel_addr_x (gen_addr_x),
        .pixel_addr_y (gen_addr_y),
        
        .pixel_red(gen_vgaRed),
        .pixel_green (gen_vgaGreen),
        .pixel_blue (gen_vgaBlue)
    );

endmodule
