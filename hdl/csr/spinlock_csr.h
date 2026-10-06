#ifndef SPINLOCK_REGISTERS_H
#define SPINLOCK_REGISTERS_H

#include <stdint.h>

// Module      : spinlock
// Description : CSR for spinlock
// Width       : 8

//==================================
// Register    : lock0
// Description : Lock 0 (test-and-set on read, write 0x00 to release)
// Address     : 0x0
//==================================
#define SPINLOCK_LOCK0 0x0

// Field       : lock0.value
// Description : Read: returns the lock state then takes the lock (all bits set to 1) - 0x00: lock was free and is now owned by the reader, 0xFF (any non-zero value): lock already taken. Write: bits written to 0 are cleared (write 0x00 to release), a write never takes the lock
// Range       : [7:0]
#define SPINLOCK_LOCK0_VALUE      0
#define SPINLOCK_LOCK0_VALUE_MASK 255

//==================================
// Register    : lock1
// Description : Lock 1 (test-and-set on read, write 0x00 to release)
// Address     : 0x1
//==================================
#define SPINLOCK_LOCK1 0x1

// Field       : lock1.value
// Description : Read: returns the lock state then takes the lock (all bits set to 1) - 0x00: lock was free and is now owned by the reader, 0xFF (any non-zero value): lock already taken. Write: bits written to 0 are cleared (write 0x00 to release), a write never takes the lock
// Range       : [7:0]
#define SPINLOCK_LOCK1_VALUE      0
#define SPINLOCK_LOCK1_VALUE_MASK 255

//----------------------------------
// Structure spinlock_t
//----------------------------------
typedef struct {
  uint8_t lock0; // 0x0
  uint8_t lock1; // 0x1
} spinlock_t;

#endif // SPINLOCK_REGISTERS_H
