#include <stdio.h>
#include "xil_printf.h"
#include "platform.h"
#include "xparameters.h"
#include "sleep.h"

void myip_SCCB_transceiver_threePhaseWrite (UINTPTR BaseAddress, u8 main_addr, u8 sub_addr, u8 data_in);
void myip_SCCB_transceiver_twoPhaseWrite (UINTPTR BaseAddress, u8 main_addr, u8 sub_addr);
u8 myip_SCCB_transceiver_twoPhaseRead (UINTPTR BaseAddress, u8 main_addr);

int main()
{
    init_platform();

    u8 value;

	while(1)
	{
		myip_SCCB_transceiver_threePhaseWrite(XPAR_MYIP_SCCB_TRANSCEIVER_0_S00_AXI_BASEADDR, 0x42, 0x3E, 0b00000000);
		usleep(1000000);
		myip_SCCB_transceiver_threePhaseWrite(XPAR_MYIP_SCCB_TRANSCEIVER_0_S00_AXI_BASEADDR, 0x42, 0x3E, 0b00000001);
		//value = myip_SCCB_transceiver_twoPhaseRead(XPAR_MYIP_SCCB_TRANSCEIVER_0_S00_AXI_BASEADDR, 43);
		//xil_printf("value: %d\n\r", value);
		usleep(1000000);
	}

    cleanup_platform();
    return 0;
}


void myip_SCCB_transceiver_threePhaseWrite (UINTPTR BaseAddress, u8 main_addr, u8 sub_addr, u8 data_in)
{
    volatile u32 *transceiver_reg = (volatile u32*) BaseAddress;
    transceiver_reg[1] = 0x1;
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

