#ifndef SPINLOCK_REGISTERS_H
#define SPINLOCK_REGISTERS_H

#include <stdint.h>

// Module      : spinlock
// Description : CSR for spinlock
// Width       : 8

//==================================
// Register    : lock0
// Description : Lock 0 (OWNER_ID = false : test-and-set on read, write 0x00 to release; OWNER_ID = true : write the owner ID to acquire, write 0x80 + ID to release, read without side effect)
// Address     : 0x0
//==================================
#define SPINLOCK_LOCK0 0x0

// Field       : lock0.value
// Description : OWNER_ID = false - Read: returns the lock state then takes the lock (all bits set to 1) - 0x00: lock was free and is now owned by the reader, 0xFF (any non-zero value): lock already taken. Write: bits written to 0 are cleared (write 0x00 to release), a write never takes the lock. OWNER_ID = true - Read: owner ID (0x00: free), no side effect. Write ID (0x01 to 0x7F): takes a free lock, ignored if taken. Write 0x80 + ID: releases the lock if ID is the owner, ignored otherwise
// Range       : [7:0]
#define SPINLOCK_LOCK0_VALUE      0
#define SPINLOCK_LOCK0_VALUE_MASK 255

//==================================
// Register    : lock1
// Description : Lock 1 (OWNER_ID = false : test-and-set on read, write 0x00 to release; OWNER_ID = true : write the owner ID to acquire, write 0x80 + ID to release, read without side effect)
// Address     : 0x1
//==================================
#define SPINLOCK_LOCK1 0x1

// Field       : lock1.value
// Description : OWNER_ID = false - Read: returns the lock state then takes the lock (all bits set to 1) - 0x00: lock was free and is now owned by the reader, 0xFF (any non-zero value): lock already taken. Write: bits written to 0 are cleared (write 0x00 to release), a write never takes the lock. OWNER_ID = true - Read: owner ID (0x00: free), no side effect. Write ID (0x01 to 0x7F): takes a free lock, ignored if taken. Write 0x80 + ID: releases the lock if ID is the owner, ignored otherwise
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
