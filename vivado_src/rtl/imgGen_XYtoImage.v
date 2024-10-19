`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/23 12:43:15
// Design Name: 
// Module Name: imgGen_XYtoImage
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module imgGen_XYtoImage(
    input clk, reset_p,
    input signed [7:0] offset_x, offset_y,
    output write_enable,
    output reg [9:0] addr_x, addr_y,
    output reg [3:0] vgaRed, vgaGreen, vgaBlue
    );
    
    reg [3:0] value_x, value_y;
    reg [19:0] time_counter;
    reg generate_frame;
    
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
    
    // Every 10ms, sweep frame by address
    reg generate_frame;
    assign write_enable = generate_frame;
    always @(posedge clk or posedge reset_p) begin
        if (reset_p) begin
            generate_frame = 0;
            addr_x = 0;
            addr_y = 0;
        end
        else begin
            if (time_counter == 0) begin
                generate_frame = 1;
            end
            else if (generate_frame) begin
                addr_x = addr_x + 1;
                if (addr_x >= 320) begin
                    addr_x = 0;
                    addr_y = addr_y + 1;
                    if (addr_y >= 240) begin
                        addr_y = 0;
                        generate_frame = 0;
                    end
                end
            end
        end
    end
    
    // generate image using value and address
    always @(posedge clk or posedge reset_p) begin
        if (reset_p) begin
            vgaRed = 0;
            vgaGreen = 0;
            vgaBlue = 0;
        end
        else begin
            vgaRed = addr_x[7:4] - value_x;
            vgaBlue = addr_y[7:4] - value_y;
            vgaGreen = 0;
        end
    end
    
endmodule
