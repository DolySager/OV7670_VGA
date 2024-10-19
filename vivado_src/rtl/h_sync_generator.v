`timescale 1ns / 1ps


module h_sync_generator(
    input clk, reset_p,
    input p_clk_cp,
    output reg Hsync, H_display_on,
    output [9:0] count_h);

    

    parameter H_ACTIVE = 10'd640;
    parameter H_FRONT_PORCH = 10'd656;
    parameter H_SYNC = 10'd752;
    parameter H_BACK_PORCH = 10'd800;


    reg [9:0] count;
    always @ (posedge clk, posedge reset_p) begin
        if(reset_p) begin
            count = 10'd799;
            Hsync = 1;
            H_display_on = 0;
        end
        else if (p_clk_cp) begin
            if (count >= H_BACK_PORCH) begin
                count = 0;
            end
            else begin
                count = count +1;
            end

            if (count < H_ACTIVE) begin
                Hsync = 1;
                H_display_on = 1;
            end
            else if (count < H_FRONT_PORCH) begin
                Hsync = 1;
                H_display_on = 0;
            end
            else if (count < H_SYNC) begin
                Hsync = 0;
                H_display_on = 0;
            end
            else if (count < H_BACK_PORCH) begin
                Hsync = 1;
                H_display_on = 0;
            end            

        end
    end

    assign count_h = (count < H_ACTIVE) ? count : 0;

endmodule
