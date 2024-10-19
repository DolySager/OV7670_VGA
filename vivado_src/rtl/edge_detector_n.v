`timescale 1ns / 1ps


module edge_detector_n (
    input i_clk, i_reset, i_cp,
    output   o_posedge, o_negedge
);

    reg ff_cur, ff_old;       

    always @ (posedge i_clk, posedge i_reset) begin
            if(i_reset) begin
                ff_cur <= 0;
                ff_old <= 0;
            end
            else begin
                ff_cur <= i_cp;                   
                ff_old <= ff_cur;
            end
    end

    assign o_posedge = ({ff_cur, ff_old} == 2'b10) ? 1: 0;
    assign o_negedge = ({ff_cur, ff_old} == 2'b01) ? 1: 0;

endmodule