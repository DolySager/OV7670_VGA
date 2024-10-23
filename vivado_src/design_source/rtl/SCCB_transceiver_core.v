`timescale 1ns / 1ps


// detect phase posedge and starts operation (finishes operation regardless of phase input signal change)
// o_phase_done signal pulse outputted when the phase is finished
module SCCB_transceiver_core(
    input i_clk,                   // this is posedge clock triggered module
    input i_reset_p,               // posedge triggered reset
    input [7:0] i_main_addr,       // address of module which data sent to via SCCB
    input [7:0] i_sub_addr,        // sub address within module which data sent to via SCCB
    input [7:0] i_data,            // data being sent via SCCB
    input [2:0] i_phase,           // phase[0]: 3-phase write, phase[1]: 2-phase write, phase[2]: 2-phase read
    inout io_sio_d,                // SCCB data line
    output reg o_sio_c,            // SSCB clock line
    output reg o_sccb_e,           // SCCB enable line (active low)
    output reg [7:0] o_data,       // byte received via SCCB
    output reg [2:0] o_phase_done  // indicates requested phase is finished
    );
    
    parameter SYS_CLK_FREQ = 100_000_000;   // system clock frequency
    parameter SCCB_CLK_FREQ = 100_000;      // SCCB clock freqeuncy
    
    reg [3:0] mode;             // mode[0]: write data mode, mode[1]: read data mode, mode[2]: start bit mode, mode[3] stop bit mode
    reg sio_d_out;              // sio_d output signal 
    wire sio_d_in;              // sio_d input signal
    reg sio_d_oe_m;             // asserted when master outputs data to sio_d (active low)
    reg sio_c_en;               // asserted when sio_c is active (active low)
    integer sio_c_counter;      // to generate sio_c clock
    reg [2:0] sio_d_bitCount;   // to count number of bits sent
    reg dontcarebit_mode;       // to indicate time to assert don't care bit (during write) (active low)
    reg nabit_mode;             // to indicate time to assert NA bit (during read) (active low)
    wire [7:0] i_byte;          // byte put on sci_d line during write operation
    reg [1:0] i_byte_selector;  // 0x = put data on sci_d, 10 = put i_main_addr on sci_d, 11 = put i_sub_addr on sci_d
    reg [2:0] phase_reg;        // stores phase operation execution state
    reg [3:0] mode_start;       // indicates mode operation has finished
    
    // sci_d byte type selector
    assign i_byte = i_byte_selector[1] ? (i_byte_selector[0] ? i_sub_addr : i_main_addr) : i_data;
    
    // edge detector
    // TODO: wire declaration needed
    edge_detector_n sio_d_oe_m_edge_detect_inst (i_clk, i_reset_p, sio_d_oe_m, sio_d_oe_m_posedge, sio_d_oe_m_negedge);
    edge_detector_n o_sio_c_edge_detect_inst (i_clk, i_reset_p, o_sio_c, o_sio_c_posedge, o_sio_c_negedge);
    edge_detector_n o_sccb_e_edge_detect_inst (i_clk, i_reset_p, o_sccb_e, o_sccb_e_posedge, o_sccb_e_negedge);
    edge_detector_n sio_d_out_edge_detect_inst (i_clk, i_reset_p, sio_d_out, sio_d_out_posedge, sio_d_out_negedge);
    
    edge_detector_n mode0_edge_detect_inst (i_clk, i_reset_p, mode[0], mode0_posedge, mode0_negedge);
    edge_detector_n mode1_edge_detect_inst (i_clk, i_reset_p, mode[1], mode1_posedge, mode1_negedge);
    edge_detector_n mode2_edge_detect_inst (i_clk, i_reset_p, mode[2], mode2_posedge, mode2_negedge);
    edge_detector_n mode3_edge_detect_inst (i_clk, i_reset_p, mode[3], mode3_posedge, mode3_negedge);
    
    edge_detector_n i_phase0_edge_detect_inst (i_clk, i_reset_p, i_phase[0], i_phase0_posedge, i_phase0_negedge);
    edge_detector_n i_phase1_edge_detect_inst (i_clk, i_reset_p, i_phase[1], i_phase1_posedge, i_phase1_negedge);
    edge_detector_n i_phase2_edge_detect_inst (i_clk, i_reset_p, i_phase[2], i_phase2_posedge, i_phase2_negedge);
    
    edge_detector_n sio_d_bitCount2_edge_detect_inst (i_clk, i_reset_p, sio_d_bitCount[2], sio_d_bitCount2_posedge, sio_d_bitCount2_negedge);
    
    // phase operation
    always @(posedge i_clk or posedge i_reset_p) begin
        if (i_reset_p) begin
            phase_reg <= 3'b000;
            mode_start <= 4'b0000;
            o_phase_done <= 3'b000;
            i_byte_selector <= 2'b00;
        end
        else begin

            // 3-phase write operation
            if (i_phase0_posedge)                                               begin phase_reg[0] <= 1; mode_start[2] <= 1; i_byte_selector <= 2'b00; end    // start bit
            else if (phase_reg[0] && mode2_negedge && i_byte_selector == 2'b00) begin mode_start[0] <= 1; i_byte_selector = 2'b10; end // write main address
            else if (phase_reg[0] && mode0_negedge && i_byte_selector == 2'b10) begin mode_start[0] <= 1; i_byte_selector <= 2'b11; end   //write sub address 
            else if (phase_reg[0] && mode0_negedge && i_byte_selector == 2'b11) begin mode_start[0] <= 1; i_byte_selector <= 2'b00; end   //write data 
            else if (phase_reg[0] && mode0_negedge && i_byte_selector == 2'b00) begin mode_start[3] <= 1; end   //stop bit
            else if (phase_reg[0] && mode3_negedge)                             begin phase_reg[0] <= 0; o_phase_done[0] <= 1; end
            
            // 2-phase write operation
            else if (i_phase1_posedge)                                          begin phase_reg[1] <= 1; mode_start[2] <= 1; i_byte_selector <= 2'b00; end // start bit
            else if (phase_reg[1] && mode2_negedge && i_byte_selector == 2'b00) begin mode_start[0] <= 1; i_byte_selector = 2'b10; end // write main address
            else if (phase_reg[1] && mode0_negedge && i_byte_selector == 2'b10) begin mode_start[0] <= 1; i_byte_selector <= 2'b11; end   //write sub address 
            else if (phase_reg[1] && mode0_negedge && i_byte_selector <= 2'b11) begin mode_start[3] <= 1; end
            else if (phase_reg[1] && mode3_negedge)                             begin phase_reg[1] <= 0; o_phase_done[1] <= 1; end
            
            // 2-phase read operation
            else if (i_phase2_posedge)                                          begin phase_reg[2] <= 1; mode_start[2] <= 1; i_byte_selector <= 2'b00; end
            else if (phase_reg[2] && mode2_negedge && i_byte_selector == 2'b00) begin mode_start[0] <= 1; i_byte_selector = 2'b10; end // write main address
            else if (phase_reg[2] && mode0_negedge && i_byte_selector == 2'b10) begin mode_start[1] <= 1; i_byte_selector <= 2'b11; end   //read data
            else if (phase_reg[2] && mode1_negedge && i_byte_selector <= 2'b11) begin mode_start[3] <= 1; end   // stop bit
            else if (phase_reg[2] && mode3_negedge)                             begin phase_reg[2] <= 0; o_phase_done[2] <= 1; end
            
            // pulse generation
            else                                                                begin mode_start <= 4'b0000; o_phase_done <= 3'b000; end

        end
    end
    
    // sio_d inout buffer (refer to Figure 4-1 of OV7670 datasheet)
    assign io_sio_d = sio_d_oe_m ? 1'bz : sio_d_out;
    assign sio_d_in = sio_d_oe_m ? io_sio_d : 1'b1;
    
    // sio_c generation
    always @(posedge i_clk or posedge i_reset_p) begin
        if (i_reset_p) begin
            sio_c_counter <= 0;
            o_sio_c <= 1;
        end
        else begin
            if (!sio_c_en) begin
                if (sio_c_counter >= (SYS_CLK_FREQ / SCCB_CLK_FREQ / 2 - 1) ) begin
                    sio_c_counter <= 0;
                    o_sio_c <= ~o_sio_c;
                end
                else if (mode) begin
                    sio_c_counter <= sio_c_counter + 1;
                end
            end
            else begin
                sio_c_counter <= 0;
            end
        end
    end
    
    // mode operation (write data, read data, start bit, or stop bit)
    always @(posedge i_clk or posedge i_reset_p) begin
        if (i_reset_p) begin
            sio_d_oe_m <= 1'b1;
            sio_c_en <= 1'b1;
            sio_d_out <= 1'b1;
            o_sccb_e <= 1'b1;
            dontcarebit_mode <= 1'b1;
            nabit_mode <= 1'b1;
            sio_d_bitCount <= 3'b000;
            o_data <= 0;
            mode <= 4'b0000;
        end
        else begin

            // write operation
            if (mode_start[0]) begin mode[0] <= 1; sio_d_oe_m <= 0; sio_d_bitCount <= 0; sio_c_en <= 0; dontcarebit_mode <= 1; sio_d_out <= i_byte[7]; end
            else if (mode[0] && o_sio_c_negedge && dontcarebit_mode) sio_d_out <= i_byte[7 - sio_d_bitCount];
            else if (mode[0] && o_sio_c_posedge && dontcarebit_mode) sio_d_bitCount <= sio_d_bitCount + 1;
            else if (mode[0] && sio_d_bitCount2_negedge) dontcarebit_mode <= 0;
            else if (mode[0] && o_sio_c_negedge && !dontcarebit_mode && !sio_d_oe_m) begin sio_d_oe_m <= 1; sio_d_out <= 0; end
            else if (mode[0] && o_sio_c_negedge && !dontcarebit_mode && sio_d_oe_m) begin dontcarebit_mode <= 1; mode[0] <= 0; sio_c_en <= 1; sio_d_out <= 0; end

            //read operation
            else if (mode_start[1]) begin mode[1] <= 1; sio_d_oe_m <= 1; sio_d_bitCount <= 0; o_data <= 0; sio_c_en <= 0; nabit_mode <= 1; sio_d_out <= 1; end 
            else if (mode[1] && o_sio_c_posedge && nabit_mode) o_data[7 - sio_d_bitCount] <= sio_d_in;
            else if (mode[1] && o_sio_c_negedge && nabit_mode) sio_d_bitCount <= sio_d_bitCount + 1;
            else if (mode[1] && sio_d_bitCount2_negedge) begin nabit_mode <= 0; sio_d_oe_m <= 0; sio_d_out <= 1; end
            // else if (mode[1] && o_sio_c_negedge && !nabit_mode && sio_d_oe_m) begin sio_d_oe_m <= 0; sio_d_out <= 1; end    // bit count already overflows during previous SCL negedge
            else if (mode[1] && o_sio_c_negedge && !nabit_mode && !sio_d_oe_m) begin nabit_mode <= 1; mode[1] <= 0; sio_c_en <= 1; sio_d_out <= 0; end

            // start bit
            else if (mode_start[2]) begin mode[2] <= 1; sio_d_out <= 1; sio_d_oe_m <= 0; sio_c_en <= 1; end
            else if (mode[2] && sio_d_oe_m_negedge) o_sccb_e <= 0;
            else if (mode[2] && o_sccb_e_negedge) sio_d_out <= 0;
            else if (mode[2] && sio_d_out_negedge) sio_c_en <= 0;
            else if (mode[2] && o_sio_c_negedge) mode[2] <= 0;

            // stop bit
            else if (mode_start[3]) begin mode[3] <= 1; sio_c_en <= 0; sio_d_out <= 0; sio_d_oe_m <= 0; end 
            else if (mode[3] && o_sio_c_posedge) begin sio_c_en <= 1; sio_d_out <= 1; end
            else if (mode[3] && sio_d_out_posedge) o_sccb_e <= 1;
            else if (mode[3] && o_sccb_e_posedge) sio_d_oe_m <= 1;
            else if (mode[3] && sio_d_oe_m_posedge) mode[3] <= 0;
        end
    end
    
endmodule
