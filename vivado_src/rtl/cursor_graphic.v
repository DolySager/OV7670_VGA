module cursor_graphic(
    input clk,
    input reset_p,
    input [3:0] i_bram_r,i_bram_g,i_bram_b,
    input mouse_left_click,
    input [9:0] pixel_addr_x, pixel_addr_y,
    input [9:0] cursor_addr_x, cursor_addr_y,
    output reg [3:0] o_vga_r, o_vga_g, o_vga_b);

    function [11:0]bit_to_12bit;
        input bit;
        begin
            bit_to_12bit = {12{bit}};
        end
        
    endfunction


    wire [1:0] lut_out;
    wire signed [10:0] temp_x, temp_y; 
    cursor_graphic_ROM cursor_graphic_ROM1(
                        .a( { ((temp_y >= 0) ? temp_y[3:0] : 4'b0) , ((temp_x >= 0) ? temp_x[2:0] : 3'b0) }), 
                        .clk(clk), 
                        .qspo(lut_out)
    );

    localparam LUT_MAX_ADDR_X = 6 ;
    localparam LUT_MAX_ADDR_Y = 10 ;

    assign temp_x = pixel_addr_x - cursor_addr_x;
    assign temp_y = pixel_addr_y - cursor_addr_y;

    always @(*) begin
        if ( (temp_x < 0 || temp_x >= LUT_MAX_ADDR_X) || (temp_y < 0 || temp_y >= LUT_MAX_ADDR_Y) ) {o_vga_r, o_vga_g, o_vga_b} = {i_bram_r,i_bram_g,i_bram_b};
        else if (lut_out == 2'b00) {o_vga_r, o_vga_g, o_vga_b} = {i_bram_r,i_bram_g,i_bram_b};
        else if (lut_out == 2'b01) {o_vga_r, o_vga_g, o_vga_b} = {4'hc, 4'hc, 4'hc};
        else if (lut_out == 2'b10) {o_vga_r, o_vga_g, o_vga_b} = {4'hf, 4'hf, 4'hf};
        else if (lut_out == 2'b11) {o_vga_r, o_vga_g, o_vga_b} = {4'h0, 4'h0, 4'h0};
        else {o_vga_r, o_vga_g, o_vga_b} = 0;
    end

//{i_bram_r,i_bram_g,i_bram_b};                                                      
//mouse_left_click ? bit_to_12bit(~pixel_bit_color) : bit_to_12bit(pixel_bit_color); 
//mouse_left_click ? bit_to_12bit(~pixel_bit_color) : bit_to_12bit(pixel_bit_color); 


endmodule