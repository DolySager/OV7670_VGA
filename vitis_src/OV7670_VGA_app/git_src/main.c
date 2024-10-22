#include <stdio.h>
#include "xil_printf.h"
#include "platform.h"
#include "xparameters.h"
#include "sleep.h"

#define BASEADDR 				XPAR_MYIP_SCCB_TRANSCEIVER_0_S00_AXI_BASEADDR
#define OV7670_MAIN_ADDR 		0x21
#define OV7670_WRITE_ADDR		OV7670_MAIN_ADDR << 1
#define OV7670_READ_ADDR		OV7670_MAIN_ADDR << 1 | 0x01

void myip_SCCB_transceiver_threePhaseWrite (UINTPTR BaseAddress, u8 main_addr, u8 sub_addr, u8 data_in);
void myip_SCCB_transceiver_twoPhaseWrite (UINTPTR BaseAddress, u8 main_addr, u8 sub_addr);
u8 myip_SCCB_transceiver_twoPhaseRead (UINTPTR BaseAddress, u8 main_addr);
void writeRegister(u8 sub_addr, u8 data_in);
void OV7670_init();

int main()
{
    init_platform();
//    usleep(3000000);
    u8 value;

    OV7670_init();


    /*
//    0x32 : HREF
//		Bit[7:6]:HREF edge offset to data output
//		Bit[5:3]:HREF end 3 LSB (high 8 MSB at register HSTOP)
//		Bit[2:0]:HREF start 3 LSB (high 8 MSB at register HSTART)
//    */
//    writeRegister(0x32, 0x00);
//
//	myip_SCCB_transceiver_threePhaseWrite(XPAR_MYIP_SCCB_TRANSCEIVER_0_S00_AXI_BASEADDR, 0x42, 0x12, 0b00000100);
//
//	/*
//	 0x40 : COM15
//		Bit[7:6]:Data format - output full range enable
//		0x: Output range: [10] to [F0]
//		10: Output range: [01] to [FE]
//		11: Output range: [00] to [FF]
//		Bit[5:4]:RGB 555/565 option (must set COM7[2] = 1 and COM7[0] = 0)
//		x0: Normal RGB output
//		01: RGB 565, effective only when RGB444[1] is low
//		11: RGB 555, effective only when RGB444[1] is low
//		Bit[3:0]:Reserved
//	 */
//	myip_SCCB_transceiver_threePhaseWrite(XPAR_MYIP_SCCB_TRANSCEIVER_0_S00_AXI_BASEADDR, 0x42, 0x40, 0b00010000);
//
//	/*
//	 0x8C : RGB444
//	 	Bit[7:2]:Reserved
//		Bit[1]:RGB444 enable, effective only when COM15[4] is high
//		0:Disable
//		1:Enable
//		Bit[0]:RGB444 word format
//		0:xR GB
//		1:RG Bx
//	 */
//	myip_SCCB_transceiver_threePhaseWrite(XPAR_MYIP_SCCB_TRANSCEIVER_0_S00_AXI_BASEADDR, 0x42, 0x8C, 0b00000011);
//
//	myip_SCCB_transceiver_threePhaseWrite(XPAR_MYIP_SCCB_TRANSCEIVER_0_S00_AXI_BASEADDR, 0x42, 0x0C, 0b01000000);
//
//	/*
//	 0x01 : BLUE
//	 	 AWB – Blue channel gain setting Range: [00] to [FF]
//	 */
//	myip_SCCB_transceiver_threePhaseWrite(XPAR_MYIP_SCCB_TRANSCEIVER_0_S00_AXI_BASEADDR, 0x42, 0x01, 0x80);
//
//	/*
//	 0x02 : RED
//	 	 AWB – Red channel gain setting Range: [00] to [FF]
//	 */
//	myip_SCCB_transceiver_threePhaseWrite(XPAR_MYIP_SCCB_TRANSCEIVER_0_S00_AXI_BASEADDR, 0x42, 0x02, 0x80);
//
//	/*
//	 0x2A : EXHCH
//		Bit[7:4]:4 MSB for dummy pixel insert in horizontal direction
//		Bit[3:2]:HSYNC falling edge delay 2 MSB
//		Bit[1:0]:HSYNC rising edge delay 2 MSB
//	 */
//	myip_SCCB_transceiver_threePhaseWrite(XPAR_MYIP_SCCB_TRANSCEIVER_0_S00_AXI_BASEADDR, 0x42, 0x2A, 0b00000000);
//
//	/*
//	 0x2B : EXHCL
//		8 LSB for dummy pixel insert in horizontal direction
//	 */
//	myip_SCCB_transceiver_threePhaseWrite(XPAR_MYIP_SCCB_TRANSCEIVER_0_S00_AXI_BASEADDR, 0x42, 0x2B, 0b00000000);
//
//	/*
//	 0x70 : SCALING_XSC
//	 	Bit[7]:Test_pattern[0] - works with test_pattern[1]
//	 	test_pattern(SCALING_XSC[7], SCALING_YSC[7]):00: No test output, 01: Shifting "1", 10: 8-bar color bar, 11: Fade to gray color bar
//		Bit[6:0]:Horizontal scale factor
//	 */
//	myip_SCCB_transceiver_threePhaseWrite(XPAR_MYIP_SCCB_TRANSCEIVER_0_S00_AXI_BASEADDR, 0x42, 0x70, 0b00111001);
//
//	/*
//	 0x71 : SCALING_YSC
//	 	Bit[7]:Test_pattern[1] - works with test_pattern[0]
//	 	test_pattern(SCALING_XSC[7], SCALING_YSC[7]):00: No test output, 01: Shifting "1", 10: 8-bar color bar, 11: Fade to gray color bar
//		Bit[6:0]:Vertical scale factor
//	 */
//	myip_SCCB_transceiver_threePhaseWrite(XPAR_MYIP_SCCB_TRANSCEIVER_0_S00_AXI_BASEADDR, 0x42, 0x71, 0b00110101);

	while(1)
	{
	}

    cleanup_platform();
    return 0;
}

