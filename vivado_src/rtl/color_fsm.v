`timescale 1ns / 1ps

module color_fsm(
    input clk, reset_p,
    input pixel_clock_pulse,
    input i_hsync, i_vsync,
    input data, data_clk,
    output o_write_enable,
    output reg [9:0] addr_x, addr_y,
    output reg [3:0] o_vgaRed, o_vgaGreen, o_vgaBlue
    );
    
    wire cursor_write_enable;
    wire [8:0] cursor_rgb_addr_x, cursor_rgb_addr_y;
    wire [3:0] cursor_rgb_red, cursor_rgb_green, cursor_rgb_blue;
    reg [5:0] state, next_state;
    
    // cursor_graphic cursor_module (
    //     .clk (clk),
    //     .reset_p (reset_p),
    //     .current_graphic_state (state),
    //     .cursor_addr_x (cursor_addr_x), 
    //     .cursor_addr_y (cursor_addr_y),
        
    //     .write_enable (cursor_write_enable),
    //     .rgb_addr_x (cursor_rgb_addr_x),
    //     .rgb_addr_y (cursor_rgb_addr_y),
    //     .rgb_red (cursor_rgb_red),
    //     .rgb_green (cursor_rgb_green),
    //     .rgb_blue (cursor_rgb_blue)
    // );
    reg [3:0] vgaRed, vgaGreen, vgaBlue;
    // reg [3:0] value_x, value_y;
    // reg [19:0] time_counter;
    // reg generate_frame;
    // reg internal_write_enable;

    wire mouse_left_click, mouse_right_click;
    wire [8:0] cursor_x, cursor_y;
    mouse_cursor cusor_module(
                                .clk(clk), 
                                .reset_p(reset_p),
                                .pixel_clock_pulse(pixel_clock_pulse),
                                .in_hsync(i_hsync), 
                                .in_vsync(i_vsync),
                                .data(data),
                                .data_clk(data_clk),
                                .mouse_left_click(mouse_left_click), 
                                .mouse_right_click(mouse_right_click),
                                .write_enable(o_write_enable),
                                .i_red(vgaRed), 
                                .i_green(vgaGreen), 
                                .i_blue(vgaBlue),
                                .out_addr_x(addr_x),
                                .out_addr_y(addr_y),
                                .o_vgaRed(o_vgaRed), 
                                .o_vgaGreen(o_vgaGreen), 
                                .o_vgaBlue(o_vgaBlue),
                                .value_x(cursor_x), 
                                .value_y(cursor_y));
    
/*
    // change value per 10ms
    always @(posedge clk or posedge reset_p) begin
        if (reset_p) begin
            time_counter = 0;
            value_x = 0;
            value_y = 0;
        end
        else begin
            time_counter = time_counter + 1;
            if (time_counter >= 'd1_000_000) begin
                time_counter = 0;
                
                value_x = value_x + 1;
                if (value_x >= 320) begin
                    value_x = 0;
                    value_y = value_y + 1;
                    if (value_y >= 240) begin
                        value_y = 0;
                    end
                end
            end
        end
        
    end
*/

    // Every 10ms, sweep frame by address;
    // always @(posedge clk or posedge reset_p) begin
    //     if (reset_p) begin
    //         generate_frame = 0;
    //         addr_x = 0;
    //         addr_y = 0;
    //     end
    //     else if (1) begin
    //         if (time_counter == 0) begin
    //             generate_frame = 1;
    //         end
    //         else if (generate_frame) begin
    //             addr_x = addr_x + 1;
    //             if (addr_x >= 320) begin
    //                 addr_x = 0;
    //                 addr_y = addr_y + 1;
    //                 if (addr_y >= 240) begin
    //                     addr_y = 0;
    //                     generate_frame = 0;
    //                 end
    //             end
    //         end
    //     end
    // end
    
    parameter IDLE  = 6'b000001;
    parameter RED   = 6'b000010;
    parameter GREEN = 6'b000100;
    parameter BLUE  = 6'b001000;
    parameter WHITE = 6'b010000;
    parameter CURSOR = 6'b010000;    



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
                    if(addr_x < 160 && addr_y < 120)begin
                        vgaRed = 4'b1111;
                        vgaGreen = 4'b0000;
                        vgaBlue = 4'b0000;
                    end
                    else if (addr_x >= 160 && addr_y < 120) begin
                        vgaRed = 4'b0000;
                        vgaGreen = 4'b1111;
                        vgaBlue = 4'b0000;
                    end
                    else if (addr_x < 160 && addr_y >= 120) begin
                        vgaRed = 4'b0000;
                        vgaGreen = 4'b0000;
                        vgaBlue = 4'b1111;
                    end
                    else begin
                        vgaRed = 4'b1111;
                        vgaGreen = 4'b1111;
                        vgaBlue = 4'b1111;
                    end
                    
                    if (cursor_x < 160 && cursor_y < 120) begin
                        if (mouse_left_click) begin
                            next_state = RED;
                        end
                    end
                    if (cursor_x >= 160 && cursor_y < 120) begin
                        if (mouse_left_click) begin
                            next_state = GREEN;
                        end
                    end
                    if (cursor_x < 160 && cursor_y >= 120) begin
                        if (mouse_left_click) begin
                            next_state = BLUE;
                        end
                    end
                    if (cursor_x >= 160 && cursor_y >= 120) begin
                        if (mouse_left_click) begin
                            next_state = WHITE;
                        end
                    end
                end

                RED: begin

                    vgaRed = 4'b1111;
                    vgaGreen = 4'b0000;
                    vgaBlue = 4'b0000;

                    if (mouse_right_click) begin
                        next_state = IDLE;
                    end
                end

                GREEN: begin

                    vgaRed = 4'b0000;
                    vgaGreen = 4'b1111;
                    vgaBlue = 4'b0000;

                    if (mouse_right_click) begin
                        next_state = IDLE;
                    end
                end

                BLUE: begin

                    vgaRed = 4'b0000;
                    vgaGreen = 4'b0000;
                    vgaBlue = 4'b1111;

                    if (mouse_right_click) begin
                        next_state = IDLE;
                    end
                end

                WHITE: begin

                    vgaRed = 4'b1111;
                    vgaGreen = 4'b1111;
                    vgaBlue = 4'b1111;

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

endmodule
