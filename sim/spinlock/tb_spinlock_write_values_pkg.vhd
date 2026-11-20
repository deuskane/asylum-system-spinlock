-------------------------------------------------------------------------------
-- Title      : tb_spinlock_write_values_pkg
-- Project    : spinlock
-------------------------------------------------------------------------------
-- File       : tb_spinlock_write_values_pkg.vhd
-- Author     : Mathieu Rosiere
-------------------------------------------------------------------------------
-- Description: Scenario write_values of tb_spinlock, from reset, on every
--              lock :
--              OWNER_ID = false : a write never takes a lock, it clears the
--                                 bits written to 0 (0x0F leaves 0x0F, still
--                                 taken ; 0xF0 then 0x0F release)
--              OWNER_ID = true  : a value with MSB = 1 or 0x00 never takes a
--                                 free lock, the extreme IDs 0x7F and 0x01
--                                 are kept on 7 bits, 0xFF releases 0x7F
-------------------------------------------------------------------------------
-- Copyright (c) 2026
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author   Description
-- 2026-11-20  1.0      mrosiere Created (T4 and end of O2 of tb_spinlock)
-------------------------------------------------------------------------------

library ieee;
use     ieee.std_logic_1164.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library bitvis_vip_sbi;
use     bitvis_vip_sbi.sbi_bfm_pkg.all;

library work;
use     work.tb_spinlock_bfm_pkg.all;

package tb_spinlock_write_values_pkg is

  -- Write values other than the acquire / release ones
  procedure run
    (constant owner_id : in    boolean
    ;signal   clk      : in    std_logic
    ;signal   sbi_if   : inout t_sbi_if
    );

end package tb_spinlock_write_values_pkg;

package body tb_spinlock_write_values_pkg is

  procedure run
    (constant owner_id : in    boolean
    ;signal   clk      : in    std_logic
    ;signal   sbi_if   : inout t_sbi_if
    ) is
  begin
    for l in C_LOCKS'range loop
      if not owner_id
      then
        -- Free lock : non-zero writes keep it free
        wr (C_LOCKS(l), x"FF"  , lock_name(l) & " free : write 0xFF"                          , clk, sbi_if);
        wr (C_LOCKS(l), x"A5"  , lock_name(l) & " free : write 0xA5"                          , clk, sbi_if);
        chk(C_LOCKS(l), C_FREE , lock_name(l) & " still free after non-zero writes (now taken)", clk, sbi_if);
        -- Taken lock : write 0xFF has no effect
        wr (C_LOCKS(l), x"FF"  , lock_name(l) & " taken : write 0xFF"                         , clk, sbi_if);
        chk(C_LOCKS(l), C_TAKEN, lock_name(l) & " still taken after write 0xFF"               , clk, sbi_if);
        -- Taken lock : write 0x0F clears bits 7:4 only, the lock stays taken (non-zero)
        wr (C_LOCKS(l), x"0F"  , lock_name(l) & " taken : write 0x0F"                         , clk, sbi_if);
        chk(C_LOCKS(l), x"0F"  , lock_name(l) & " read after write 0x0F : 0x0F (non-zero = taken), set again", clk, sbi_if);
        chk(C_LOCKS(l), C_TAKEN, lock_name(l) & " read again : 0xFF"                          , clk, sbi_if);
        -- Partial clears down to 0x00
        wr (C_LOCKS(l), x"F0"  , lock_name(l) & " write 0xF0"                                 , clk, sbi_if);
        wr (C_LOCKS(l), x"0F"  , lock_name(l) & " write 0x0F"                                 , clk, sbi_if);
        chk(C_LOCKS(l), C_FREE , lock_name(l) & " 0xF0 then 0x0F clears every bit : free (now taken)", clk, sbi_if);
        wr (C_LOCKS(l), C_FREE , lock_name(l) & " release"                                    , clk, sbi_if);
      else
        -- Free lock : a value with MSB = 1 or 0x00 never takes it
        wr (C_LOCKS(l), C_RELEASE or x"05", lock_name(l) & " free : write 0x85"               , clk, sbi_if);
        wr (C_LOCKS(l), C_RELEASE         , lock_name(l) & " free : write 0x80"               , clk, sbi_if);
        wr (C_LOCKS(l), x"00"  , lock_name(l) & " free : write 0x00"                          , clk, sbi_if);
        chk(C_LOCKS(l), C_FREE , lock_name(l) & " still free (a value with MSB = 1 or 0x00 never takes a lock)", clk, sbi_if);
        -- Extreme IDs
        wr (C_LOCKS(l), x"7F"  , lock_name(l) & " acquire by ID 0x7F"                         , clk, sbi_if);
        chk(C_LOCKS(l), x"7F"  , lock_name(l) & " owner 0x7F"                                 , clk, sbi_if);
        wr (C_LOCKS(l), x"FF"  , lock_name(l) & " release by the owner 0x7F"                  , clk, sbi_if);
        chk(C_LOCKS(l), C_FREE , lock_name(l) & " free"                                       , clk, sbi_if);
        wr (C_LOCKS(l), x"01"  , lock_name(l) & " acquire by ID 0x01"                         , clk, sbi_if);
        chk(C_LOCKS(l), x"01"  , lock_name(l) & " owner 0x01"                                 , clk, sbi_if);
        wr (C_LOCKS(l), C_RELEASE or x"01", lock_name(l) & " release by the owner 0x01"       , clk, sbi_if);
        chk(C_LOCKS(l), C_FREE , lock_name(l) & " free"                                       , clk, sbi_if);
      end if;
    end loop;
  end procedure;

end package body tb_spinlock_write_values_pkg;
