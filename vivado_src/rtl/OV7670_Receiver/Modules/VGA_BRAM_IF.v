`timescale 1ns / 1ps

module VGA_BRAM_IF(
    // OV Receiver
        input       wire        [9 : 0]     i_h_addr,
        input       wire        [9 : 0]     i_v_addr,
        input       wire                    i_valid,
        input       wire        [11 : 0]    i_pixel_data,

    // VGA_BRAM
        output      wire        [9 : 0]     o_h_addr,
        output      wire        [9 : 0]     o_v_addr,
        output      wire                    o_valid,

        output      wire        [3 : 0]     o_pxl_r,
        output      wire        [3 : 0]     o_pxl_g,
        output      wire        [3 : 0]     o_pxl_b
    );

    assign o_h_addr = {1'b0, i_h_addr[9 : 1]};
    assign o_v_addr = {1'b0, i_v_addr[9 : 1]};
    assign o_valid  = i_valid;

    // Need More Things Here..
    assign {o_pxl_r, o_pxl_g, o_pxl_b} = i_pixel_data[11 : 0];

endmodule
