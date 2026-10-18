# spinlock
CSR for spinlock

| Address | Registers |
|---------|-----------|
|0x0|lock0|
|0x1|lock1|

## 0x0 lock0
Lock 0 (OWNER_ID = false : test-and-set on read, write 0x00 to release; OWNER_ID = true : write the owner ID to acquire, write 0x80 + ID to release, read without side effect)

### [7:0] value
OWNER_ID = false - Read: returns the lock state then takes the lock (all bits set to 1) - 0x00: lock was free and is now owned by the reader, 0xFF (any non-zero value): lock already taken. Write: bits written to 0 are cleared (write 0x00 to release), a write never takes the lock. OWNER_ID = true - Read: owner ID (0x00: free), no side effect. Write ID (0x01 to 0x7F): takes a free lock, ignored if taken. Write 0x80 + ID: releases the lock if ID is the owner, ignored otherwise

## 0x1 lock1
Lock 1 (OWNER_ID = false : test-and-set on read, write 0x00 to release; OWNER_ID = true : write the owner ID to acquire, write 0x80 + ID to release, read without side effect)

### [7:0] value
OWNER_ID = false - Read: returns the lock state then takes the lock (all bits set to 1) - 0x00: lock was free and is now owned by the reader, 0xFF (any non-zero value): lock already taken. Write: bits written to 0 are cleared (write 0x00 to release), a write never takes the lock. OWNER_ID = true - Read: owner ID (0x00: free), no side effect. Write ID (0x01 to 0x7F): takes a free lock, ignored if taken. Write 0x80 + ID: releases the lock if ID is the owner, ignored otherwise

