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

  --==================================
  -- Register    : lock0
  -- Description : Lock 0
  -- Address     : 0x0
  -- Width       : 8
  -- Sw Access   : rsw1c
  -- Hw Access   : none
  -- Hw Type     : reg
  --==================================
  type spinlock_lock0_sw2hw_t is record
    re : std_logic;
    we : std_logic;
  end record spinlock_lock0_sw2hw_t;

  --==================================
  -- Register    : lock1
  -- Description : Lock 1
  -- Address     : 0x1
  -- Width       : 8
  -- Sw Access   : rsw1c
  -- Hw Access   : none
  -- Hw Type     : reg
  --==================================
  type spinlock_lock1_sw2hw_t is record
    re : std_logic;
    we : std_logic;
  end record spinlock_lock1_sw2hw_t;

  ------------------------------------
  -- Structure spinlock_t
  ------------------------------------
  type spinlock_sw2hw_t is record
    lock0 : spinlock_lock0_sw2hw_t;
    lock1 : spinlock_lock1_sw2hw_t;
  end record spinlock_sw2hw_t;


  constant spinlock_ADDR_WIDTH : natural := 1;
  constant spinlock_DATA_WIDTH : natural := 8;

  ------------------------------------
  -- Component
  ------------------------------------
component spinlock_registers is
  port (
    -- Clock and Reset
    clk_i      : in  std_logic
   ;arst_b_i   : in  std_logic
    -- Bus
   ;sbi_ini_i  : in  sbi_ini_t
   ;sbi_tgt_o  : out sbi_tgt_t
    -- CSR
   ;sw2hw_o    : out spinlock_sw2hw_t
  );
end component spinlock_registers;


end package spinlock_csr_pkg;
