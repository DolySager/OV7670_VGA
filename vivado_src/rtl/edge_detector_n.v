`timescale 1ns / 1ps


module edge_detector_n (clk, reset_p, cp, p_edge, n_edge);
    input clk, reset_p, cp;
    output   p_edge, n_edge;

    reg ff_cur, ff_old;       

    always @ (posedge clk, posedge reset_p) begin
            if(reset_p) begin
                ff_cur <= 0;
                ff_old <= 0;
            end
            else begin
                ff_cur <= cp;                   
                ff_old <= ff_cur;
            end
    end

    assign p_edge = ({ff_cur, ff_old} == 2'b10) ? 1: 0;
    assign n_edge = ({ff_cur, ff_old} == 2'b01) ? 1: 0;

endmodule