
module BRAM_ADC_test (
    input clk, reset_p,
    input pixel_clock_pulse,
    input in_hsync, in_vsync,
    input in_display_on,
    output reg [9:0] out_addr_x,
    output reg [9:0] out_addr_y,
    output reg write_enable,
    output [3:0] vgaRed, vgaGreen, vgaBlue
);

    parameter pixel_cursor = 2'd2;
    wire hsync_nedge, vsync_nedge;
    edge_detector_n hsync_edge_detector (.clk(clk), .reset_p(reset_p), .cp(in_hsync), .n_edge(hsync_nedge));
    edge_detector_n vsync_edge_detector (.clk(clk), .reset_p(reset_p), .cp(in_vsync), .n_edge(vsync_nedge));

    reg [3:0] counter_red, counter_green, counter_blue;
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

    wire [1:0] x, y;

    wire write_enable_pedge;
    edge_detector_n write_enable_edge(.clk(clk), .reset_p(reset_p), .cp(write_enable), .p_edge(write_enable_pedge));
     

    ADC_CONTROLLER adc_con(      .clk(clk), .reset_p(reset_p),
                                    .vauxp6(vauxp6), .vauxn6(vauxn6), .vauxp15(vauxp15), .vauxn15(vauxn15),
                                    .x(x), .y(y));

    reg [8:0] adc_x, adc_y;

    always @(posedge clk, posedge reset_p) begin
        if (reset_p) begin
            adc_x = 9'd160;
            adc_y = 9'd120;
        end
        else begin
            if (write_enable_pedge) begin
                if (x == 2'd0) begin
                    adc_x = adc_x + 1;
                end
                else if (x == 2'd1) begin
                    adc_x = adc_x;
                end
                else if (x == 2'd2) begin
                    adc_x = adc_x - 1;
                end

                if (y == 2'd0) begin
                    adc_y = adc_y - 1;
                end
                else if (y == 2'd1) begin
                    adc_y = adc_y;
                end
                else if (y == 2'd2) begin
                    adc_y = adc_y + 1;
                end

                if (adc_x >= 9'd320) begin
                    adc_x = 0;
                end

                if (adc_y >= 9'd240) begin
                    adc_y = 0;
                end
                
            end
        end
    end

    reg cursor_flag;

    reg [2:0] count_cursor;

    always @(posedge clk, posedge reset_p) begin
        if (reset_p) begin
            cursor_flag = 0;
            count_cursor = 0;
        end
        else begin
            if (write_enable) begin
                if (out_addr_x == adc_x && out_addr_y == adc_y) begin 
                    cursor_flag = 1;
                end
                else begin
                    count_cursor = count_cursor +1;
                end

                if (count_cursor >= 3) begin
                    cursor_flag = 0;
                    count_cursor = 0;
                end

                if (out_addr_x == adc_x && out_addr_y == (adc_y - 1)) begin 
                    cursor_flag = 1;
                end
                else begin
                    count_cursor = count_cursor +1;
                end

/*
                if (out_addr_y == adc_y) begin
                    counter_red = 4'b0000;
                    counter_green = 4'b0000;
                    counter_blue = 4'b0000;
                end
                else begin
                    counter_red = 4'b1111;
                    counter_green = 4'b1111;
                    counter_blue = 4'b1111;
                end
                */
            end
        end
    end


    always @(posedge clk, posedge reset_p) begin
        if(reset_p) begin
            counter_red = 0;
            counter_green = 0;
            counter_blue = 0;
        end
        else begin
            if (cursor_flag) begin
                counter_red = 4'b0000;
                counter_green = 4'b0000;
                counter_blue = 4'b0000;
            end
            else begin
                counter_red = 4'b1111;
                counter_green = 4'b1111;
                counter_blue = 4'b1111;
            end
        end
    end

    assign vgaRed = counter_red;
    assign vgaGreen = counter_green;
    assign vgaBlue = counter_blue;

endmodule