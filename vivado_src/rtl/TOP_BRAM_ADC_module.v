module TOP_BRAM_ADC_module (
    input clk, reset_p,
    output Hsync,Vsync,
    output [3:0] V2M_Red, V2M_Green, V2M_Blue
);

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


BRAM_ADC_test BAT(
    .clk(clk), .reset_p(reset_p),
    .pixel_clock_pulse(pixel_clock_pulse),
    .in_hsync(Hsync), .in_vsync(Vsync),
    .in_display_on(out_display_on),
    .out_addr_x(gen_addr_x), .out_addr_y(gen_addr_y),
    .write_enable(write_enable),
    .vgaRed(gen_vgaRed), .vgaGreen(gen_vgaGreen), .vgaBlue(gen_vgaBlue)
);

endmodule