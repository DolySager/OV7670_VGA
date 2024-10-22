`timescale 1ns / 1ps


module tb_SCCB_transceiver_core(

    );
    
    reg i_clk, i_reset_p;
    reg [7:0] i_main_addr, i_sub_addr, i_data;
    reg [2:0] i_phase;
    wire io_sio_d;
    wire o_sio_c, o_sccb_e;
    wire [7:0] o_data;
    wire [2:0] o_phase_done;
    
    SCCB_transceiver_core DUT (
        i_clk,
        i_reset_p,
        i_main_addr,
        i_sub_addr,
        i_data, 
        i_phase,
        io_sio_d,        
        o_sio_c,    
        o_sccb_e,   
        o_data,
        o_phase_done
        );
        
    initial begin
        i_clk = 0;
        i_reset_p = 1;
        i_main_addr = 0; i_sub_addr = 0; i_data = 0;
        i_phase = 0;
    end
    
    always #5 i_clk = ~i_clk;
    
    initial begin
        #10 i_reset_p = 0;
        #100
        i_main_addr = 8'h42; i_sub_addr = 8'hb4; i_data = 8'b10101010;
        i_phase[0] = 1;
        @(posedge o_phase_done[0]) i_phase[0] = 0;
        #100 $finish;
    end
    
endmodule