void OV7670_init(){
	writeRegister(0x12, 0x80); 	//reset	 	reset
	usleep(1000000);			//delay		delay
	writeRegister(0x12, 0x04); 	//COM7	 	set RGB
	writeRegister(0x11, 0x80);	//CLKRC		internal PLL matches input clock
	writeRegister(0x0C, 0x00);	//COM3		default settings
	writeRegister(0x3E, 0x00);	//COM14		no scaling, normal pclock
	writeRegister(0x04, 0x00);	//COM1		disable CCIR656
	writeRegister(0x40, 0xD0);	//COM15		RGB565, full output range
//	writeRegister(0x8C, 0x02);	//RGB444	set rgb444 mode (XRGB)
//	writeRegister(0x8C, 0x03);	//RGB444	set rgb444 mode (RGBX)
	writeRegister(0x3A, 0x04);	//TSLB		set correct output data sequence (magic)
	writeRegister(0x14, 0x18);	//COM9		MAX AGC value x4
	writeRegister(0x4F, 0xB3);	//MTX1		all of these are magical matrix coefficients
	writeRegister(0x50, 0xB3);	//MTX2		all of these are magical matrix coefficients
	writeRegister(0x51, 0x00);	//MTX3		all of these are magical matrix coefficients
	writeRegister(0x52, 0x3D);	//MTX4		all of these are magical matrix coefficients
	writeRegister(0x53, 0xA7);	//MTX5		all of these are magical matrix coefficients
	writeRegister(0x54, 0xE4);	//MTX6		all of these are magical matrix coefficients
	writeRegister(0x58, 0x9E);	//MTXS		all of these are magical matrix coefficients
	writeRegister(0x3D, 0xC0);	//COM13		sets gamma enable, does not preserve reserved bits, may be wrong?
	writeRegister(0x17, 0x14);	//HSTART	start high 8 bits
	writeRegister(0x18, 0x02);	//HSTOP		stop high 8 bits //these kill the odd colored line
	writeRegister(0x32, 0x80);	//HREF		edge offset
	writeRegister(0x19, 0x03);	//VSTART	start high 8 bits
	writeRegister(0x1A, 0x7B);	//VSTOP		stop high 8 bits
	writeRegister(0x03, 0x0A);	//VREF		vsync edge offset
	writeRegister(0x0F, 0x41);	//COM6		reset timings
	writeRegister(0x1E, 0x00);	//MVFP		disable mirror / flip //might have magic value of 03
	writeRegister(0x33, 0x0B);	//CHLF		Array Current Control magic value from the internet
	writeRegister(0x3C, 0x78);	//COM12		no HREF when VSYNC low
	writeRegister(0x69, 0x00);	//GFIX		fix gain control
	writeRegister(0x74, 0x00);	//REG74		Digital gain control
	writeRegister(0xB0, 0x84);	//RSVD		magic value from the internet *required* for good color
	writeRegister(0xB1, 0x0C);	//ABLC1		ABLC (Automatic Black Level Calibration)
	writeRegister(0xB2, 0x0E);	//RSVD		more magic internet values
	writeRegister(0xB3, 0x80);	//THL_ST	ABLC Target
	writeRegister(0x70, 0x3A);	//	mystery scaling numbers
	writeRegister(0x71, 0x35);	//	mystery scaling numbers
	writeRegister(0x72, 0x11);	//	mystery scaling numbers
	writeRegister(0x73, 0xF0);	//	mystery scaling numbers
	writeRegister(0xA2, 0x02);	//	mystery scaling numbers
	writeRegister(0x7A, 0x20);	//	gamma curve values
	writeRegister(0x7B, 0x10);	//	gamma curve values
	writeRegister(0x7C, 0x1E);	//	gamma curve values
	writeRegister(0x7E, 0x5A);	//	gamma curve values
	writeRegister(0x7F, 0x69);	//	gamma curve values
	writeRegister(0x80, 0x76);	//	gamma curve values
	writeRegister(0x81, 0x80);	//	gamma curve values
	writeRegister(0x82, 0x88);	//	gamma curve values
	writeRegister(0x83, 0x8F);	//	gamma curve values
	writeRegister(0x84, 0x96);	//	gamma curve values
	writeRegister(0x85, 0xA3);	//	gamma curve values
	writeRegister(0x86, 0xAF);	//	gamma curve values
	writeRegister(0x87, 0xC4);	//	gamma curve values
	writeRegister(0x88, 0xD7);	//	gamma curve values
	writeRegister(0x89, 0xE8);	//	gamma curve values
	writeRegister(0x13, 0xE0);	//	disable AGC / AEC
	writeRegister(0x00, 0x00);	//	set gain reg to 0 for AGC
	writeRegister(0x10, 0x00);	//	set ARCJ reg to 0
	writeRegister(0x0D, 0x40);	//	magic reserved bit for COM4
	writeRegister(0x14, 0x18);	//	4x gain + magic bit
	writeRegister(0xA5, 0x05);	//	50Hz Banding Step Limit
	writeRegister(0xAB, 0x07);	//	60Hz Banding Step Limit
	writeRegister(0x24, 0x95);	//	AGC upper limit
	writeRegister(0x25, 0x33);	//	AGC lower limit
	writeRegister(0x26, 0xE3);	//	AGC/AEC fast mode op region
	writeRegister(0x9F, 0x78);	//	Histogram-based AEC/AGC Control 1
	writeRegister(0xA0, 0x68);	//	Histogram-based AEC/AGC Control 2
	writeRegister(0xA1, 0x03);	//	magic
	writeRegister(0xA6, 0xD8);	//	Histogram-based AEC/AGC Control 3
	writeRegister(0xA7, 0xD8);	//	Histogram-based AEC/AGC Control 4
	writeRegister(0xA8, 0xF0);	//	Histogram-based AEC/AGC Control 5
	writeRegister(0xA9, 0x90);	//	Histogram-based AEC/AGC Control 6
	writeRegister(0xAA, 0x94);	//	AEC algorithm selection
	writeRegister(0x13, 0xE5);	//	enable AGC / AEC
}

