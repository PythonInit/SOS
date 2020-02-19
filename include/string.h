#ifndef __STRING_H
#define __STRING_H

typedef long size_t;
extern void* memcpy(void*, const void*, size_t);
extern void* memset(void*, int, size_t);
extern void* memsetw(void*, int, size_t);
extern size_t strlen(const char*);
extern unsigned char inportb(unsigned short);
extern void outportb(unsigned short, unsigned char);

#endif