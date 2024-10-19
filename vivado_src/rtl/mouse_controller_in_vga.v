`timescale 1ns / 1ps

module mouse_controller_in_vga(
    input clk, reset_p,
    input data,
    input data_clk,
    output mouse_left_click, mouse_right_click,
    output [9:0] value_x, value_y);

    parameter MAX_ADDR_X = 320;
    parameter MAX_ADDR_Y = 240;

    wire data_finish_flag;

    wire [10:0] signal_1, signal_2, signal_3;
    wire signed [7:0] mouse_move_x, mouse_move_y;
    
    wire mouse_x_overflow, mouse_y_overflow;
    wire mouse_right_left_cursor, mouse_up_down_cursor;
    mouse_sipo ps2_mouse(
                        .clk(clk), .reset_p(reset_p),
                        .data(data),
                        .data_clk(data_clk),
                        .data_finish_flag(data_finish_flag),
                        .signal_1(signal_1), .signal_2(signal_2), .signal_3(signal_3));


    mouse_data_origin_Word valid_data_div(
                                .clk(clk), .reset_p(reset_p),
                                .signal_1(signal_1), .signal_2(signal_2), .signal_3(signal_3),
                                .mouse_left_click(mouse_left_click), .mouse_right_click(mouse_right_click), 
                                .mouse_right_left_cursor(mouse_right_left_cursor), .mouse_up_down_cursor(mouse_up_down_cursor),
                                .mouse_x_overflow (mouse_x_overflow), .mouse_y_overflow (mouse_y_overflow),
                                .mouse_move_x(mouse_move_x), .mouse_move_y(mouse_move_y));


    reg signed [7:0] int_move_x, int_move_y;
    reg signed [15:0] coord_buffer_x, coord_buffer_y;
    always @(posedge clk, posedge reset_p) begin
        if (reset_p) begin
            coord_buffer_x = 0;
            coord_buffer_y = 0;
        end
        else begin
            // if there is overflow set to max value (8-bit signed max is 255)
            if (mouse_x_overflow) begin
                if (mouse_right_left_cursor) int_move_x = 127;
                else int_move_x = -127;
            end
            else int_move_x = mouse_move_x;
            
            if (mouse_y_overflow) begin
                if (mouse_up_down_cursor) int_move_y = 127;
                else int_move_y = -127;
            end
            else int_move_y = mouse_move_y;

            // add mouse value
            coord_buffer_x = coord_buffer_x + int_move_x;       
            coord_buffer_y = coord_buffer_y - int_move_y;       // y-axis is inverted
            
            // if mouse coordinate exceed min or max value, set it back within boundary
            if (coord_buffer_x < 0) coord_buffer_x = 0;
            else if (coord_buffer_x[12:3] >= MAX_ADDR_X) coord_buffer_x[12:3] = MAX_ADDR_X - 1;
            
            if (coord_buffer_y < 0) coord_buffer_y = 0;
            else if (coord_buffer_y[12:3] >= MAX_ADDR_Y) coord_buffer_y[12:3] = MAX_ADDR_Y - 1;
        end
    end
    
    assign value_x = coord_buffer_x[9:0];
    assign value_y = coord_buffer_y[9:0];

endmodule