# spinlock
CSR for spinlock

| Address | Registers |
|---------|-----------|
|0x0|lock0|
|0x1|lock1|

## 0x0 lock0
Lock 0 (test-and-set on read, write 0x00 to release)

### [7:0] value
Read: returns the lock state then takes the lock (all bits set to 1) - 0x00: lock was free and is now owned by the reader, 0xFF (any non-zero value): lock already taken. Write: bits written to 0 are cleared (write 0x00 to release), a write never takes the lock

## 0x1 lock1
Lock 1 (test-and-set on read, write 0x00 to release)

### [7:0] value
Read: returns the lock state then takes the lock (all bits set to 1) - 0x00: lock was free and is now owned by the reader, 0xFF (any non-zero value): lock already taken. Write: bits written to 0 are cleared (write 0x00 to release), a write never takes the lock

