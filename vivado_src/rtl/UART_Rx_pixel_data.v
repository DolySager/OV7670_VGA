`timescale 1ns / 1ps

/*
 * Payload information:
 *      4 bytes of UART TX per pixel:
 *          pixel_x[7:0]
 *          {pixel_y[5:0], pixel_x[9:8]}
 *          {vgaBlue[3:0], pixel_y[9:6]}
 *          {vgaRed[3:0], vgaGreen[3:0]}
 */

module UART_Rx_pixel_data_addr_and_rgb(
    input clk, reset_p,
    input uart_rx,
    output reg write_enable,
    output [9:0] pixel_addr_x, pixel_addr_y,
    output [3:0] pixel_red, pixel_green, pixel_blue
    );
    
    wire [7:0] byte_out;
    wire rx_busy;
    UART_rx_byte #(.BAUDRATE(115200)) module_UART_rx_byte(
        .clk (clk),
        .reset_p (reset_p),
        
        .uart_rx (uart_rx),
        
        .byte_out (byte_out),
        .busy (rx_busy)
    );
    
    wire rx_busy_nedge;
    edge_detector_p busy_edge_detector(
        clk, reset_p, 
        rx_busy, 
        , // pedge 
        rx_busy_nedge
    );
    
    edge_detector_p byte_count_overflow_detector(
        clk, reset_p, 
        byte_count[1], 
        , // pedge
        byte_count_overflow // nedge
    );
    
    reg [1:0] byte_count;
    reg [7:0] pixel_buffer [0:3], pixel_output [0:3];
    always @(posedge clk or posedge reset_p) begin
        if (reset_p) begin
            pixel_buffer[0] = 0;
            pixel_buffer[1] = 0;
            pixel_buffer[2] = 0;
            pixel_buffer[3] = 0;
            byte_count = 0;
        end
        else begin
            if (rx_busy_nedge) begin
                pixel_buffer[byte_count] = byte_out;
                byte_count = byte_count + 1;
            end
        end
    end
    
    always @(posedge clk or posedge reset_p) begin
        if (reset_p) begin
            pixel_output[0] = 0;
            pixel_output[1] = 0;
            pixel_output[2] = 0;
            pixel_output[3] = 0;
        end
        else begin
            if (byte_count_overflow) begin
                pixel_output[0] = pixel_buffer[0];
                pixel_output[1] = pixel_buffer[1];
                pixel_output[2] = pixel_buffer[2];
                pixel_output[3] = pixel_buffer[3];
                write_enable = 1;
            end
            else begin
                write_enable = 0;
            end
        end
    end
    
    assign pixel_addr_x = {pixel_output[1][1:0], pixel_output[0][7:0]};
    assign pixel_addr_y = {pixel_output[2][3:0], pixel_output[1][7:2]};
    assign pixel_red = pixel_output[3][7:4];
    assign pixel_green = pixel_output[3][3:0];
    assign pixel_blue = pixel_output[2][7:4];
    
endmodule
