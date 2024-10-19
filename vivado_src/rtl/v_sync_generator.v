`timescale 1ns / 1ps


module v_sync_generator(
    input clk, reset_p,
    input h_sync_cp,
    output reg Vsync, V_display_on,
    output [9:0] count_v);

    

    parameter V_ACTIVE = 10'd480;
    parameter V_FRONT_PORCH = 10'd491;
    parameter V_SYNC = 10'd493;
    parameter V_BACK_PORCH = 10'd524;


    reg [9:0] count;
    always @ (posedge clk, posedge reset_p) begin
        if(reset_p) begin
            count = 523;
            Vsync = 1;
            V_display_on = 0;
        end
        else if(h_sync_cp) begin
            if(count >= V_BACK_PORCH) begin
                count = 0;
            end
            else begin
                count = count +1;
            end
                       
            if (count < V_ACTIVE) begin
                Vsync = 1;
                V_display_on = 1;
            end
            else if (count < V_FRONT_PORCH) begin
                Vsync = 1;
                V_display_on = 0;
            end
            else if (count < V_SYNC) begin
                Vsync = 0;
                V_display_on = 0;
            end
            else if (count < V_BACK_PORCH) begin
                Vsync = 1;
                V_display_on = 0;
            end            

        end
    end
    
    assign count_v = (count < V_ACTIVE) ? count : 0;

endmodule
