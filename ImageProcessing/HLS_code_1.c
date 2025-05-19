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
// Include files for system interrupts
#include "xgpiops.h"
#include "xscugic.h"
#include "xil_exception.h"

// Image parameters
#define IMG_SIZE    (512*512)
#define HEADER_SIZE 1080
#define FILE_SIZE   (IMG_SIZE+HEADER_SIZE)
#define ROW_SIZE    512

// Global buffers - ensure cache alignment for DMA
u8 *buffer;     // Input buffer
u8 *buffer_r;   // Output buffer
volatile u32 processing_done = 0;
volatile u32 dma_rx_done = 0;  // Flag to track DMA receive completion

// Interrupt instances
XGpioPs gpio;
XGpioPs_Config *gpioConfig;
// Global interrupt instances
XScuGic intc;
XScuGic_Config *intcConfig;
// DMA instances
XAxiDma axidma;
XAxiDma_Config *axidma_conf;
// UART instances
XUartPs_Config *myUartConfig;
XUartPs myUart;

// Forward declarations
static void imageISA(void *CallbackRef);
static void dmaS2MISA(void *CallbackRef);
void setup_intr_system(void);
u32 checkHalted(u32 baseAddress, u32 offset);

void initialize_DMA(void)
{
    axidma_conf = XAxiDma_LookupConfigBaseAddr(XPAR_AXI_DMA_0_BASEADDR);
    if (XAxiDma_CfgInitialize(&axidma, axidma_conf) != XST_SUCCESS)
    {
        xil_printf("DMA not initialized!\r\n");
        return;
    }
    
    // Disable interrupts before setup
    XAxiDma_IntrDisable(&axidma, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DMA_TO_DEVICE);
    XAxiDma_IntrDisable(&axidma, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DEVICE_TO_DMA);
    
    xil_printf("DMA initialized successfully\r\n");
    return;
}

void initialize_UART(void)
{
    myUartConfig = XUartPs_LookupConfig(XPAR_PS7_UART_1_DEVICE_ID);
    if (XUartPs_CfgInitialize(&myUart, myUartConfig, myUartConfig->BaseAddress) != XST_SUCCESS)
    {
        xil_printf("UART not initialized!\r\n");
        return;
    }
    if (XUartPs_SetBaudRate(&myUart, 115000) != XST_SUCCESS)
    {
        xil_printf("UART Baud rate not set!\r\n");
        return;
    }
    xil_printf("UART initialized successfully\r\n");
    return;
}

// Interrupt handler for image processing IP
static void imageISA(void *CallbackRef)
{
    u32 status;
    static int row_idx = 1; // Start with second row (first row already sent)
    
    // Disable interrupt during handler execution
    XScuGic_Disable(&intc, XPAR_FABRIC_IMAGEPROCESSTOP_0_O_INTR_INTR);
    
    // Check if MM2S channel is halted
    status = checkHalted(XPAR_AXI_DMA_0_BASEADDR, 0x4);
    while (status == 0) {
        status = checkHalted(XPAR_AXI_DMA_0_BASEADDR, 0x4);
    }
    
    if (row_idx < 512) {
        // Calculate the address of the next row to process
        u32 row_addr = (u32)(&buffer[HEADER_SIZE + (row_idx * ROW_SIZE)]);
        
        // Send the next row to the image processing IP
        status = XAxiDma_SimpleTransfer(&axidma, row_addr, ROW_SIZE, XAXIDMA_DMA_TO_DEVICE);
        if (status != XST_SUCCESS) {
            xil_printf("Error sending row %d to DMA\r\n", row_idx);
        }
        
        row_idx++;
    } else {
        // All rows processed
        processing_done = 1;
        xil_printf("All rows processed\r\n");
    }
    
    // Re-enable the interrupt
    XScuGic_Enable(&intc, XPAR_FABRIC_IMAGEPROCESSTOP_0_O_INTR_INTR);
}

// Interrupt handler for DMA S2MM completion
static void dmaS2MISA(void *CallbackRef)
{
    // Disable DMA interrupt
    XAxiDma_IntrDisable(&axidma, XAXIDMA_IRQ_IOC_MASK, XAXIDMA_DEVICE_TO_DMA);
    
    // Clear the interrupt status
    XAxiDma_IntrAckIrq(&axidma, XAXIDMA_IRQ_IOC_MASK, XAXIDMA_DEVICE_TO_DMA);
    
    // Set the DMA receive done flag
    dma_rx_done = 1;
    
    // Re-enable DMA interrupt
    XAxiDma_IntrEnable(&axidma, XAXIDMA_IRQ_IOC_MASK, XAXIDMA_DEVICE_TO_DMA);
}

