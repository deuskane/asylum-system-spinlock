-------------------------------------------------------------------------------
-- Title      : tb_spinlock_independent_pkg
-- Project    : spinlock
-------------------------------------------------------------------------------
-- File       : tb_spinlock_independent_pkg.vhd
-- Author     : Mathieu Rosiere
-------------------------------------------------------------------------------
-- Description: Scenario independent of tb_spinlock, from reset : an access
--              to a lock never changes the other one.
--              OWNER_ID = false : take and release lock0 and lock1 in turn
--              OWNER_ID = true  : two owners, a release with the ID of the
--                                 owner of the other lock is refused
-------------------------------------------------------------------------------
-- Copyright (c) 2026
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author   Description
-- 2026-11-20  1.0      mrosiere Created (T3 and O3 of tb_spinlock)
-------------------------------------------------------------------------------

library ieee;
use     ieee.std_logic_1164.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library bitvis_vip_sbi;
use     bitvis_vip_sbi.sbi_bfm_pkg.all;

library asylum;
use     asylum.spinlock_csr_pkg.all;

library work;
use     work.tb_spinlock_bfm_pkg.all;

package tb_spinlock_independent_pkg is

  -- An access to a lock never changes the other one
  procedure run
    (constant owner_id : in    boolean
    ;signal   clk      : in    std_logic
    ;signal   sbi_if   : inout t_sbi_if
    );

end package tb_spinlock_independent_pkg;

package body tb_spinlock_independent_pkg is

  procedure run
    (constant owner_id : in    boolean
    ;signal   clk      : in    std_logic
    ;signal   sbi_if   : inout t_sbi_if
    ) is
  begin
    if not owner_id
    then
      chk(SPINLOCK_LOCK0, C_FREE , "Take lock0"                                        , clk, sbi_if);
      chk(SPINLOCK_LOCK1, C_FREE , "lock1 still free while lock0 is taken (now taken)" , clk, sbi_if);
      chk(SPINLOCK_LOCK0, C_TAKEN, "lock0 taken"                                       , clk, sbi_if);
      wr (SPINLOCK_LOCK0, C_FREE , "Release lock0"                                     , clk, sbi_if);
      chk(SPINLOCK_LOCK1, C_TAKEN, "lock1 still taken after the release of lock0"      , clk, sbi_if);
      chk(SPINLOCK_LOCK0, C_FREE , "lock0 free again (now taken)"                      , clk, sbi_if);
      wr (SPINLOCK_LOCK1, C_FREE , "Release lock1"                                     , clk, sbi_if);
      chk(SPINLOCK_LOCK0, C_TAKEN, "lock0 still taken after the release of lock1"      , clk, sbi_if);
      chk(SPINLOCK_LOCK1, C_FREE , "lock1 free again (now taken)"                      , clk, sbi_if);
    else
      wr (SPINLOCK_LOCK0, x"01"  , "lock0 acquire by ID 0x01"                          , clk, sbi_if);
      wr (SPINLOCK_LOCK1, x"02"  , "lock1 acquire by ID 0x02"                          , clk, sbi_if);
      chk(SPINLOCK_LOCK0, x"01"  , "lock0 owner 0x01"                                  , clk, sbi_if);
      chk(SPINLOCK_LOCK1, x"02"  , "lock1 owner 0x02"                                  , clk, sbi_if);
      wr (SPINLOCK_LOCK1, C_RELEASE or x"01", "lock1 release by ID 0x01 (owner of lock0 only)", clk, sbi_if);
      chk(SPINLOCK_LOCK1, x"02"  , "lock1 still owned by 0x02"                         , clk, sbi_if);
      wr (SPINLOCK_LOCK0, C_RELEASE or x"01", "lock0 release by its owner 0x01"        , clk, sbi_if);
      chk(SPINLOCK_LOCK0, C_FREE , "lock0 free"                                        , clk, sbi_if);
      chk(SPINLOCK_LOCK1, x"02"  , "lock1 still owned by 0x02 after the release of lock0", clk, sbi_if);
      wr (SPINLOCK_LOCK1, C_RELEASE or x"02", "lock1 release by its owner 0x02"        , clk, sbi_if);
      chk(SPINLOCK_LOCK1, C_FREE , "lock1 free"                                        , clk, sbi_if);
    end if;
  end procedure;

end package body tb_spinlock_independent_pkg;
