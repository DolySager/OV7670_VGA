module top_mouse_test(
    input clk, reset_p,
    input data,
    input data_clk,
    output [3:0] com,
    output [7:0] seg_7);

    wire mouse_left_click, mouse_right_click, mouse_right_left_cursor, mouse_up_down_cursor;
    wire [7:0] mouse_move_x, mouse_move_y;

    mouse_controller_in_vga mouse_test(
                        .clk(clk), .reset_p(reset_p),
                        .data(data),
                        .data_clk(data_clk),
                        .mouse_left_click(mouse_left_click), .mouse_right_click(mouse_right_click), 
                        .value_x(mouse_move_x), .value_y(mouse_move_y));

    // reg [7:0] value_x, value_y;
    reg [7:0] value_x, value_y;
    reg [15:0] value; 
    always @(posedge clk, posedge reset_p) begin
        if (reset_p) begin
            value_x = 0;
            value_y = 0;
            value = 0;
        end
        else begin
            if (mouse_left_click) begin
                value = value + 1;
            end

            if (mouse_right_left_cursor) begin
                value = value + mouse_move_x[3];
            end
            else begin
                value = value - mouse_move_x[3];
            end
            


        end
    end

    // assign value = {value_y, value_x};

    fnd_4digit_cntr test( .clk(clk), .reset_p(reset_p), .com(com), .value(value), .seg_7(seg_7) );


endmodule

module fnd_4digit_cntr( clk, reset_p, com , value, seg_7 );
input clk, reset_p ;
input [15:0] value;
output [3:0] com;
output [7:0] seg_7;

reg [3:0] hex_value;

    ring_counter_bcd com_0 (.clk(clk), .reset_p(reset_p), . q(com));    
    
    decoder_7seg_behavioral  seg0(  .hex_value(hex_value),  .seg_7(seg_7));    

    always @ (posedge clk) begin                        
               case(com)
                        4'b1110: hex_value = value[3:0];
                        4'b1101: hex_value = value[7:4];
                        4'b1011: hex_value = value[11:8];
                        4'b0111: hex_value = value[15:12];
               endcase
    end


endmodule


 module   ring_counter_bcd (clk, reset_p,  q);
input clk, reset_p;
output  reg [3:0] q;

    reg [16:0] clk_div;
    always @(posedge clk) clk_div = clk_div +1;                        
   wire  clk_div_16_p;
   
    edge_detector_n de_clk (.clk(clk), .reset_p(reset_p), .cp(clk_div[16]), .p_edge(clk_div_16_p));

always @(posedge clk , posedge reset_p)begin                        
    if(reset_p) q = 4'b1110;                                                          
    else if (clk_div_16_p)  
               if (q == 4'b0111) q = 4'b1110;
               else q = {q[2:0], 1'b1};
    end 
    
endmodule

module decoder_7seg_behavioral(                 
    input [3:0] hex_value,                      
    output reg [7:0] seg_7);                    

    always @(hex_value) begin                   
        case(hex_value)                         
                              
            4'b0000 : seg_7 = 8'b0000_0011;     
            4'b0001 : seg_7 = 8'b1001_1111;     
            4'b0010 : seg_7 = 8'b0010_0101;     
            4'b0011 : seg_7 = 8'b0000_1101;     
            4'b0100 : seg_7 = 8'b1001_1001;     
            4'b0101 : seg_7 = 8'b0100_1001;     
            4'b0110 : seg_7 = 8'b0100_0001;     
            4'b0111 : seg_7 = 8'b0001_1111;     
            4'b1000 : seg_7 = 8'b0000_0001;     
            4'b1001 : seg_7 = 8'b0001_1001;     
            4'b1010 : seg_7 = 8'b0001_0001;     
            4'b1011 : seg_7 = 8'b1100_0001;     
            4'b1100 : seg_7 = 8'b0110_0011;     
            4'b1101 : seg_7 = 8'b1000_0101;     
            4'b1110 : seg_7 = 8'b0110_0001;     
            4'b1111 : seg_7 = 8'b0111_0001;     
        endcase                                
    end                                        

endmodule 


module edge_detector_p (clk, reset_p, cp, p_edge, n_edge);
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