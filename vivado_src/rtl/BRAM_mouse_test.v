`timescale 1ns / 1ps

module mouse_cursor_v1 (
    input clk, reset_p,
    input pixel_clock_pulse,
    input in_hsync, in_vsync,
    input data,
    input data_clk,
    input [3:0] i_red, i_green, i_blue,
    output reg write_enable,
    output [8:0] value_x, value_y,
    output reg [9:0] out_addr_x,
    output reg [9:0] out_addr_y,
    output [3:0] o_vgaRed, o_vgaGreen, o_vgaBlue);

    parameter pixel_cursor = 2'd2;
    wire hsync_nedge, vsync_nedge;
    edge_detector_n hsync_edge_detector (.clk(clk), .reset_p(reset_p), .cp(in_hsync), .n_edge(hsync_nedge));
    edge_detector_n vsync_edge_detector (.clk(clk), .reset_p(reset_p), .cp(in_vsync), .n_edge(vsync_nedge));

    reg [3:0] vgaRed, vgaGreen, vgaBlue;
    integer counter;
    //integer pixel_counter;
    
    // address manipulator
    always @(posedge clk or posedge reset_p) begin
        if (reset_p) begin
            out_addr_x = 0;    
            out_addr_y = 0;
        end
        else begin
            if (write_enable) begin
                out_addr_x = out_addr_x + 1;
                if (out_addr_x >= 320) begin
                    out_addr_x = 0;
                    out_addr_y = out_addr_y + 1;
                end
            end
            else begin
                out_addr_x = 0;
                out_addr_y = 0;
            end
        end
    end

    always @(posedge clk or posedge reset_p) begin
        if (reset_p) begin
            write_enable = 1;
        end
        else if (write_enable) begin
            if (out_addr_y >= 240) begin
                write_enable = 0;
            end
        end
        else if (vsync_nedge) begin
            write_enable = 1;
        end
    end


    wire write_enable_pedge;
    edge_detector_n write_enable_edge(.clk(clk), .reset_p(reset_p), .cp(write_enable), .p_edge(write_enable_pedge));
    
    wire mouse_right_left_cursor, mouse_up_down_cursor;
    wire mouse_left_click, mouse_right_click;

    mouse_controller_in_vga test_monitor(
                                            .clk(clk), .reset_p(reset_p),
                                            .data(data),
                                            .data_clk(data_clk),
                                            .mouse_left_click(mouse_left_click), .mouse_right_click(mouse_right_click),
                                            .value_x(value_x), .value_y(value_y));

    reg cursor_flag;

    reg [2:0] count_cursor;


    always @(posedge clk, posedge reset_p) begin
        if (reset_p) begin
            cursor_flag = 0;
            count_cursor = 0;
        end
        else begin
            if (write_enable) begin
                if (out_addr_x == value_x && out_addr_y == value_y) begin 
                    cursor_flag = 1;
                end
                else begin
                    count_cursor = count_cursor +1;
                end

                if (count_cursor >= 3) begin
                    cursor_flag = 0;
                    count_cursor = 0;
                end

                if (out_addr_x == value_x && out_addr_y == (value_y - 1)) begin 
                    cursor_flag = 1;
                end
                else begin
                    count_cursor = count_cursor +1;
                end
            end
        end
    end

    parameter IDLE  = 6'b000001;
    parameter RED   = 6'b000010;
    parameter GREEN = 6'b000100;
    parameter BLUE  = 6'b001000;
    parameter WHITE = 6'b010000;
    parameter CURSOR = 6'b010000;    

    reg [5:0] state, next_state;
    
    always @(posedge clk or posedge reset_p) begin
        if (reset_p) state = IDLE;
        else state = next_state;
    end

    // next state circuit
    always @(posedge clk or posedge reset_p) begin
        if (reset_p) begin
            next_state = IDLE;
            vgaRed = 0;
            vgaGreen = 0;
            vgaBlue = 0;
        end
        else begin
            case (state)
                IDLE: begin
                    if(out_addr_x < 160 && out_addr_y < 120)begin
                        if (cursor_flag) begin
                            vgaRed = 4'b0000;
                            vgaGreen = 4'b0000;
                            vgaBlue = 4'b0000;
                        end
                        else begin
                            vgaRed = 4'b1111;
                            vgaGreen = 4'b0000;
                            vgaBlue = 4'b0000;
                        end
                    end
                    else if (out_addr_x >= 160 && out_addr_y < 120) begin
                        if (cursor_flag) begin
                            vgaRed = 4'b0000;
                            vgaGreen = 4'b0000;
                            vgaBlue = 4'b0000;
                        end
                        else begin
                            vgaRed = 4'b0000;
                            vgaGreen = 4'b1111;
                            vgaBlue = 4'b0000;
                        end 
                    end
                    else if (out_addr_x < 160 && out_addr_y >= 120) begin
                        if (cursor_flag) begin
                            vgaRed = 4'b0000;
                            vgaGreen = 4'b0000;
                            vgaBlue = 4'b0000;
                        end
                        else begin
                            vgaRed = 4'b0000;
                            vgaGreen = 4'b0000;
                            vgaBlue = 4'b1111;
                        end 
                    end
                    else begin
                        if (cursor_flag) begin
                            vgaRed = 4'b0000;
                            vgaGreen = 4'b0000;
                            vgaBlue = 4'b0000;
                        end
                        else begin
                            vgaRed = 4'b1111;
                            vgaGreen = 4'b1111;
                            vgaBlue = 4'b1111;
                        end 
                    end
                    
                    if (value_x < 160 && value_y < 120) begin
                        if (mouse_left_click) begin
                            next_state = RED;
                        end
                    end
                    if (value_x >= 160 && value_y < 120) begin
                        if (mouse_left_click) begin
                            next_state = GREEN;
                        end
                    end
                    if (value_x < 160 && value_y >= 120) begin
                        if (mouse_left_click) begin
                            next_state = BLUE;
                        end
                    end
                    if (value_x >= 160 && value_y >= 120) begin
                        if (mouse_left_click) begin
                            next_state = WHITE;
                        end
                    end
                end

                RED: begin
                    if (cursor_flag) begin
                        vgaRed = 4'b0000;
                        vgaGreen = 4'b0000;
                        vgaBlue = 4'b0000;
                    end
                    else begin
                        vgaRed = 4'b1111;
                        vgaGreen = 4'b0000;
                        vgaBlue = 4'b0000;
                    end
                    

                    if (mouse_right_click) begin
                        next_state = IDLE;
                    end
                end

                GREEN: begin
                    if (cursor_flag) begin
                        vgaRed = 4'b0000;
                        vgaGreen = 4'b0000;
                        vgaBlue = 4'b0000;
                    end
                    else begin
                        vgaRed = 4'b0000;
                        vgaGreen = 4'b1111;
                        vgaBlue = 4'b0000;
                    end

                    

                    if (mouse_right_click) begin
                        next_state = IDLE;
                    end
                end

                BLUE: begin
                    if (cursor_flag) begin
                        vgaRed = 4'b0000;
                        vgaGreen = 4'b0000;
                        vgaBlue = 4'b0000;
                    end
                    else begin
                        vgaRed = 4'b0000;
                        vgaGreen = 4'b0000;
                        vgaBlue = 4'b1111;
                    end
                    

                    if (mouse_right_click) begin
                        next_state = IDLE;
                    end
                end

                WHITE: begin
                    if (cursor_flag) begin
                        vgaRed = 4'b0000;
                        vgaGreen = 4'b0000;
                        vgaBlue = 4'b0000;
                    end
                    else begin
                        vgaRed = 4'b1111;
                        vgaGreen = 4'b1111;
                        vgaBlue = 4'b1111;
                    end

                    if (mouse_right_click) begin
                        next_state = IDLE;
                    end
                end
                // CURSOR: begin
                //     o_write_enable = cursor_write_enable;
                //     addr_x = cursor_rgb_addr_x; addr_y = cursor_rgb_addr_y;
                //     vgaRed = cursor_rgb_red; vgaGreen = cursor_rgb_green; vgaBlue = cursor_rgb_blue;
                // end

                default: next_state = IDLE;
            endcase
        end
    end





    // always @(posedge clk, posedge reset_p) begin
    //     if(reset_p) begin
    //         counter_red = 0;
    //         counter_green = 0;
    //         counter_blue = 0;
    //     end
    //     else begin
    //         if (cursor_flag) begin
    //             counter_red = 4'b0000;
    //             counter_green = 4'b0000;
    //             counter_blue = 4'b0000;
    //         end
    //         else begin
    //             counter_red = i_red;
    //             counter_green = i_green;
    //             counter_blue = i_blue;
    //         end
    //     end
    // end

    assign o_vgaRed = vgaRed;
    assign o_vgaGreen = vgaGreen;
    assign o_vgaBlue = vgaBlue;

endmodule
