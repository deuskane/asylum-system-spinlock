-------------------------------------------------------------------------------
-- Title      : tb_spinlock_acquire_release_pkg
-- Project    : spinlock
-------------------------------------------------------------------------------
-- File       : tb_spinlock_acquire_release_pkg.vhd
-- Author     : Mathieu Rosiere
-------------------------------------------------------------------------------
-- Description: Scenario acquire_release of tb_spinlock, from reset, three
--              times on every lock :
--              OWNER_ID = false : a read takes a free lock (0x00), the next
--                                 reads return taken (0xFF), write 0x00
--                                 releases
--              OWNER_ID = true  : write ID 0x05 takes the lock, the other
--                                 writes are refused (other ID, its own ID
--                                 again, release by another ID, 0x00, 0xFF,
--                                 0xC5 : ID 0x45 differs from 0x05 in bit 6),
--                                 write 0x85 releases
-------------------------------------------------------------------------------
-- Copyright (c) 2026
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author   Description
-- 2026-11-20  1.0      mrosiere Created (T2 and O2 of tb_spinlock)
-------------------------------------------------------------------------------

library ieee;
use     ieee.std_logic_1164.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library bitvis_vip_sbi;
use     bitvis_vip_sbi.sbi_bfm_pkg.all;

library work;
use     work.tb_spinlock_bfm_pkg.all;

package tb_spinlock_acquire_release_pkg is

  -- Acquire, refused attempts and release, three times on every lock
  procedure run
    (constant owner_id : in    boolean
    ;signal   clk      : in    std_logic
    ;signal   sbi_if   : inout t_sbi_if
    );

end package tb_spinlock_acquire_release_pkg;

package body tb_spinlock_acquire_release_pkg is

  procedure run
    (constant owner_id : in    boolean
    ;signal   clk      : in    std_logic
    ;signal   sbi_if   : inout t_sbi_if
    ) is
  begin
    for l in C_LOCKS'range loop
      for i in 0 to 2 loop
        if not owner_id
        then
          chk(C_LOCKS(l), C_FREE , lock_name(l) & " acquire : read returns free"     , clk, sbi_if);
          chk(C_LOCKS(l), C_TAKEN, lock_name(l) & " 2nd try : read returns taken"    , clk, sbi_if);
          chk(C_LOCKS(l), C_TAKEN, lock_name(l) & " 3rd try : read returns taken"    , clk, sbi_if);
          wr (C_LOCKS(l), C_FREE , lock_name(l) & " release (write 0x00)"            , clk, sbi_if);
        else
          wr (C_LOCKS(l), x"05"  , lock_name(l) & " acquire by ID 0x05"              , clk, sbi_if);
          chk(C_LOCKS(l), x"05"  , lock_name(l) & " owner 0x05"                      , clk, sbi_if);
          chk(C_LOCKS(l), x"05"  , lock_name(l) & " owner 0x05 (read without side effect)", clk, sbi_if);
          wr (C_LOCKS(l), x"07"  , lock_name(l) & " acquire by ID 0x07 while taken"  , clk, sbi_if);
          chk(C_LOCKS(l), x"05"  , lock_name(l) & " still owned by 0x05"             , clk, sbi_if);
          wr (C_LOCKS(l), x"05"  , lock_name(l) & " acquire again by its owner 0x05" , clk, sbi_if);
          chk(C_LOCKS(l), x"05"  , lock_name(l) & " still owned by 0x05 (not a release)", clk, sbi_if);
          wr (C_LOCKS(l), C_RELEASE or x"07", lock_name(l) & " release by ID 0x07 (not the owner)", clk, sbi_if);
          chk(C_LOCKS(l), x"05"  , lock_name(l) & " release by another ID refused"   , clk, sbi_if);
          wr (C_LOCKS(l), x"C5"  , lock_name(l) & " release by ID 0x45 (owner ID but bit 6)", clk, sbi_if);
          chk(C_LOCKS(l), x"05"  , lock_name(l) & " release by ID 0x45 refused"      , clk, sbi_if);
          wr (C_LOCKS(l), x"00"  , lock_name(l) & " write 0x00"                      , clk, sbi_if);
          chk(C_LOCKS(l), x"05"  , lock_name(l) & " write 0x00 does not release"     , clk, sbi_if);
          wr (C_LOCKS(l), x"FF"  , lock_name(l) & " write 0xFF"                      , clk, sbi_if);
          chk(C_LOCKS(l), x"05"  , lock_name(l) & " write 0xFF does not release"     , clk, sbi_if);
          wr (C_LOCKS(l), C_RELEASE or x"05", lock_name(l) & " release by the owner 0x05", clk, sbi_if);
          chk(C_LOCKS(l), C_FREE , lock_name(l) & " free after the release"          , clk, sbi_if);
        end if;
      end loop;
    end loop;
  end procedure;

end package body tb_spinlock_acquire_release_pkg;
