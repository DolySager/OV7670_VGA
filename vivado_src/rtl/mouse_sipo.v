
module mouse_sipo(
    input clk, reset_p,
    input data,
    input data_clk,
    output reg data_finish_flag,
    output [10:0] signal_1, signal_2, signal_3, signal_4);
    // output [3:0] com,
    // output [7:0] seg_7

    reg [43:0] sipo;
    reg [43:0] buffer;
    reg [5:0] count;
    reg mouse_data;

    wire data_clk_nedge;

    edge_detector_n right_click_edge ( .clk(clk), .reset_p(reset_p), .cp(data_clk), .n_edge(data_clk_nedge));

    
    assign signal_1 =  sipo[43:33];
    assign signal_2 =  sipo[32:22];
    assign signal_3 =  sipo[21:11];
    assign signal_4 =  sipo[10:0];


    always @(posedge clk, posedge reset_p) begin
        if (reset_p) begin
            sipo <= 0;
            buffer <= 0;
            mouse_data <= 0;
            count <= 0;
        end
        else begin
            mouse_data <= data;
            if (data_clk_nedge) begin
                buffer <= {buffer[42:0], mouse_data};
                count <= count + 1;
            end

            if (count >= 6'd44) begin
                sipo <= buffer;
                buffer <= 0;
                count <= 0;
                data_finish_flag <= 1;
            end
            else begin
                sipo <= 0;
                data_finish_flag <= 0;
            end

        end
    end
    
endmodule
