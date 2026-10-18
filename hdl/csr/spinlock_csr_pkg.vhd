-- Generated VHDL Package for spinlock

library IEEE;
use     IEEE.STD_LOGIC_1164.ALL;
use     IEEE.NUMERIC_STD.ALL;

library asylum;
use     asylum.sbi_pkg.all;
--==================================
-- Module      : spinlock
-- Description : CSR for spinlock
-- Width       : 8
--==================================

package spinlock_csr_pkg is

  ------------------------------------
  -- Global Constants
  ------------------------------------

  constant SPINLOCK_ADDR_WIDTH : natural := 1;
  constant SPINLOCK_DATA_WIDTH : natural := 8;

  --==================================
  -- Register    : lock0
  -- Description : Lock 0 (OWNER_ID = false : test-and-set on read, write 0x00 to release; OWNER_ID = true : write the owner ID to acquire, write 0x80 + ID to release, read without side effect)
  -- Address     : 0x0
  -- Width       : 8
  -- Sw Access   : rw
  -- Hw Access   : rw
  -- Hw Type     : ext
  --==================================
  constant SPINLOCK_LOCK0 : unsigned(SPINLOCK_ADDR_WIDTH-1 downto 0) := to_unsigned(0, SPINLOCK_ADDR_WIDTH);

  type spinlock_lock0_sw2hw_t is record
    re : std_logic;
    we : std_logic;
  --==================================
  -- Field       : value
  -- Description : OWNER_ID = false - Read: returns the lock state then takes the lock (all bits set to 1) - 0x00: lock was free and is now owned by the reader, 0xFF (any non-zero value): lock already taken. Write: bits written to 0 are cleared (write 0x00 to release), a write never takes the lock. OWNER_ID = true - Read: owner ID (0x00: free), no side effect. Write ID (0x01 to 0x7F): takes a free lock, ignored if taken. Write 0x80 + ID: releases the lock if ID is the owner, ignored otherwise
  -- Width       : 8
  --==================================
    value : std_logic_vector(8-1 downto 0);
  end record spinlock_lock0_sw2hw_t;

  type spinlock_lock0_hw2sw_t is record
    we : std_logic;
  --==================================
  -- Field       : value
  -- Description : OWNER_ID = false - Read: returns the lock state then takes the lock (all bits set to 1) - 0x00: lock was free and is now owned by the reader, 0xFF (any non-zero value): lock already taken. Write: bits written to 0 are cleared (write 0x00 to release), a write never takes the lock. OWNER_ID = true - Read: owner ID (0x00: free), no side effect. Write ID (0x01 to 0x7F): takes a free lock, ignored if taken. Write 0x80 + ID: releases the lock if ID is the owner, ignored otherwise
  -- Width       : 8
  --==================================
    value : std_logic_vector(8-1 downto 0);
  end record spinlock_lock0_hw2sw_t;

  --==================================
  -- Register    : lock1
  -- Description : Lock 1 (OWNER_ID = false : test-and-set on read, write 0x00 to release; OWNER_ID = true : write the owner ID to acquire, write 0x80 + ID to release, read without side effect)
  -- Address     : 0x1
  -- Width       : 8
  -- Sw Access   : rw
  -- Hw Access   : rw
  -- Hw Type     : ext
  --==================================
  constant SPINLOCK_LOCK1 : unsigned(SPINLOCK_ADDR_WIDTH-1 downto 0) := to_unsigned(1, SPINLOCK_ADDR_WIDTH);

  type spinlock_lock1_sw2hw_t is record
    re : std_logic;
    we : std_logic;
  --==================================
  -- Field       : value
  -- Description : OWNER_ID = false - Read: returns the lock state then takes the lock (all bits set to 1) - 0x00: lock was free and is now owned by the reader, 0xFF (any non-zero value): lock already taken. Write: bits written to 0 are cleared (write 0x00 to release), a write never takes the lock. OWNER_ID = true - Read: owner ID (0x00: free), no side effect. Write ID (0x01 to 0x7F): takes a free lock, ignored if taken. Write 0x80 + ID: releases the lock if ID is the owner, ignored otherwise
  -- Width       : 8
  --==================================
    value : std_logic_vector(8-1 downto 0);
  end record spinlock_lock1_sw2hw_t;

  type spinlock_lock1_hw2sw_t is record
    we : std_logic;
  --==================================
  -- Field       : value
  -- Description : OWNER_ID = false - Read: returns the lock state then takes the lock (all bits set to 1) - 0x00: lock was free and is now owned by the reader, 0xFF (any non-zero value): lock already taken. Write: bits written to 0 are cleared (write 0x00 to release), a write never takes the lock. OWNER_ID = true - Read: owner ID (0x00: free), no side effect. Write ID (0x01 to 0x7F): takes a free lock, ignored if taken. Write 0x80 + ID: releases the lock if ID is the owner, ignored otherwise
  -- Width       : 8
  --==================================
    value : std_logic_vector(8-1 downto 0);
  end record spinlock_lock1_hw2sw_t;

  ------------------------------------
  -- Structure spinlock_t
  ------------------------------------
  type spinlock_sw2hw_t is record
    lock0 : spinlock_lock0_sw2hw_t;
    lock1 : spinlock_lock1_sw2hw_t;
  end record spinlock_sw2hw_t;

  type spinlock_hw2sw_t is record
    lock0 : spinlock_lock0_hw2sw_t;
    lock1 : spinlock_lock1_hw2sw_t;
  end record spinlock_hw2sw_t;

  ------------------------------------
  -- Component
  ------------------------------------
component spinlock_registers is
  generic (
    MODULE_NAME :  string := "" -- Name of the module
  );
  port (
    -- Clock and Reset
    clk_i      : in  std_logic
   ;arst_b_i   : in  std_logic
    -- Bus
   ;sbi_ini_i  : in  sbi_ini_t
   ;sbi_tgt_o  : out sbi_tgt_t
    -- CSR
   ;sw2hw_o    : out spinlock_sw2hw_t
   ;hw2sw_i    : in  spinlock_hw2sw_t
  );
end component spinlock_registers;


end package spinlock_csr_pkg;
