`timescale 1ns / 1ps

module Receiver #(
        parameter                                           DATA_WIDTH      =       8,
        parameter                                           H_WIDTH         =       320,
        parameter                                           V_WIDTH         =       240,
        parameter                                           R_WIDTH         =       5,
        parameter                                           G_WIDTH         =       6,
        parameter                                           B_WIDTH         =       5,
        parameter                                           PXL_WIDTH       =       R_WIDTH + G_WIDTH + B_WIDTH
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

        // XCLK_GEN IF
        output      wire                                    o_en_xclk,

        // BRAM IF
        output      wire        [PXL_WIDTH - 1 : 0]         o_pixel_data,
        output      wire        [$clog2(H_WIDTH) : 0]       o_h_addr,
        output      wire        [$clog2(V_WIDTH) : 0]       o_v_addr,
        output      wire                                    o_valid
    );

                    localparam                              PXL_WIDTH_RGB565    =   16;
                    localparam                              PXL_WIDTH_RGB555    =   15;
                    localparam                              PXL_WIDTH_RGB444    =   12;

                    localparam  [5 : 0]                     IDLE                =   6'b000_001 << 0;
                    localparam  [5 : 0]                     WAIT_VSYNC_FALL     =   6'b000_001 << 1;
                    localparam  [5 : 0]                     WAIT_HREF_RISE      =   6'b000_001 << 2;
                    localparam  [5 : 0]                     WAIT_FIRST_BYTE     =   6'b000_001 << 3;
                    localparam  [5 : 0]                     WAIT_SECOND_BYTE    =   6'b000_001 << 4;
                    localparam  [5 : 0]                     FRAME_DONE          =   6'b000_001 << 5;

                    reg         [5 : 0]                     present_state;
                    reg         [5 : 0]                     next_state;

                    reg                                     r_en_xclk;
                    reg         [2*DATA_WIDTH - 1 : 0]      r_pixel_data;
                    reg                                     r_valid;

                    wire                                    w_pclk_posedge;
                    reg                                     r_pclk_posedge_z;
                    wire                                    w_pclk_negedge;

                    wire                                    w_href_posedge;
                    wire                                    w_href_negedge;

                    wire                                    w_vsync_posedge;
                    wire                                    w_vsync_negedge;

                    reg                                     r_flag;

                    reg         [$clog2(H_WIDTH) : 0]       r_h_addr;
                    reg         [$clog2(V_WIDTH) : 0]       r_v_addr;

        edge_detector_n                                     ED_PCLK(
            .i_clk                                          (i_clk),
            .i_reset                                        (~i_n_reset),
            .i_cp                                           (i_PCLK),
            .o_posedge                                      (w_pclk_posedge),
            .o_negedge                                      (w_pclk_negedge)
        );

        edge_detector_n                                     ED_HREF(
            .i_clk                                          (i_clk),
            .i_reset                                        (~i_n_reset),
            .i_cp                                           (i_HS),
            .o_posedge                                      (w_href_posedge),
            .o_negedge                                      (w_href_negedge)
        );

        edge_detector_n                                     ED_VSYNC(
            .i_clk                                          (i_clk),
            .i_reset                                        (~i_n_reset),
            .i_cp                                           (i_VS),
            .o_posedge                                      (w_vsync_posedge),
            .o_negedge                                      (w_vsync_negedge)
        );

        always @(negedge i_clk) begin
            if (!i_n_reset) begin
                present_state <= IDLE;
            end
            else begin
                present_state <= next_state;
            end
        end

        always @(posedge i_clk) begin
            if (!i_n_reset) begin
                next_state <= IDLE;
                r_pixel_data <= 0;
                r_en_xclk <= 0;
            end
            else begin
                case (present_state)
                
                    IDLE    : begin
                        if (i_start_capture) begin
                            next_state <= WAIT_VSYNC_FALL;
                            r_en_xclk <= 1;
                        end
                        else begin
                            next_state <= IDLE;
                        end
                    end

                    WAIT_VSYNC_FALL : begin
                        if (w_vsync_negedge) begin
                            next_state <= WAIT_HREF_RISE;
                        end
                        else begin
                            next_state <= WAIT_VSYNC_FALL;
                        end
                    end

                    WAIT_HREF_RISE : begin
                        if (w_vsync_posedge) begin
                            next_state <= FRAME_DONE;
                        end
                        else if (w_href_posedge) begin
                            next_state <= WAIT_FIRST_BYTE;
                        end
                        else begin
                            next_state <= WAIT_HREF_RISE;
                        end
                    end

                    WAIT_FIRST_BYTE : begin : PXL_DATA_RCV
                        if (w_vsync_posedge) begin
                            next_state <= FRAME_DONE;
                        end
                        else if (w_href_negedge) begin
                            // Next Line
                            next_state <= WAIT_HREF_RISE;
                        end
                        // else if (r_pclk_posedge_z) begin
                        else if (w_pclk_negedge) begin
                            next_state <= WAIT_SECOND_BYTE;
                            r_pixel_data <= i_DATA;
                        end
                        else begin
                            next_state <= WAIT_FIRST_BYTE;
                        end
                    end

                    WAIT_SECOND_BYTE : begin
                        if (w_vsync_posedge) begin
                            next_state <= FRAME_DONE;
                        end
                        // else if (r_pclk_posedge_z) begin
                        else if (w_pclk_negedge) begin
                            // Next Byte, in same line
                            next_state <= WAIT_FIRST_BYTE;
                            r_pixel_data <= (r_pixel_data << (DATA_WIDTH) | i_DATA);
                        end
                        else begin
                            next_state <= WAIT_SECOND_BYTE;
                        end
                    end

                    FRAME_DONE : begin
                        if (i_next_frame) begin
                            next_state      <=      WAIT_VSYNC_FALL;
                            r_pixel_data    <=      0;
                            r_en_xclk       <=      1;
                        end
                    end

                    default : begin
                            next_state      <=      'bz;
                            r_pixel_data    <=      'bz;
                            r_en_xclk       <=      'bz;
                    end
                endcase
            end
        end

        always @(posedge i_clk) begin
            if (!i_n_reset) begin
                r_h_addr <= 0;
                r_v_addr <= 0;
                r_flag <= 0;
                r_valid <= 0;
            end
            else begin
                if (w_vsync_posedge) begin
                    r_h_addr <= 0;
                    r_v_addr <= 0;
                    r_valid <= 0;
                end
                else if (w_href_negedge) begin
                    r_h_addr <= 0;
                    r_v_addr <= r_v_addr + 1;
                    r_valid <= 0;
                end
                // else if (o_valid) begin
                //     r_h_addr <= r_h_addr + 1;
                // end
                else if (r_pclk_posedge_z && i_HS) begin
                    if (r_flag == 0) begin
                        r_flag <= 1;
                        r_valid <= 0;
                    end
                    else if (r_flag == 1) begin
                        r_flag <= 0;
                        r_h_addr <= r_h_addr + 1;
                        r_valid <= 1;
                    end
                end
                else begin
                    r_valid <= 0;
                end
                // if (o_valid) begin
                //     if (r_h_addr >= H_WIDTH - 1) begin
                //         if (r_v_addr >= V_WIDTH - 1) begin
                //             r_h_addr <= 0;
                //             r_v_addr <= 0;
                //         end
                //         else begin
                //             r_h_addr <= 0;
                //             r_v_addr <= r_v_addr + 1;
                //         end
                //     end
                //     else begin
                //         r_h_addr <= r_h_addr + 1;
                //     end
                // end
            end
        end

        always @(posedge i_clk) begin
            if (!i_n_reset) begin
                r_pclk_posedge_z <= 0;
            end
            else begin
                r_pclk_posedge_z <= w_pclk_posedge;
            end
        end

        assign  o_present_state =       present_state;
        assign  o_pixel_data    =       r_pixel_data[PXL_WIDTH - 1 : 0];
        assign  o_h_addr        =       r_h_addr;
        assign  o_v_addr        =       r_v_addr;
        assign  o_valid         =       r_valid;
        assign  o_en_xclk       =       r_en_xclk;

endmodule
