`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/21 17:10:01
// Design Name: 
// Module Name: tb_axi_sccb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_axi_sccb(

    );
    
    wire io_sio_d, o_sio_c, o_sccb_e;
    reg clk, reset_n;
    
    myip_SCCB_Transceiver_v1_0 DUT (
    	.s00_axi_aclk(clk),
        .s00_axi_aresetn(reset_n),
        .io_sio_d(io_sio_d),
        .o_sio_c(o_sio_c),    
        .o_sccb_e(o_sccb_e)
        );
    
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    initial begin
        reset_n = 1;
        reset_n = 0;
        #10 reset_n = 1;
        
        force DUT.myip_SCCB_Transceiver_v1_0_S00_AXI_inst.slv_reg1 = {8'b0, 8'hcc, 8'hcc, 8'hcc};
        force DUT.myip_SCCB_Transceiver_v1_0_S00_AXI_inst.slv_reg0 = 32'h00000001;
        #10 release DUT.myip_SCCB_Transceiver_v1_0_S00_AXI_inst.slv_reg0;
        #100000;
        $stop;
        
    end
endmodule
