module mouse_controller(
    input clk, reset_p,
    input data,
    input data_clk,
    output mouse_left_click, mouse_right_click, 
    output mouse_right_left_cursor, mouse_up_down_cursor, 
    output [7:0] mouse_move_x, mouse_move_y);


    wire data_finish_flag;

    wire [10:0] signal_1, signal_2, signal_3;

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
                                .mouse_move_x(mouse_move_x), .mouse_move_y(mouse_move_y));

endmodule

// module mouse_controller_in_vga(
//     input clk, reset_p,
//     input data,
//     input data_clk,
//     output mouse_left_click, mouse_right_click,
//     output [3:0] com,
//     output [7:0] seg_7,
//     output reg [8:0] value_x, value_y);


//     wire data_finish_flag;

//     wire [10:0] signal_1, signal_2, signal_3;
//     wire [7:0] mouse_move_x, mouse_move_y;
//     mouse_sipo ps2_mouse(
//                         .clk(clk), .reset_p(reset_p),
//                         .data(data),
//                         .data_clk(data_clk),
//                         .data_finish_flag(data_finish_flag),
//                         .signal_1(signal_1), .signal_2(signal_2), .signal_3(signal_3));


//     mouse_data_origin_Word valid_data_div(
//                                 .clk(clk), .reset_p(reset_p),
//                                 .signal_1(signal_1), .signal_2(signal_2), .signal_3(signal_3),
//                                 .mouse_left_click(mouse_left_click), .mouse_right_click(mouse_right_click), 
//                                 .mouse_right_left_cursor(mouse_right_left_cursor), .mouse_up_down_cursor(mouse_up_down_cursor), 
//                                 .mouse_move_x(mouse_move_x), .mouse_move_y(mouse_move_y));


//     wire [15:0] value; 
//     always @(posedge clk, posedge reset_p) begin
//         if (reset_p) begin
//             value_x = 0;
//             value_y = 0;
//         end
//         else begin
            
//             if (mouse_right_left_cursor) begin
//                 value_x = value_x - mouse_move_x[3:2];
//                 if (value_x >= 9'd320) begin
//                     value_x = 9'd319;
//                 end
//             end
//             else begin
//                 value_x = value_x + mouse_move_x[4:2];
//                 if (value_x <= 9'd1) begin
//                     value_x = 9'd2;
//                 end
//             end
            
//             if (!mouse_up_down_cursor) begin
//                 value_y = value_y - mouse_move_y[4:2];
//                 if (value_y <= 9'd1) begin
//                     value_y = 9'd2;
//                 end
//             end
//             else begin
//                 value_y = value_y + mouse_move_y[3:2];
//                 if (value_y >= 9'd240) begin
//                     value_y = 9'd239;
//                 end
//             end


//         end
//     end


//     assign value = {value_y[7:0], value_x[7:0]};

// endmodule

