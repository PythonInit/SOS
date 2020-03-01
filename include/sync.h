#ifndef __SYNC_H
#define __SYNC_H

#include <stdbool.h>

#include "asm.h"
#include "atomic.h"

typedef volatile uint64_t spinlock_t;

typedef volatile struct {
    atomic64_t readers;
    spinlock_t rd_lock;
    spinlock_t wr_lock;
}rwspinlock_t;

void spin_lock(volatile spinlock_t* lock);
void spin_unlock(volatile spinlock_t* lock);
bool spin_try_lock(volatile spinlock_t* lock);

#define spin_lock_irqsave(lock, rflags) do { \
        rflags = read_rflags();              \
        cli();                               \
        spin_lock(lock);                     \
}while(0)

#define spin_unlock_irqsave(lock, rflags) do { \
        spin_unlock(lock);                     \
        write_rflags(rflags)                   \
}while(0) 

static inline void spin_init(volatile spinlock_t* lock) {
    *lock = 0;
}

static inline void read_spin_lock(volatile rwspinlock_t* lock) {
    spin_lock(&lock->rd_lock);
    uint64_t readers = atomic_inc_read64(&lock->readers);
    if (readers == 1)
        spin_lock(&lock->wr_lock);
    preempt_inc();
    spin_unlock(&lock->rd_lock);
}

#endif 