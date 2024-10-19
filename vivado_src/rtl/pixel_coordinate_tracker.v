`timescale 1ns / 1ps


// Tracks current pixel coordinates on monitor
module pixel_coordinate_tracker (
    input clk, reset_p,
    input Hsync, Vsync, pixel_clock_pulse, in_display_on,
    output reg [9:0] pixel_coord_x, pixel_coord_y
);
    // in_display_on = h_displayon && v_displayon
    wire Hsync_nedeg, display_on_nedge, Vsync_nedge;
    edge_detector_n Hsync_edge_module (.clk(clk), .reset_p(reset_p), .cp(Hsync), .n_edge(Hsync_nedeg));
    edge_detector_n display_on_edge_module (.clk(clk), .reset_p(reset_p), .cp(in_display_on), .n_edge(display_on_nedge));
    edge_detector_n Vsync_edge_module (.clk(clk), .reset_p(reset_p), .cp(Vsync), .n_edge(Vsync_nedge));

    reg count_1_x, count_1_y;

    always @(posedge clk or posedge reset_p) begin
        if (reset_p) begin
            pixel_coord_x = 0;
            pixel_coord_y = 0;
            count_1_x = 0;
            count_1_y = 0;
        end
        else begin
            if (display_on_nedge) begin
                pixel_coord_x = 0;
                count_1_x = 0;
                pixel_coord_y = pixel_coord_y + count_1_y;
                count_1_y = 1;
            end

            if (pixel_clock_pulse && in_display_on) begin
                pixel_coord_x = pixel_coord_x + count_1_x;
                count_1_x = 1;
            end

            if(Vsync_nedge) begin
                pixel_coord_x = 0;
                pixel_coord_y = 0;
                count_1_x = 0;
                count_1_y = 0;
            end
        end
    end

endmodule




/*

module pixel_coordinate_tracker_1 (
    input clk, reset_p,
    input Hsync, Vsync, pixel_clock_pusle, in_display_on,
    output reg [9:0] pixel_coord_x, pixel_coord_y
);
    // in_display_on = h_displayon && v_displayon
    wire Hsync_nedeg, display_on_nedge, Vsync_nedge;
    edge_detector_n Hsync_edge_module (.clk(clk), .reset_p(reset_p), .cp(Hsync), .n_edge(Hsync_nedeg));
    edge_detector_n display_on_edge_module (.clk(clk), .reset_p(reset_p), .cp(in_display_on), .n_edge(display_on_nedge));
    edge_detector_n Vsync_edge_module (.clk(clk), .reset_p(reset_p), .cp(Vsync), .n_edge(Vsync_nedge));

    

    always @(posedge clk or posedge reset_p) begin
        if (reset_p) begin
            pixel_coord_x = 10'h3ff;
            pixel_coord_y = 10'h3ff;
        end
        else begin
            if (Hsync_nedeg) begin
                pixel_coord_x = 10'h3ff;
                pixel_coord_y = pixel_coord_y +1;
            end

            if (pixel_clock_pusle && in_display_on) begin
                pixel_coord_x = pixel_coord_x +1;
            end

            if(Vsync_nedge) begin
                pixel_coord_x = 10'h3ff;
                pixel_coord_y = 10'h3ff;
            end
        end
    end

endmodule

module pixel_coordinate_tracker_flag (
    input clk, reset_p,
    input Hsync, Vsync, pixel_clock_pusle, in_display_on,
    output reg [9:0] pixel_coord_x, pixel_coord_y
);
    // in_display_on = h_displayon && v_displayon
    wire Hsync_nedeg, Hsync_pedeg, display_on_nedge, Vsync_nedge, Vsync_pedge;
    edge_detector_n Hsync_edge_module (.clk(clk), .reset_p(reset_p), .cp(Hsync), .p_edge(Hsync_pedeg),.n_edge(Hsync_nedeg));
    edge_detector_n display_on_edge_module (.clk(clk), .reset_p(reset_p), .cp(in_display_on), .n_edge(display_on_nedge));
    edge_detector_n Vsync_edge_module (.clk(clk), .reset_p(reset_p), .cp(Vsync), .p_edge(Vsync_pedge),.n_edge(Vsync_nedge));

    reg hsync_count_flag, vsync_count_flag;

    always @(posedge clk or posedge reset_p) begin
        if (reset_p) begin
            hsync_count_flag = 0;
            vsync_count_flag = 0;
        end
        else begin
            if (Hsync_pedeg) begin
                hsync_count_flag = 1;
            end
            else if (Hsync_nedeg) begin
                hsync_count_flag = 0;
            end

            if (Vsync_pedge ) begin
                vsync_count_flag = 1;
            end
            else if (Vsync_nedge) begin
                vsync_count_flag = 0;
            end
        end
    end

    always @(posedge clk , posedge reset_p) begin
        if (reset_p) begin
            pixel_coord_x = 0;
            pixel_coord_y = 0;
        end
        else if (vsync_count_flag) begin
            
        end
    end

endmodule
*/
