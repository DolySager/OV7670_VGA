`timescale 1ns / 1ps

module tb_Receiver();

    parameter                           DATA_WIDTH          =       8;

    parameter                           H_WIDTH             =       4;
    parameter                           V_WIDTH             =       4;

    parameter                           R_WIDTH             =       5;
    parameter                           G_WIDTH             =       6;
    parameter                           B_WIDTH             =       5;
    parameter                           PXL_WIDTH           =       R_WIDTH + G_WIDTH + B_WIDTH;
    parameter                           XCLK_FREQ           =       24_000_000;
        
    localparam                          FIRST_LINE_DELAY    =       17;
    localparam                          INTER_LINE_DELAY    =       144;
    localparam                          LAST_LINE_DELAY     =       10;
        
    reg                                 i_clk               =       1'b0;
    reg                                 i_n_reset           =       1'b0;
    reg                                 i_next_frame        =       1'b0;
    reg                                 i_start_capture     =       1'b0;
    // reg                                 i_PCLK              =       1'b0;
    reg                                 i_VS                =       1'b1;
    reg                                 i_HS                =       1'b0;
    reg     [DATA_WIDTH - 1 : 0]        i_DATA              =       1;

    wire                                o_XCLK;
    wire    [$clog2(H_WIDTH) : 0]       o_h_addr;
    wire    [$clog2(V_WIDTH) : 0]       o_v_addr;
    wire                                o_valid;

    reg                                 r_XCLK_z            =       0;
    reg                                 r_XCLK_zz           =       0;
    wire                                w_PCLK;

    OV7670_Receiver                     #(
        .DATA_WIDTH                     (DATA_WIDTH),
        .H_WIDTH                        (H_WIDTH),
        .V_WIDTH                        (V_WIDTH),
        .R_WIDTH                        (R_WIDTH),
        .G_WIDTH                        (G_WIDTH),
        .B_WIDTH                        (B_WIDTH),
        .PXL_WIDTH                      (PXL_WIDTH),
        .XCLK_FREQ                      (XCLK_FREQ)
    )                                   DUT(
        .i_clk                          (i_clk),
        .i_n_reset                      (i_n_reset),
        .i_next_frame                   (i_next_frame),
        .i_start_capture                (i_start_capture),
        .i_PCLK                         (w_PCLK),
        .i_VS                           (i_VS),
        .i_HS                           (i_HS),
        .i_DATA                         (i_DATA),
        .o_XCLK                         (o_XCLK),
        .o_pixel_data                   (o_pixel_data),
        .o_h_addr                       (o_h_addr),
        .o_v_addr                       (o_v_addr),
        .o_valid                        (o_valid)
    );

    always #5 i_clk = ~i_clk;
    initial begin
        @(posedge i_clk) i_n_reset = 1'b0;
        @(posedge i_clk) i_n_reset = 1'b1;
        @(posedge i_clk) i_start_capture = 1;
        @(posedge w_PCLK) i_VS <= 0;
    end

    initial begin
        repeat (FIRST_LINE_DELAY) begin
            @(posedge w_PCLK);
        end
        repeat (V_WIDTH) begin
            @(negedge w_PCLK) i_HS <= 1;
            repeat (H_WIDTH * 2 - 1) begin
                @(negedge w_PCLK) i_DATA = i_DATA + 1;
            end
            @(negedge w_PCLK) i_HS <= 0;
            repeat (INTER_LINE_DELAY) begin
                @(negedge w_PCLK) i_HS <= 0;
            end
        end
        repeat (LAST_LINE_DELAY) begin
            @(posedge w_PCLK);
        end
        @(posedge w_PCLK) i_VS <= 1;
        #1000
        $stop();
    end

    always @(posedge i_clk) begin
        r_XCLK_z <= o_XCLK;
        r_XCLK_zz <= r_XCLK_z;
    end
    
    assign w_PCLK = r_XCLK_zz;

endmodule
