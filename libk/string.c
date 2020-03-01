typedef long size_t;
typedef long uintptr_t;

#include "string.h"

void* memcpy (void* dst, const void* src, size_t n) {
    if (!((uintptr_t)src & 0x3) && !((uintptr_t)dst & 0x3)) {
        while (n>=4) {
            *(long*)dst++ = *(long*)src++;
            n -= 4;
        }
    }

    while (n--)
        *(char*)dst++ = *(char*)src++;

    return dst;
}

void* memset (void* s, int c, size_t n) {
    long buffer = (c) | (c << 8) | (c << 16) | (c << 24);
    if (!((uintptr_t)s & 0x3)) {
        while (n >= 4) {
            *(long*)s++ = buffer;
            n -= 4;
        }
    }
    while (n--) {
        *(char*)s = c;
    }
    return s;
}

void* memsetw (void* s, int c, size_t n) {
    long buffer = (c) | (c << 16);
    if (!((uintptr_t)s & 0x3)) {
        while (n >= 2) {
            *(long*)s++ = buffer;
            n -= 2;
        }
    }
    while (n--) {
        *(short*)s++ = (short)c;
    }
    return s;
}

size_t strlen (const char* s) {
    int n = 0;
    while (*s++)++n;
    return n;
}

unsigned char inportb (unsigned short _port) {
    unsigned char rv;  
    asm volatile ("inb %1, %0" : "=a"(rv) : "dN"(_port));
    return rv;
}

void outportb (unsigned short _port, unsigned char _data) {
    asm volatile ("outb %1, %0" : : "dN"(_port), "a"(_data));
}