void setup_intr_system(void)
{
    // Initialize the interrupt controller
    intcConfig = XScuGic_LookupConfig(XPAR_PS7_SCUGIC_0_DEVICE_ID);
    if (XScuGic_CfgInitialize(&intc, intcConfig, intcConfig->CpuBaseAddress) != XST_SUCCESS)
    {
        xil_printf("Interrupts not initialized!\r\n");
        return;
    }
    
    // Connect interrupt from imageProcessing IP
    XScuGic_Connect(&intc, XPAR_FABRIC_IMAGEPROCESSTOP_0_O_INTR_INTR, 
                   (Xil_InterruptHandler)imageISA, 0);
    XScuGic_Enable(&intc, XPAR_FABRIC_IMAGEPROCESSTOP_0_O_INTR_INTR);
    
    // Connect interrupt from DMA S2MM channel
    XScuGic_Connect(&intc, XPAR_FABRIC_AXI_DMA_0_S2MM_INTROUT_INTR,
                   (Xil_InterruptHandler)dmaS2MISA, 0);
    XScuGic_Enable(&intc, XPAR_FABRIC_AXI_DMA_0_S2MM_INTROUT_INTR);
    
    // Enable DMA interrupts
    XAxiDma_IntrEnable(&axidma, XAXIDMA_IRQ_IOC_MASK, XAXIDMA_DEVICE_TO_DMA);
    
    // Enable exceptions
    Xil_ExceptionInit();
    Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT,
                                (Xil_ExceptionHandler)XScuGic_InterruptHandler,
                                (void *)&intc);
    Xil_ExceptionEnable();
    
    xil_printf("Interrupt system setup complete\r\n");
    return;
}

int main()
{
    u32 status;
    u32 total_receivedBytes = 0;
    u32 receivedBytes = 0;
    u32 total_sentBytes = 0;
    u32 sentBytes = 0;
    
    xil_printf("Starting image processing application\r\n");
    
    // Allocate memory for image buffers - ensure cache alignment
    buffer = (u8*)malloc(FILE_SIZE);
    buffer_r = (u8*)malloc(FILE_SIZE);
    
    if (!buffer || !buffer_r) {
        xil_printf("Error: Failed to allocate memory\r\n");
        return XST_FAILURE;
    }
    
    // Initialize peripherals
    initialize_UART();
    initialize_DMA();
    
    xil_printf("Waiting to receive image data via UART (%d bytes)...\r\n", FILE_SIZE);
    
    // Receive image data via UART
    while (total_receivedBytes < FILE_SIZE) {
        receivedBytes = XUartPs_Recv(&myUart, &buffer[total_receivedBytes], 
                                     FILE_SIZE - total_receivedBytes);
        if (receivedBytes > 0) {
            total_receivedBytes += receivedBytes;
            if (total_receivedBytes % 10240 == 0) {
                xil_printf("Received %d bytes\r\n", total_receivedBytes);
            }
        }
    }
    
    xil_printf("Image received completely (%d bytes)\r\n", total_receivedBytes);
    
    // Copy header to output buffer
    for (int i = 0; i < HEADER_SIZE; i++) {
        buffer_r[i] = buffer[i];
    }
    
    // Setup interrupt system
    setup_intr_system();
    
    // DMA operations will proceed without explicit cache handling
    
    // Setup DMA to receive processed data
    status = XAxiDma_SimpleTransfer(&axidma, (u32)&buffer_r[HEADER_SIZE], 
                                   IMG_SIZE, XAXIDMA_DEVICE_TO_DMA);
    if (status != XST_SUCCESS) {
        xil_printf("Error: Failed to set up DMA receive\r\n");
        return XST_FAILURE;
    }
    
    // Send first row to image processing IP
    status = XAxiDma_SimpleTransfer(&axidma, (u32)&buffer[HEADER_SIZE], 
                                   ROW_SIZE, XAXIDMA_DMA_TO_DEVICE);
    if (status != XST_SUCCESS) {
        xil_printf("Error: Failed to send first row\r\n");
        return XST_FAILURE;
    }
    
    // Wait for processing to complete
    xil_printf("Processing image...\r\n");
    while (!processing_done || !dma_rx_done) {
        usleep(1000);
    }
    
    xil_printf("Processing complete, sending data back via UART\r\n");
    
    // Send processed image back via UART
    while (total_sentBytes < FILE_SIZE) {
        // Send up to 32 bytes at a time (adjust based on UART FIFO size)
        u32 bytesToSend = (FILE_SIZE - total_sentBytes > 32) ? 32 : (FILE_SIZE - total_sentBytes);
        sentBytes = XUartPs_Send(&myUart, &buffer_r[total_sentBytes], bytesToSend);
        
        if (sentBytes > 0) {
            total_sentBytes += sentBytes;
            if (total_sentBytes % 10240 == 0) {
                xil_printf("Sent %d bytes\r\n", total_sentBytes);
            }
        }
    }
    
    xil_printf("Image transfer complete\r\n");
    
    // Free allocated memory
    free(buffer);
    free(buffer_r);
    
    return XST_SUCCESS;
}

u32 checkHalted(u32 baseAddress, u32 offset)
{
    u32 status;
    status = (XAxiDma_ReadReg(baseAddress, offset)) & XAXIDMA_HALTED_MASK;
    return status;
}
