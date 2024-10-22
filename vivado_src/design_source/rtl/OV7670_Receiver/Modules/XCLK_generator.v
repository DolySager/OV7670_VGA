`timescale 1ns / 1ps

module XCLK_generator #(
    parameter                                                       FREQ = 24_000_000
    )(
        input           wire                                        i_clk,
        input           wire                                        i_n_reset,
        input           wire                                        i_enable,
        input           wire                                        i_xclk,
        output          wire                                        o_xclk
    );
        // localparam                                                  F_CPU       =   100_000_000;
        // localparam                                                  CNT_TH      =   F_CPU / FREQ;

        //                 reg         [$clog2(CNT_TH) - 1 : 0]        r_count;

        // always @(posedge i_clk) begin
        //     if (!i_n_reset) begin
        //         r_count <= 0;
        //     end
        //     else if (i_enable) begin
        //         if (r_count >= CNT_TH - 1) begin
        //             r_count <= 0;
        //         end
        //         else begin
        //             r_count <= r_count + 1;
        //         end
        //     end
        //     else begin
        //         r_count <= 0;
        //     end
        // end

        // assign o_xclk = (r_count >= CNT_TH / 2) ? (1'b1) : (1'b0);
        assign o_xclk = (i_enable) ? (i_xclk) : (1'b0);
        
endmodule
