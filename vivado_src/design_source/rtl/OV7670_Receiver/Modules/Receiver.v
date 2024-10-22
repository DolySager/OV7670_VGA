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

                    // Synchronize
                    reg                                     r_PCLK;
                    reg                                     r_VS;
                    reg                                     r_HS;
                    reg         [7 : 0]                     r_DATA;
                    
                    reg                                     r_PCLK_z;
                    reg                                     r_VS_z;
                    reg                                     r_HS_z;
                    reg         [7 : 0]                     r_DATA_z;
                    
                    reg                                     r_PCLK_zz;
                    reg                                     r_VS_zz;
                    reg                                     r_HS_zz;
                    reg         [7 : 0]                     r_DATA_zz;

                    wire                                    w_PCLK;
                    wire                                    w_VS;
                    wire                                    w_HS;
                    wire        [7 : 0]                     w_DATA;

                    reg                                     r_en_xclk;
                    reg         [2*DATA_WIDTH - 1 : 0]      r_pixel_data;
                    reg                                     r_valid;

                    wire                                    w_pclk_posedge;
                    wire                                    w_pclk_negedge;

                    wire                                    w_href_posedge;
                    wire                                    w_href_negedge;

                    wire                                    w_vsync_posedge;
                    wire                                    w_vsync_negedge;

                    wire                                    w_valid_posedge;

                    reg                                     r_flag;

                    reg         [15 : 0]                    r_pclk_count;
                    reg         [$clog2(H_WIDTH) : 0]       r_h_addr;
                    reg         [$clog2(V_WIDTH) : 0]       r_v_addr;

        edge_detector_n                                     ED_PCLK(
            .i_clk                                          (i_clk),
            .i_reset                                        (~i_n_reset),
            .i_cp                                           (w_PCLK),
            .o_posedge                                      (w_pclk_posedge),
            .o_negedge                                      (w_pclk_negedge)
        );

        edge_detector_n                                     ED_HREF(
            .i_clk                                          (w_PCLK),
            .i_reset                                        (~i_n_reset),
            .i_cp                                           (w_HS),
            .o_posedge                                      (w_href_posedge),
            .o_negedge                                      (w_href_negedge)
        );

        edge_detector_n                                     ED_VSYNC(
            .i_clk                                          (w_PCLK),
            .i_reset                                        (~i_n_reset),
            .i_cp                                           (w_VS),
            .o_posedge                                      (w_vsync_posedge),
            .o_negedge                                      (w_vsync_negedge)
        );

        always @(posedge i_clk) begin
            if (!i_n_reset) begin
                present_state <= IDLE;
            end
            else begin
                present_state <= next_state;
            end
        end

        always @(posedge w_PCLK or negedge i_n_reset) begin
            if (!i_n_reset) begin
                next_state <= IDLE;
                r_pixel_data <= 0;
                r_flag <= 0;
                r_valid <= 0;
                r_en_xclk <= 1;
                r_h_addr <= 0;
                r_v_addr <= 0;
                r_pclk_count <= 0;
            end
            else begin
                if (w_vsync_posedge) begin
                    r_h_addr <= 0;
                    r_v_addr <= 0;
                    r_flag <= 0;
                end
                if (w_href_negedge) begin
                    // if (r_v_addr >= V_WIDTH) begin
                    //     r_h_addr <= 0;
                    //     r_v_addr <= 0;
                    // end
                    // else begin
                        r_h_addr <= 0;
                        r_v_addr <= r_v_addr + 1;
                    // end
                    r_pclk_count <= 0;
                    r_flag <= 0;
                end
                if (w_HS) begin
                    if (r_pclk_count >= (16 - 1) && r_pclk_count <= ((640)*2 + 16 - 1)) begin
                        if (!r_flag) begin : RCV_FIRST_BYTE
                            r_flag <= ~r_flag;
                            r_pixel_data[2*DATA_WIDTH - 1 -: DATA_WIDTH] <= i_DATA;
                            r_valid <= 0;
                        end
                        else if (r_flag) begin : RCV_SECOND_BYTE
                            r_flag <= ~r_flag;
                            r_pixel_data[DATA_WIDTH - 1 -: DATA_WIDTH] <= i_DATA;
                            r_valid <= 1;
                            // if (r_h_addr >= H_WIDTH) begin
                            //     r_h_addr <= 0;
                            //     // r_v_addr <= r_v_addr + 1;
                            // end
                            // else begin
                                r_h_addr <= r_h_addr + 1;
                            // end
                        end
                        else begin
                            r_valid <= 0;
                        end
                    end
                    r_pclk_count <= r_pclk_count + 1;
                end
            end
        end

        always @(posedge i_clk) begin
            if (!i_n_reset) begin
                r_PCLK      <= 0;
                r_VS        <= 0;
                r_HS        <= 0;
                r_DATA      <= 0;
                
                r_PCLK_z    <= 0;
                r_VS_z      <= 0;
                r_HS_z      <= 0;
                r_DATA_z    <= 0;
                
                r_PCLK_zz   <= 0;
                r_VS_zz     <= 0;
                r_HS_zz     <= 0;
                r_DATA_zz   <= 0;
            end
            else begin
                r_PCLK      <= i_PCLK;
                r_VS        <= i_VS;
                r_HS        <= i_HS;
                r_DATA      <= i_DATA;
                
                r_PCLK_z    <= r_PCLK;
                r_VS_z      <= r_VS;
                r_HS_z      <= r_HS;
                r_DATA_z    <= r_DATA;

                r_PCLK_zz   <= r_PCLK_z;
                r_VS_zz     <= r_VS_z;
                r_HS_zz     <= r_HS_z;
                r_DATA_zz   <= r_DATA_z;
            end
        end

        assign  o_present_state     =       present_state;
        assign  o_pixel_data        =       r_pixel_data[PXL_WIDTH - 1 : 0];
        assign  o_h_addr            =       r_h_addr;
        assign  o_v_addr            =       r_v_addr;
        assign  o_valid             =       r_valid;
        assign  o_en_xclk           =       r_en_xclk;

        assign  w_PCLK              =       r_PCLK_zz;
        assign  w_VS                =       r_VS_zz;
        assign  w_HS                =       r_HS_zz;
        assign  w_DATA              =       r_DATA_zz;

endmodule
