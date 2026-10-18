-------------------------------------------------------------------------------
-- Title      : sbi_spinlock
-- Project    : PicoSOC
-------------------------------------------------------------------------------
-- File       : sbi_spinlock.vhd
-- Author     : Mathieu Rosiere
-- Company    : 
-- Created    : 2025-07-04
-- Last update: 2026-05-27
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description:
-------------------------------------------------------------------------------
-- Copyright (c) 2017
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2025-07-04  0.1      mrosiere Created
-------------------------------------------------------------------------------

library IEEE;
use     IEEE.STD_Logic_1164.ALL;
use     IEEE.numeric_std.ALL;
use     ieee.std_logic_textio.all;
use     std.textio.all;

library asylum;
use     asylum.logic_pkg.all;
use     asylum.sbi_pkg.all;
use     asylum.spinlock_pkg.all;
use     asylum.spinlock_csr_pkg.all;
use     asylum.techmap_pkg.all;

entity sbi_spinlock is
  generic (
    NAME             : string  := ""
   ;OWNER_ID         : boolean := false -- false : anonymous test-and-set on read
                                        -- true  : owner ID written by software (compare-and-set)
    );
  port   (
    clk_i            : in  std_logic;
    arst_b_i         : in  std_logic; -- asynchronous reset

    -- Bus
    sbi_ini_i        : in  sbi_ini_t;
    sbi_tgt_o        : out sbi_tgt_t
    );

end entity sbi_spinlock;

architecture rtl of sbi_spinlock is

  constant NB_LOCK                : natural := 2;
  
  type     lock_t is array (0 to NB_LOCK-1) of std_logic_vector(SPINLOCK_DATA_WIDTH-1 downto 0);

  signal   sw2hw                  : spinlock_sw2hw_t;
  signal   hw2sw                  : spinlock_hw2sw_t;

  signal   lock_r                 : lock_t;
  signal   lock_wd                : lock_t;
  signal   lock_re                : std_logic_vector(0 to NB_LOCK-1);
  signal   lock_we                : std_logic_vector(0 to NB_LOCK-1);

begin  -- architecture rtl

  ins_csr : spinlock_registers
  generic map(
    MODULE_NAME      => NAME
    )
  port map(
    clk_i            => clk_i
   ,arst_b_i         => arst_b_i
   ,sbi_ini_i        => sbi_ini_i 
   ,sbi_tgt_o        => sbi_tgt_o
   ,sw2hw_o          => sw2hw           
   ,hw2sw_i          => hw2sw   
    );

  -----------------------------------------------------------------------------
  -- Locks (csr_ext registers : the CSR bank gives the access strobes and the
  -- write data, the read data is the lock value)
  -----------------------------------------------------------------------------
  lock_re(0)          <= sw2hw.lock0.re;
  lock_we(0)          <= sw2hw.lock0.we;
  lock_wd(0)          <= sw2hw.lock0.value;
  hw2sw.lock0.we      <= '1';
  hw2sw.lock0.value   <= lock_r(0);

  lock_re(1)          <= sw2hw.lock1.re;
  lock_we(1)          <= sw2hw.lock1.we;
  lock_wd(1)          <= sw2hw.lock1.value;
  hw2sw.lock1.we      <= '1';
  hw2sw.lock1.value   <= lock_r(1);

  p_lock: process (clk_i, arst_b_i) is
  begin
    if arst_b_i = '0' then
      lock_r <= (others => (others => '0'));
    elsif rising_edge(clk_i) then
      for i in lock_r'range loop
        if not OWNER_ID then
          -- Anonymous test-and-set (csr_reg "rsw0c" model) :
          -- a read sets every bit, a write clears the bits written to 0
          if lock_re(i) = '1' and lock_we(i) = '1' then
            lock_r(i) <= lock_wd(i);
          elsif lock_re(i) = '1' then
            lock_r(i) <= (others => '1');
          elsif lock_we(i) = '1' then
            lock_r(i) <= lock_r(i) and lock_wd(i);
          end if;
        else
          -- Owner ID (compare-and-set), a read has no side effect :
          -- write ID (MSB = 0, non zero) : takes the lock if it is free
          -- write 0x80 + ID              : releases the lock if ID is the owner
          -- any other write is ignored
          if lock_we(i) = '1' then
            if    unsigned(lock_r(i)) = 0 and lock_wd(i)(7) = '0' then
              lock_r(i) <= lock_wd(i);
            elsif unsigned(lock_r(i)) /= 0 and lock_wd(i) = ('1' & lock_r(i)(6 downto 0)) then
              lock_r(i) <= (others => '0');
            end if;
          end if;
        end if;
      end loop;
    end if;
  end process p_lock;
  
end architecture rtl;
