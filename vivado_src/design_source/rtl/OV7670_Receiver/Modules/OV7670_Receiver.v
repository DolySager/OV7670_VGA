`timescale 1ns / 1ps

module OV7670_Receiver#(
        parameter                                           DATA_WIDTH      =       8,
        parameter                                           H_WIDTH         =       320,
        parameter                                           V_WIDTH         =       240,
        parameter                                           R_WIDTH         =       5,
        parameter                                           G_WIDTH         =       6,
        parameter                                           B_WIDTH         =       5,
        parameter                                           PXL_WIDTH       =       R_WIDTH + G_WIDTH + B_WIDTH,
        parameter                                           XCLK_FREQ       =       24_000_000
    )(
        // System IF
        input       wire                                    i_clk,
        input       wire                                    i_n_reset,
        input       wire                                    i_xclk,

        input       wire                                    i_next_frame,
        input       wire                                    i_start_capture,
        output      wire        [5 : 0]                     o_present_state,

        // OV7670 IF
        input       wire                                    i_PCLK,
        input       wire                                    i_VS,
        input       wire                                    i_HS,
        input       wire        [DATA_WIDTH - 1 : 0]        i_DATA,
        output      wire                                    o_XCLK,

        output      wire                                    o_PCLK,
        output      wire                                    o_VS,
        output      wire                                    o_HS,

        // VGA_BRAM_IF
        output      wire        [PXL_WIDTH - 1 : 0]         o_pixel_data,
        output      wire        [$clog2(H_WIDTH) : 0]       o_h_addr,
        output      wire        [$clog2(V_WIDTH) : 0]       o_v_addr,
        output      wire                                    o_valid 
    );
        // XCLK_GEN IF
                    wire                                    w_en_xclk;

        Receiver                                            #(
            .DATA_WIDTH                                     (DATA_WIDTH),
            .H_WIDTH                                        (H_WIDTH),
            .V_WIDTH                                        (V_WIDTH),
            .R_WIDTH                                        (R_WIDTH),
            .G_WIDTH                                        (G_WIDTH),
            .B_WIDTH                                        (B_WIDTH),
            .PXL_WIDTH                                      (PXL_WIDTH)
        )                                                   FSM(
            .i_clk                                          (i_clk),
            .i_n_reset                                      (i_n_reset),
            .i_next_frame                                   (i_next_frame),
            .i_start_capture                                (i_start_capture),
            .o_present_state                                (o_present_state),
            .i_PCLK                                         (i_PCLK),
            .i_VS                                           (i_VS),
            .i_HS                                           (i_HS),
            .o_PCLK                                         (o_PCLK),
            .o_VS                                           (o_VS),
            .o_HS                                           (o_HS),
            .i_DATA                                         (i_DATA),
            .o_en_xclk                                      (w_en_xclk),
            .o_pixel_data                                   (o_pixel_data),
            .o_h_addr                                       (o_h_addr),
            .o_v_addr                                       (o_v_addr),
            .o_valid                                        (o_valid)
        );

        XCLK_generator                                      #(
            .FREQ                                           (XCLK_FREQ)
        )                                                   XCLK_GEN(
            .i_clk                                          (i_clk),
            .i_n_reset                                      (i_n_reset),
            .i_enable                                       (w_en_xclk),
            .i_xclk                                         (i_xclk),
            .o_xclk                                         (o_XCLK)
        );
endmodule
