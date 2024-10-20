`timescale 1ns / 1ps


module VGA_controller(
    input clk, reset_p,
    input pixel_clock_pulse,
    input [3:0] in_vgaRed, in_vgaGreen, in_vgaBlue,
    output  Hsync, Vsync, out_display_on,
    output reg [3:0] out_vgaRed, out_vgaGreen, out_vgaBlue,
    output [9:0] count_h, count_v
    );

    wire H_display_on, V_display_on;
    wire h_sync_nedge;

    edge_detector_n edge_usec (.i_clk(clk), .i_reset(reset_p), .i_cp(Hsync), .o_negedge(h_sync_nedge));
              
    h_sync_generator h_sync_module(
                            .clk(clk), .reset_p(reset_p),
                            .p_clk_cp(pixel_clock_pulse),
                            .Hsync(Hsync), .H_display_on(H_display_on),
                            .count_h (count_h) );

    v_sync_generator v_sync_module(
                            .clk(clk), .reset_p(reset_p),
                            .h_sync_cp(h_sync_nedge),
                            .Vsync(Vsync), .V_display_on(V_display_on),
                            .count_v (count_v) );

    always @(posedge clk, posedge reset_p) begin
        if (reset_p) begin
            out_vgaRed  = 0; 
            out_vgaGreen = 0;
            out_vgaBlue = 0;            
        end
        else begin
            if(out_display_on) begin
                out_vgaRed  = in_vgaRed; 
                out_vgaGreen = in_vgaGreen;
                out_vgaBlue = in_vgaBlue;
            end
            else begin
                out_vgaRed  = 0; 
                out_vgaGreen = 0;
                out_vgaBlue = 0;                 
            end
        end    
    end

    assign out_display_on = H_display_on && V_display_on;
    
endmodule