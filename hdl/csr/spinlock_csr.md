# spinlock
CSR for spinlock

| Address | Registers |
|---------|-----------|
|0x0|lock0|
|0x1|lock1|

## 0x0 lock0
Lock 0

### [7:0] value
0: lock free, 1: lock acquiered

## 0x1 lock1
Lock 1

### [7:0] value
0: lock free, 1: lock acquiered

