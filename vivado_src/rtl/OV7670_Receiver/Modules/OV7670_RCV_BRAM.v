`timescale 1ns / 1ps

module OV7670_RCV_BRAM#(
        parameter                                           DATA_WIDTH      =       8,
        parameter                                           H_WIDTH         =       640,
        parameter                                           V_WIDTH         =       480,
        parameter                                           R_WIDTH         =       4,
        parameter                                           G_WIDTH         =       4,
        parameter                                           B_WIDTH         =       4,
        parameter                                           PXL_WIDTH       =       R_WIDTH + G_WIDTH + B_WIDTH,
        parameter                                           XCLK_FREQ       =       24_000_000
    )(
        // System IF
        input       wire                                    i_clk,
        input       wire                                    i_n_reset,

        input       wire                                    i_next_frame,
        input       wire                                    i_start_capture,
        output      wire        [5 : 0]                     o_present_state,

        // OV7670 IF
        input       wire                                    i_PCLK,
        input       wire                                    i_VS,
        input       wire                                    i_HS,
        input       wire        [DATA_WIDTH - 1 : 0]        i_DATA,
        output      wire                                    o_XCLK,

        // VGA_BRAM_IF
        output      wire        [9 : 0]                     o_h_addr,
        output      wire        [9 : 0]                     o_v_addr,
        output      wire                                    o_valid,

        output      wire        [3 : 0]                     o_pxl_r,
        output      wire        [3 : 0]                     o_pxl_g,
        output      wire        [3 : 0]                     o_pxl_b
    );
                    wire        [9 : 0]                     w_h_addr;
                    wire        [9 : 0]                     w_v_addr;
                    wire                                    w_valid;
                    wire        [11 : 0]                    w_pixel_data;

        OV7670_Receiver                                     #(
            .DATA_WIDTH                                     (DATA_WIDTH),
            .H_WIDTH                                        (H_WIDTH),
            .V_WIDTH                                        (V_WIDTH),
            .R_WIDTH                                        (R_WIDTH),
            .G_WIDTH                                        (G_WIDTH),
            .B_WIDTH                                        (B_WIDTH),
            .PXL_WIDTH                                      (PXL_WIDTH),
            .XCLK_FREQ                                      (XCLK_FREQ)
        )                                                   OV_RCV(
            .i_clk                                          (i_clk),
            .i_n_reset                                      (i_n_reset),
            .i_next_frame                                   (i_next_frame),
            .i_start_capture                                (i_start_capture),
            .o_present_state                                (o_present_state),
            .i_PCLK                                         (i_PCLK),
            .i_VS                                           (i_VS),
            .i_HS                                           (i_HS),
            .i_DATA                                         (i_DATA),
            .o_XCLK                                         (o_XCLK),
            .o_pixel_data                                   (w_pixel_data),
            .o_h_addr                                       (w_h_addr),
            .o_v_addr                                       (w_v_addr),
            .o_valid                                        (w_valid)
        );

        VGA_BRAM_IF                                         BRAM_IF(
            .i_h_addr                                       (w_h_addr),
            .i_v_addr                                       (w_v_addr),
            .i_valid                                        (w_valid),
            .i_pixel_data                                   (w_pixel_data),

            .o_h_addr                                       (o_h_addr),
            .o_v_addr                                       (o_v_addr),
            .o_valid                                        (o_valid),
            .o_pxl_r                                        (o_pxl_r),
            .o_pxl_g                                        (o_pxl_g),
            .o_pxl_b                                        (o_pxl_b)
        );

endmodule
