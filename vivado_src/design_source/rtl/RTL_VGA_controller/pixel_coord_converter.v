module pixel_coord_converter
    (input [9:0] addr_x, addr_y,
     output [9:0] addr_x_scaler, addr_y_scaler);

    parameter scale_factor = 2;
    localparam bit_shift = $clog2(scale_factor);

    assign addr_x_scaler = addr_x>>bit_shift;
    assign addr_y_scaler = addr_y>>bit_shift;
endmodule