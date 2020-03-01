#include <stdint.h>

#include "drivers/serial.h"
#include "asm.h"

#define COM1_PORT 0x3F8
#define COM2_PORT 0x2F8
uint16_t COM3_PORT = 0;
uint16_t COM4_PORT = 0;


void serial_init (void) {
    // https://wiki.osdev.org/Serial_Ports
    outb(COM1_PORT + 1, 0x00); // Disable all interrupts
    outb(COM1_PORT + 3, 0x80); // Enable DLAB (set baud rate divisor)
    outb(COM1_PORT + 0, 0x03); // set divisor to 3 (lo byte) 38400 baud
    outb(COM1_PORT + 1, 0x00); //                  (hi byte)
    outb(COM1_PORT + 3, 0x03); // 8 bits, no parity, one stop bit
    outb(COM1_PORT + 2, 0xC7); // Enable FIFO, clear them, with 14-byte threshold
    outb(COM1_PORT + 4, 0x0B); // IRQs enabled, RTS/DSR set

    outb(COM2_PORT + 1, 0x00); // Disable all interrupts
    outb(COM2_PORT + 3, 0x80); // Enable DLAB (set baud rate divisor)
    outb(COM2_PORT + 0, 0x03); // set divisor to 3 (lo byte) 38400 baud
    outb(COM2_PORT + 1, 0x00);   //                  (hi byte)
    outb(COM2_PORT + 3, 0x03); // 8 bits, no parity, one stop bit
    outb(COM2_PORT + 2, 0xC7); // Enable FIFO, clear them, with 14-byte threshold
    outb(COM2_PORT + 4, 0x0B); // IRQs enabled, RTS/DSR set

}

// not all fields are standardized, may not work on modern UEFI systems
void serial_get_com(int com) {
    if (com == 3) {
        COM3_PORT = *((uint16_t*)0x0400 + 2);
    } else if (com == 4) {
        COM4_PORT = *((uint16_t*)0x0400 + 3);
    }
}

int serial_transmit_empty(uint16_t port) {
    return inb(port + 5) & 0x20;
}

int serial_write_com (int com, unsigned char data) {
    uint16_t port = (int[]){COM1_PORT, COM2_PORT, COM3_PORT, COM4_PORT}[com];
    if (port == 0)
        return -1;
    while (serial_transmit_empty(port) == 0)
        pause();

    outb(port, data); 
}