void writeRegister(u8 sub_addr, u8 data_in){
	myip_SCCB_transceiver_threePhaseWrite(OV7670_WRITE_ADDR, sub_addr, data_in);
}

void myip_SCCB_transceiver_threePhaseWrite (UINTPTR BaseAddress, u8 main_addr, u8 sub_addr, u8 data_in)
{
    volatile u32 *transceiver_reg = (volatile u32*) BaseAddress;
    transceiver_reg[1] = main_addr | (sub_addr << 8) | (data_in << 16);
    transceiver_reg[0] = 0b1;
    while(transceiver_reg[0]);  // wait till operation is done
    usleep(10);
    return;
}

void myip_SCCB_transceiver_twoPhaseWrite (UINTPTR BaseAddress, u8 main_addr, u8 sub_addr)
{
	volatile u32 *transceiver_reg = (volatile u32 *) BaseAddress;
    transceiver_reg[1] = main_addr | (sub_addr << 8);
    transceiver_reg[0] = 0b10;
    while(transceiver_reg[0]);  // wait till operation is done
    usleep(10);
    return;
}

u8 myip_SCCB_transceiver_twoPhaseRead (UINTPTR BaseAddress, u8 main_addr)
{
	volatile u32 *transceiver_reg = (volatile u32 *) BaseAddress;
    u8 data_out;
    transceiver_reg[1] = main_addr;
    transceiver_reg[0] = 0b100;
    while(transceiver_reg[0]);  // wait till operation is done
    usleep(10);
    data_out = (u8) transceiver_reg[2];
    return data_out;
}

