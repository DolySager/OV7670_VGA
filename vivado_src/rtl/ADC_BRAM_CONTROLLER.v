// from adc value  bram adress control module
module ADC_BRAM_CONTROLLER (
    input clk, reset_p,
    input vauxp6, vauxn6, vauxp15, vauxn15);

    wire [1:0] x, y;

    ADC_CONTROLLER adc_con(      .clk(clk), .reset_p(reset_p),
                                    .vauxp6(vauxp6), .vauxn6(vauxn6), .vauxp15(vauxp15), .vauxn15(vauxn15),
                                    .x(x), .y(y));

    reg [8:0] address_x , address_y;

    always @(posedge clk, posedge reset_p) begin
        if (reset_p) begin
            address_x = 0;
            address_y = 0;
        end
        else begin
            
        end
    end



endmodule