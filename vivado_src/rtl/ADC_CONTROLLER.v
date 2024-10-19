// adc_controller x,y value  0, 1, 2  x( 0 left, 1 idle 2 right) y(0 down, 1 idle, 2 up)
module ADC_CONTROLLER(
    input clk, reset_p,
    input vauxp6, vauxn6, vauxp15, vauxn15,
    output reg [1:0] x, y);

    parameter VALUE_CUT_1400 = 12'd1400;
    parameter VALUE_CUT_2800 = 12'd2800;
    parameter VALUE_CUT_4096 = 12'd4095;

    wire [4:0] channel_out;
    wire eoc_out;
    wire [15:0] do_out;
    xadc_wiz_0 adc_joystick(
          .daddr_in({2'b0, channel_out}),            // Address bus for the dynamic reconfiguration port
          .dclk_in(clk),             // Clock input for the dynamic reconfiguration port
          .den_in(eoc_out),              // Enable Signal for the dynamic reconfiguration port
          .reset_in(reset_p),            // Reset signal for the System Monitor control logic
          .vauxp6(vauxp6),              // Auxiliary channel 6
          .vauxn6(vauxn6),
          .vauxp15(vauxp15),             // Auxiliary channel 15
          .vauxn15(vauxn15),
          .channel_out(channel_out),         // Channel Selection Outputs
          .do_out(do_out),              // Output data bus for dynamic reconfiguration port
          .eoc_out(eoc_out));

    wire eoc_out_pedge, eoc_out_nedge;
    edge_detector_n  ed1 (.clk(clk), .reset_p(reset_p), .cp(eoc_out), .p_edge(eoc_out_pedge), .n_edge(eoc_out_nedge));

    reg [23:0] do_out_avr_x, do_out_avr_y;

    reg [7:0] count_x, count_y;

    reg [11:0] adc_value_x, adc_value_y;

    always @(posedge clk, posedge reset_p) begin
        if (reset_p) begin
            do_out_avr_x = 0;
            do_out_avr_y = 0;
            adc_value_x = 0;
            adc_value_y = 0;
            count_x = 0;
            count_y = 0;
            
        end
        else if (eoc_out_pedge) begin           
            case(channel_out[3:0])
                6: begin
                    do_out_avr_x = do_out_avr_x + do_out;
                    count_x = count_x +1;
                    if (count_x >= 8'd255) begin
                        count_x = 0;
                        adc_value_x = do_out_avr_x[23:12];
                        do_out_avr_x = 0;
                    end
                end 
                15: begin 
                    do_out_avr_y = do_out_avr_y + do_out;
                    count_y = count_y +1;
                    if (count_y >= 8'd255) begin
                        count_y = 0;
                        adc_value_y = do_out_avr_y[23:12];
                        do_out_avr_y = 0;
                    end
                end
            endcase

        end
    end



    always @(posedge clk, posedge reset_p) begin
        if (reset_p) begin
            x = 1;
            y = 1; 
        end
        else if (eoc_out_pedge) begin
            if (adc_value_x <= VALUE_CUT_1400) begin
                x = 0;
            end
            else if (adc_value_x <= VALUE_CUT_2800) begin
                x = 1;
            end
            else if (adc_value_x <= VALUE_CUT_4096) begin
                x = 2;
            end

            if (adc_value_y <= VALUE_CUT_1400) begin
                y = 0;
            end
            else if (adc_value_y <= VALUE_CUT_2800) begin
                y = 1;
            end
            else if (adc_value_y <= VALUE_CUT_4096) begin
                y = 2;
            end
        end
    end






endmodule