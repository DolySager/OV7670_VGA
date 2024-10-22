`timescale 1ns/1ps

module OV7670_STATE_REG_WR #(
        parameter CLK_FREQ=25000000
    )(
        // System
        input       wire            i_clk,

        // IO
        input       wire            i_btn_start,
        output      wire            o_led_done,

        // OV7670
        output      wire            o_SCL,
        output      wire            o_SDA
    );

        camera_configure            #(
            .CLK_FREQ               (CLK_FREQ)
        )                           i_camera_configure(
            .clk                    (i_clk),
            .start                  (i_btn_start),
            .sioc                   (o_SCL),
            .siod                   (o_SDA),
            .done                   (o_led_done)
        );
    
endmodule