/*
 * main.c

 *
 *  Created on: 25-Mar-2025
 *      Author: HP
 */

#include "xuartps.h"
#include "xaxidma.h"
#include "xparameters.h"
#include "sleep.h"
#include "xil_cache.h"
//include files for system interrupts
#include "xgpiops.h"
#include "xscugic.h"
#include "xil_exception.h"


//image parameters
#define imgsize    512*512
#define headersize 1080
#define filesize   imgsize+headersize

//Global buffers
u8 *buffer;  //initial buffer
u8 *buffer_r; //output buffer

volatile u32 processing_done = 0;

//interrupt instances
XGpioPs gpio;
XGpioPs_Config *gpioConfig;
//global interrupt instances
XScuGic intc;
XScuGic_Config *intcConfig;
//DMA instances
XAxiDma axidma;
XAxiDma_Config *axidma_conf;
//UART instances
XUartPs_Config *myUartConfig;
XUartPs myUart;

void initialize_DMA(void)
{
	axidma_conf = XAxiDma_LookupConfigBaseAddr(XPAR_AXI_DMA_0_BASEADDR);
	if (XAxiDma_CfgInitialize(&axidma, axidma_conf) != XST_SUCCESS)
	{
		print("DMA not initialized!");
	}
	return;
}
void initialize_UART(void)
{
	myUartConfig = XUartPs_LookupConfig(XPAR_PS7_UART_1_DEVICE_ID);
	if ( XUartPs_CfgInitialize(&myUart, myUartConfig, myUartConfig->BaseAddress) != XST_SUCCESS)
	{
		print("UART not initialized!");
	}
	if (XUartPs_SetBaudRate(&myUart, 115000) != XST_SUCCESS)
	{
		print("UART Baud rate not set!");
	}
	return;
}

static void imageISA();

static void dmaISA(){}

void setup_intr_system(void)
{
	XAxiDma_IntrEnable(&axidma, XAXIDMA_IRQ_IOC_MASK, XAXIDMA_DEVICE_TO_DMA);

	//interrupt controller configuration
	intcConfig = XScuGic_LookupConfig(XPAR_PS7_SCUGIC_0_DEVICE_ID);
	if (XScuGic_CfgInitialize(&intc, intcConfig, intcConfig->CpuBaseAddress) != XST_SUCCESS)
	{
		print("Interrupts not initialized!");
	}
	//interrupt from imageProcessing IP
	XScuGic_Connect(&intc, XPAR_FABRIC_IMAGEPROCESSTOP_0_O_INTR_INTR, (Xil_InterruptHandler)imageISA, 0);
	XScuGic_Enable(&intc, XPAR_FABRIC_IMAGEPROCESSTOP_0_O_INTR_INTR);
	//interrupt from dma
	XScuGic_Connect(&intc, XPAR_FABRIC_AXI_DMA_0_S2MM_INTROUT_INTR, (Xil_InterruptHandler)dmaISA, 0);
    XScuGic_Enable(&intc, XPAR_FABRIC_AXI_DMA_0_S2MM_INTROUT_INTR);

    //enabling exceptions
    Xil_ExceptionInit();
    Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT,(Xil_ExceptionHandler)XScuGic_InterruptHandler,(void *)&intc);
    Xil_ExceptionEnable();

    return;
}


int main()
{
	u32 status; // status
	u32 total_recievedBytes = 0;
	u32 recievedBytes = 0;
	u32 total_transferredBytes = 0;
	u32 transferredBytes = 0;

	buffer   = (u8*)malloc(filesize); //Dynamically allocating space to image
	buffer_r = (u8*)malloc(filesize);

	//initializing peri
	initialize_UART();
	initialize_DMA();

    // Receive image data via UART
    while (total_recievedBytes < filesize) {
        recievedBytes = XUartPs_Recv(&myUart, &buffer[total_recievedBytes], 10);
        if (recievedBytes > 0) {
            total_recievedBytes += recievedBytes;
        }
    }

    //send header to buffer_r
    for (int i = 0; i<headersize; i++)
    {
    	buffer_r[i] = buffer[i];
    }


	//init interrupts
	setup_intr_system();
	//send data via DMA to image processing IP
	status = XAxiDma_SimpleTransfer(&axidma, (u32)buffer[headersize],   512*4,   XAXIDMA_DMA_TO_DEVICE);
	if (status != XST_SUCCESS)
		{
			print("DMA Failed\n");
			return 0;
		}
	status = XAxiDma_SimpleTransfer(&axidma, (u32)buffer_r[headersize], 512*512, XAXIDMA_DEVICE_TO_DMA);
	if (status != XST_SUCCESS)
	{
		print("DMA Failed\n");
		return 0;
	}

	while (!processing_done)
		usleep(1000);
	//transfer data back using UART.

	while (total_transferredBytes < filesize) {
		transferredBytes = XUartPs_Recv(&myUart, &buffer_r[total_transferredBytes], 10);
	    if (transferredBytes > 0) {
	    	total_transferredBytes += recievedBytes;
	    }
	}


}

u32 checkHalted(u32 baseAddress, u32 offset)
{
	u32 status;
	status = (XAxiDma_ReadReg(baseAddress, offset)) & XAXIDMA_HALTED_MASK;
	return status;
}

//no need for callbacking because axidma is initialized globally
static void imageISA()
{
	u32 status;
	static int i = 4;
	XScuGic_Disable(&intc, XPAR_FABRIC_IMAGEPROCESSTOP_0_O_INTR_INTR);
	//Check if DMA is halted or not
	status = checkHalted(XPAR_AXI_DMA_0_BASEADDR, 0x4);
	while (status == 0)
		status = checkHalted(XPAR_AXI_DMA_0_BASEADDR, 0x4);

	if (i<512)
	{
		status =  XAxiDma_SimpleTransfer(&axidma, (u32)&buffer[512*i], 512, XAXIDMA_DMA_TO_DEVICE);
		i++;
	}else {
        // All rows processed
        processing_done = 1;
    }
	XScuGic_Enable(&intc, XPAR_FABRIC_IMAGEPROCESSTOP_0_O_INTR_INTR);
}



