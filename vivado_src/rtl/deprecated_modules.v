`timescale 1ns / 1ps

module vga_test_red(
    input clk, reset_p,
    output reg Hsync, Vsync,
    output [3:0] vgaRed, vgaGreen, vgaBlue);

    parameter H_IDLE = 4'b0001;
    parameter HSYNC_UP = 4'b0010;
    parameter HSYNC_DOWN = 4'b0100;
    parameter H_COLOR = 4'b1000;
    
    parameter V_IDLE = 4'b0001;
    parameter VSYNC_UP = 4'b0010;
    parameter VSYNC_DOWN = 4'b0100;
    parameter V_COLOR = 4'b1000;
    
    reg [3:0] h_state, h_state_next, v_state, v_state_next;


    wire w_25mhz;

    pixel_clock_generator mh_25(
                .clk(clk), .reset_p(reset_p),
                .clk_div_100(w_25mhz),
                .cp_div_100());
    
    reg [9:0] count_hor;
    reg [9:0] count_ver;
    reg count_e; 

    // always @(posedge clk, posedge reset_p) begin
    //     if(reset_p) begin
    //         count_hor = 0;
    //     end
    //     else begin
    //         if (w_25mhz && count_e) begin
    //             count_hor = count_hor +1;    
    //         end
    //         else if (!count_e) begin
    //             count_hor = 0;
    //         end
    //     end
    // end

    always @(posedge clk, posedge reset_p) begin
        if (reset_p) begin
            count_hor = 0;
            count_ver = 0;
        end
        else begin
            if (w_25mhz) begin
                if (count_hor >=800) begin
                    count_hor =0;
                    if (count_ver >= 521) begin
                        count_ver = 0;
                    end
                    else begin
                        count_ver = count_ver +1;
                    end
                end
                else begin
                    count_hor = count_hor +1;
                end
            end
        end
    end


    always @(posedge clk, posedge reset_p) begin
        if(reset_p) begin
            Hsync = 1;
            count_e = 1;
        end
        else begin
            if(count_hor <= 10'd127 ) begin
                Hsync = 0;
            end
            else begin
                Hsync = 1;
            end
        end
    end

    assign vgaRed = 4'hf;
    assign vgaGreen = 4'h0;
    assign vgaBlue = 4'h0;

    always @(posedge clk, posedge reset_p) begin
        if(reset_p) begin
            Vsync = 1;
            count_e = 1;
        end
        else begin
            if(count_ver <= 2 ) begin
                Vsync = 0;
            end
            else begin
                Vsync = 1;
            end
        end
    end


    // always @ (posedge clk, posedge reset_p) begin
    //     if (reset_p) begin
    //         h_state = H_IDLE;
    //         v_state = V_IDLE;
    //     end
    //     else begin
    //         h_state = h_state_next;
    //         v_state = v_state_next;
    //     end
    // end

    // always @(, posedge reset_p) begin
    //     if (reset_p) begin
    //         h_state_next = H_IDLE;
    //     end
    //     else begin
    //         case (h_state)
    //             H_IDLE : begin
    //                 h_state = 
    //             end 
    //             HSYNC_UP : begin

    //                 hsync = 1;
    //             end 
    //             HSYNC_DOWN : begin
                    
    //             end 
    //             H_COLOR : begin
                    
    //             end 
    //             default: ;
    //         endcase
    //     end
    // end



endmodule 

module vga_test_ver_1(
    input clk, reset_p,
    input [11:0] sw,
    output reg Hsync, Vsync,
    output reg [3:0] vgaRed, vgaGreen, vgaBlue);

    parameter [3:0] HSYNC_IDLE = 4'b0001;
    parameter [3:0] H_BACK_PORCH = 4'b0010;
    parameter [3:0] H_DISPALY_DATA = 4'b0100;
    parameter [3:0] H_FRONT_PORCH = 4'b1000;

    parameter [3:0] VSYNC_IDLE = 4'b0001;
    parameter [3:0] V_BACK_PORCH = 4'b0010;
    parameter [3:0] V_DISPALY_DATA = 4'b0100;
    parameter [3:0] V_FRONT_PORCH = 4'b1000;

    reg [3:0] h_state, h_state_next, v_state, v_state_next;

    always @(posedge clk, posedge reset_p) begin
        if(reset_p) begin
            h_state = HSYNC_IDLE;
            v_state = VSYNC_IDLE;
        end
        else begin
            h_state = h_state_next;
            v_state = v_state_next;            
        end
    end

    wire w_25mhz;

    pixel_clock_generator mh_25(
                .clk(clk), .reset_p(reset_p),
                .clk_div_100(w_25mhz),
                .cp_div_100());

    reg [9:0] count, count_h;
    reg count_e;
    reg [9:0] count_v;

    always @(posedge clk, posedge reset_p) begin
        if (reset_p) begin
            count = 0;
            count_v = 0;
        end
        else begin 
            if (w_25mhz) begin
                count = count +1;
                if (count >= 10'd800) begin
                    count = 0;
                    count_v = count_v + 1;
                    if(count_v >= 10'd521) begin
                        count_v = 0;
                    end
                end
            end
        end
    end

    always @(posedge clk, posedge reset_p) begin
        if (reset_p) begin
            h_state_next = HSYNC_IDLE;
            count_h = 0;
            Hsync = 0;
        end
        else begin
            case (h_state)
                HSYNC_IDLE : begin
                    if (count >= 10'd128) begin
                        h_state_next = H_BACK_PORCH;
                        Hsync = 0;
                    end
                    else begin
                        Hsync = 1;
                    end
                end
                H_BACK_PORCH : begin
                    if (count >= 10'd144) begin
                        h_state_next = H_DISPALY_DATA;
                    end
                end 
                H_DISPALY_DATA : begin
                    if (count >= 10'd784) begin
                        h_state_next = H_FRONT_PORCH;
                    end                  
                end 
                H_FRONT_PORCH : begin
                    if (count >= 10'd800) begin
                        h_state_next = HSYNC_IDLE;
                    end                    
                end  
                default: ;
            endcase
        end
    end


    always @(posedge clk, posedge reset_p) begin
        if (reset_p) begin
            v_state_next = VSYNC_IDLE;
            Vsync = 0;
        end
        else begin
            case (v_state) 
                VSYNC_IDLE: begin
                    if (count_v >= 10'd2) begin
                        Vsync = 0;
                        v_state_next = V_BACK_PORCH; 
                    end
                    else begin
                        Vsync = 1;
                    end
                end
                V_BACK_PORCH: begin
                    if (count_v >= 10'd31) begin
                        v_state_next = V_DISPALY_DATA;
                    end
                end
                V_DISPALY_DATA: begin
                    if (count_v >= 10'd511) begin
                        v_state_next = V_FRONT_PORCH;
                    end
                end
                V_FRONT_PORCH: begin
                    if (count_v >= 10'd521) begin
                        v_state_next = VSYNC_IDLE;
                    end
                end 
                default: ;
            endcase
        end
    end

    always @(posedge clk, posedge reset_p) begin
        if (reset_p) begin
            vgaRed  = 0; 
            vgaGreen = 0;
            vgaBlue = 0;            
        end
        else begin
            vgaRed  = sw[3:0]; 
            vgaGreen = sw[7:4];
            vgaBlue = sw[11:8];
        end
        
    end


endmodule

module vga_test_ver_2(
    input clk, reset_p,
    input [11:0] sw,
    output reg Hsync, Vsync,
    output reg [3:0] vgaRed, vgaGreen, vgaBlue);

    parameter [3:0] HSYNC_ACTIVE = 4'b0001;
    parameter [3:0] H_FRONT_PORCH = 4'b0010;
    parameter [3:0] H_SYNC_DOWN = 4'b0100;
    parameter [3:0] H_BACK_PORCH = 4'b1000;

    parameter [3:0] VSYNC_ACTIVE = 4'b0001;
    parameter [3:0] V_FRONT_PORCH = 4'b0010;
    parameter [3:0] V_SYNC_DOWN = 4'b0100;
    parameter [3:0] V_BACK_PORCH = 4'b1000;

    reg [3:0] h_state, h_state_next, v_state, v_state_next;

    always @(posedge clk, posedge reset_p) begin
        if(reset_p) begin
            h_state = HSYNC_ACTIVE;
            v_state = VSYNC_ACTIVE;
        end
        else begin
            h_state = h_state_next;
            v_state = v_state_next;            
        end
    end

    wire w_25mhz;

    pixel_clock_generator mh_25(
                .clk(clk), .reset_p(reset_p),
                .clk_div_100(w_25mhz),
                .cp_div_100());

    reg [10:0] count, count_h;
    reg count_e;
    reg [10:0] count_v;

    always @(posedge clk, posedge reset_p) begin
        if (reset_p) begin
            count = 0;
            count_v = 0;
        end
        else if (w_25mhz) begin           
            count = count +1;
            if (count >= 11'd800) begin
                count = 0;
                count_v = count_v + 1;
                if(count_v >= 11'd524) begin
                    count_v = 0;
                end
            end      
        end
    end

    reg H_dispaly_data, V_dispaly_data;

    always @(posedge clk, posedge reset_p) begin
        if (reset_p) begin
            h_state_next = HSYNC_ACTIVE;
            count_h = 0;
            Hsync = 1;
            H_dispaly_data = 0;
        end
        else begin
            case (h_state)
                HSYNC_ACTIVE : begin
                    if (count >= 11'd640) begin
                        h_state_next = H_FRONT_PORCH;                                              
                    end
                    else begin
                        Hsync = 1;
                        H_dispaly_data = 1;
                    end
                end
                H_FRONT_PORCH : begin
                    if (count >= 11'd656) begin
                        h_state_next = H_SYNC_DOWN;
                    end
                    else begin
                        H_dispaly_data = 0;  
                    end
                end 
                H_SYNC_DOWN : begin
                    if (count >= 11'd752) begin
                        h_state_next = H_BACK_PORCH;
                    end
                    else begin
                        Hsync = 0;                       
                    end                  
                end 
                H_BACK_PORCH : begin
                    if (count >= 11'd799) begin
                        h_state_next = HSYNC_ACTIVE;
                    end
                    else begin
                        Hsync = 1;
                    end                    
                end  
                default: ;
            endcase
        end
    end


    always @(posedge clk, posedge reset_p) begin
        if (reset_p) begin
            v_state_next = VSYNC_ACTIVE;
            Vsync = 1;
            V_dispaly_data = 0;
        end
        else begin
            case (v_state) 
                VSYNC_ACTIVE: begin
                    if (count_v >= 11'd480) begin                        
                        v_state_next = V_FRONT_PORCH;                       
                    end
                    else begin
                        V_dispaly_data = 1;
                        Vsync = 1;
                    end
                end
                V_FRONT_PORCH: begin
                    if (count_v >= 11'd491) begin
                        v_state_next = V_SYNC_DOWN;
                    end
                    else begin
                        V_dispaly_data = 0; 
                    end
                end
                V_SYNC_DOWN: begin
                    if (count_v >= 11'd493) begin
                        v_state_next = V_BACK_PORCH;
                    end
                    else begin
                        Vsync = 0;
                    end
                end
                V_BACK_PORCH: begin
                    if (count_v >= 11'd523) begin
                        v_state_next = VSYNC_ACTIVE;
                    end
                    else begin
                        Vsync = 1;
                    end
                end 
                default: ;
            endcase
        end
    end

    always @(posedge clk, posedge reset_p) begin
        if (reset_p) begin
            vgaRed  = 0; 
            vgaGreen = 0;
            vgaBlue = 0;            
        end
        else begin
            if(H_dispaly_data && V_dispaly_data) begin
                vgaRed  = sw[3:0]; 
                vgaGreen = sw[7:4];
                vgaBlue = sw[11:8];
            end
            else begin
                vgaRed  = 0; 
                vgaGreen = 0;
                vgaBlue = 0;                 
            end
    end    
    end


endmodule

module vga_test_ver_3(
    input clk, reset_p,
    input [11:0] sw,
    output  Hsync, Vsync,
    output reg [3:0] vgaRed, vgaGreen, vgaBlue);


    wire w_25mhz;

    wire H_display_on, V_display_on;
    
    wire h_sync_nedge;

    pixel_clock_generator mh_25(
                .clk(clk), .reset_p(reset_p),
                .clk_div_100(w_25mhz),
                .cp_div_100());

    edge_detector_n  edge_usec (.clk(clk), .reset_p(reset_p), .cp(Hsync), .n_edge(h_sync_nedge));
              

    h_sync_generator h_sync_module(
                            .clk(clk), .reset_p(reset_p),
                            .p_clk_cp(w_25mhz),
                            .Hsync(Hsync), .H_display_on(H_display_on));


    v_sync_generator v_sync_module(
                            .clk(clk), .reset_p(reset_p),
                            .h_sync_cp(h_sync_nedge),
                            .Vsync(Vsync), .V_display_on(V_display_on));


    always @(posedge clk, posedge reset_p) begin
        if (reset_p) begin
            vgaRed  = 0; 
            vgaGreen = 0;
            vgaBlue = 0;            
        end
        else begin
            if(H_display_on && V_display_on) begin
                vgaRed  = sw[3:0]; 
                vgaGreen = sw[7:4];
                vgaBlue = sw[11:8];
            end
            else begin
                vgaRed  = 0; 
                vgaGreen = 0;
                vgaBlue = 0;                 
            end
        end    
    end


endmodule
