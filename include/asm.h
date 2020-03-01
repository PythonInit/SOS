#ifndef __ASM_H
#define __ASM_H

#include <stdint.h>
#include <stdbool.h>

const uint32_t CPUID_FLAG_MSR = 1 << 5;

static inline void cpuid (int code, uint32_t *a, uint32_t *d) {
    asm volatile("cpuid":"=a"(*a),"=d"(*d):"a"(code):"ecx", "ebx");
}

bool cpuHasMSR() {
    uint32_t a, d;
    cpuid(1, &a, &d);
    return d & CPUID_FLAG_MSR;
}

void cpuGetMSR(uint32_t msr, uint32_t* lo, uint32_t* hi) {
    asm volatile ("rdmsr" : "=a"(*lo), "=d"(*hi) : "c"(msr));
}

void cpuSetMSR(uint32_t msr, uint32_t lo, uint32_t hi) {
    asm volatile ("wrmsr" : : "a"(lo), "d"(hi), "c"(msr));
}

static inline void invlpg (void* m) {
    asm volatile ("invlpg (%0)" : : "b"(m) : "memory");
}

static inline void outb(uint16_t port, uint8_t val) {
    asm volatile ("outb %0, %1" : : "a"(val), "Nd"(port));
}

static inline uint8_t inb(uint16_t port) {
    uint8_t ret;
    asm volatile ("inb %1, %0" : "=a"(ret) : "Nd"(port));
    return ret;
}

static inline void cli(void) {
    asm volatile ("cli" : : : "cc");
}

static inline void sti(void) {
    asm volatile ("sti" : : : "cc");
}

static inline void irq_disable(void) {
    cli();
}

static inline void irq_enable(void) {
    sti();
}


static inline void barrier(void) {
    asm volatile ("" : : : "memory");
}

static inline void pause(void) {
    __builtin_ia32_pause();
}

static inline uintptr_t read_cr3(void) {
    uintptr_t rv;
    asm volatile ("mov %%cr3, %0" : "=a"(rv) : );
    return rv;
}

static inline void write_cr3(uintptr_t cr3) {
    asm volatile ("mov %0, %%cr3" : : "a"(cr3) : "memory");
}

static inline uint64_t read_rflags(void) {
    return __builtin_ia32_readeflags_u64();
}

static inline void write_rflags(uint64_t rflags) {
    __builtin_ia32_writeeflags_u64(rflags);
}

static inline void preempt_inc(void) {
    asm volatile ("lock incl %%gs:0x18" : : );
}

static inline void preempt_dec(void) {
    asm volatile ("lock decl %%gs:0x18" : : );
}

#endif