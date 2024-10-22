`timescale 1ns / 1ps

module VGA_BRAM_IF #(
        parameter                           TARGET_BRAM_LINE_WIDTH = 512
)(
    // OV Receiver
        input       wire        [10 : 0]    i_h_addr,
        input       wire        [9 : 0]     i_v_addr,
        input       wire                    i_valid,
        input       wire        [15 : 0]    i_pixel_data,

    // VGA_BRAM
        output      wire        [9 : 0]     o_h_addr,
        output      wire        [9 : 0]     o_v_addr,
        output      wire                    o_valid,

        output      wire        [3 : 0]     o_pxl_r,
        output      wire        [3 : 0]     o_pxl_g,
        output      wire        [3 : 0]     o_pxl_b
    );

    assign o_h_addr = i_h_addr >> 1;
    assign o_v_addr = i_v_addr >> 1;
    assign o_valid  = i_valid;

    // Need More Things Here..

    // XRGB
    // assign {o_pxl_r, o_pxl_g, o_pxl_b} = i_pixel_data[11 : 0];

    // RGB565
    assign o_pxl_r = i_pixel_data[14 : 11];
    assign o_pxl_g = i_pixel_data[8 : 5];
    assign o_pxl_b = i_pixel_data[3 : 0];
    

endmodule
