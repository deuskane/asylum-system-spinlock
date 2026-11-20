-------------------------------------------------------------------------------
-- Title      : tb_spinlock_reset_values_pkg
-- Project    : spinlock
-------------------------------------------------------------------------------
-- File       : tb_spinlock_reset_values_pkg.vhd
-- Author     : Mathieu Rosiere
-------------------------------------------------------------------------------
-- Description: Scenario reset_values of tb_spinlock, from reset :
--              every lock is free, NAME in sbi_tgt_o.info.name.
--              OWNER_ID = false : the first read returns 0x00 and takes the
--                                 lock, the second one returns 0xFF
--              OWNER_ID = true  : a read has no side effect
-------------------------------------------------------------------------------
-- Copyright (c) 2026
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author   Description
-- 2026-11-20  1.0      mrosiere Created (T1 and O1 of tb_spinlock)
-------------------------------------------------------------------------------

library ieee;
use     ieee.std_logic_1164.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library bitvis_vip_sbi;
use     bitvis_vip_sbi.sbi_bfm_pkg.all;

library asylum;
use     asylum.sbi_pkg.all;

library work;
use     work.tb_spinlock_bfm_pkg.all;

package tb_spinlock_reset_values_pkg is

  -- Every lock free after the reset, NAME of the target
  procedure run
    (constant owner_id : in    boolean
    ;constant name     : in    string           -- NAME of the DUT
    ;signal   tgt_name : in    string           -- sbi_tgt_o.info.name
    ;signal   clk      : in    std_logic
    ;signal   sbi_if   : inout t_sbi_if
    );

end package tb_spinlock_reset_values_pkg;

package body tb_spinlock_reset_values_pkg is

  procedure run
    (constant owner_id : in    boolean
    ;constant name     : in    string
    ;signal   tgt_name : in    string
    ;signal   clk      : in    std_logic
    ;signal   sbi_if   : inout t_sbi_if
    ) is
  begin
    check_value(tgt_name, to_sbi_name(name), error, "sbi_tgt_o.info.name : NAME", C_TB_SCOPE);

    for l in C_LOCKS'range loop
      if not owner_id
      then
        chk(C_LOCKS(l), C_FREE , lock_name(l) & " reset value : free, now taken", clk, sbi_if);
        chk(C_LOCKS(l), C_TAKEN, lock_name(l) & " second read : taken (0xFF)"   , clk, sbi_if);
      else
        chk(C_LOCKS(l), C_FREE , lock_name(l) & " reset value : free"           , clk, sbi_if);
        chk(C_LOCKS(l), C_FREE , lock_name(l) & " still free after a read"      , clk, sbi_if);
      end if;
    end loop;
  end procedure;

end package body tb_spinlock_reset_values_pkg;
