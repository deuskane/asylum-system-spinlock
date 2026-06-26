#ifndef SPINLOCK_REGISTERS_H
#define SPINLOCK_REGISTERS_H

#include <stdint.h>

// Module      : spinlock
// Description : CSR for spinlock
// Width       : 8

//==================================
// Register    : lock0
// Description : Lock 0
// Address     : 0x0
//==================================
#define SPINLOCK_LOCK0 0x0

// Field       : lock0.value
// Description : 0: lock free, 1: lock acquiered
// Range       : [7:0]
#define SPINLOCK_LOCK0_VALUE      0
#define SPINLOCK_LOCK0_VALUE_MASK 255

//==================================
// Register    : lock1
// Description : Lock 1
// Address     : 0x1
//==================================
#define SPINLOCK_LOCK1 0x1

// Field       : lock1.value
// Description : 0: lock free, 1: lock acquiered
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
