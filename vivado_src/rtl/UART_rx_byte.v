`timescale 1ns / 1ps

// UART Rx one packet
module UART_rx_byte(
    input clk, reset_p,
    input uart_rx,
    output reg [7:0] byte_out,
    output reg busy
    );
    
    parameter BAUDRATE = 9600;
    localparam SYSCLK_HZ = 100_000_000;
    localparam SYSCLK_COUNT_PER_BITS = SYSCLK_HZ / BAUDRATE;
    
    // UART RX line edge detector
    wire uart_rx_pedge, uart_rx_nedge;
    edge_detector_p uart_rx_edge_detector(
        clk, reset_p, 
        uart_rx, 
        uart_rx_pedge, 
        uart_rx_nedge
    );
    
    // state machine
    parameter ST_IDLE = 3'b0001;        // same as ST_STOP (stop bit condition)
    parameter ST_START = 3'b0010;
    parameter ST_DATA = 3'b0100;
    reg [2:0] state, next_state;
    always @(posedge clk or posedge reset_p) begin
        if (reset_p) state = ST_IDLE;
        else state = next_state;
    end
    
    // state machine main part
    reg [3:0] bit_count;
    reg [15:0] baud_count;
    always @(posedge clk or posedge reset_p) begin
        if (reset_p) begin
            next_state = ST_IDLE;
            byte_out = 0;
            busy = 0;
            bit_count = 0;
            baud_count = 0;
        end
        else begin
            case (state)
                ST_IDLE: begin
                    busy = 0;
                    if (uart_rx_nedge) begin
                        next_state = ST_START;
                    end
                end
                
                ST_START: begin
                    busy = 1;
                    baud_count = baud_count + 1;
                    if (baud_count == SYSCLK_COUNT_PER_BITS) begin
                        baud_count = 0;
                        next_state = ST_DATA;
                    end
                end
                
                ST_DATA: begin
                    busy = 1;
                    baud_count = baud_count + 1;
                    if (baud_count >= SYSCLK_COUNT_PER_BITS) begin          // end of BCLK
                        baud_count = 0;
                        bit_count = bit_count + 1;
                    end
                    if (bit_count >= 8) begin       // end of byte receive
                        next_state = ST_IDLE;
                        baud_count = 0;
                        bit_count = 0;
                    end
                    
                    if (baud_count == SYSCLK_COUNT_PER_BITS >> 1) begin    // halfway of BCLK
                        byte_out = {uart_rx, byte_out[7:1]};
                    end
                end
            endcase
        end
    end 
endmodule
