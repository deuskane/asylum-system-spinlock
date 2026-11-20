-------------------------------------------------------------------------------
-- Title      : tb_spinlock_async_reset_pkg
-- Project    : spinlock
-------------------------------------------------------------------------------
-- File       : tb_spinlock_async_reset_pkg.vhd
-- Author     : Mathieu Rosiere
-------------------------------------------------------------------------------
-- Description: Scenario async_reset of tb_spinlock, from reset : both locks
--              taken, a reset pulse releases them ; taken again, a reset
--              pulse between two clock edges (no rising edge while the
--              reset is active) releases them too
-------------------------------------------------------------------------------
-- Copyright (c) 2026
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author   Description
-- 2026-11-20  1.0      mrosiere Created (T5 and O4 of tb_spinlock)
-------------------------------------------------------------------------------

library ieee;
use     ieee.std_logic_1164.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library bitvis_vip_sbi;
use     bitvis_vip_sbi.sbi_bfm_pkg.all;

library work;
use     work.tb_spinlock_bfm_pkg.all;

package tb_spinlock_async_reset_pkg is

  -- The asynchronous reset releases every lock, without clock edge
  procedure run
    (constant owner_id : in    boolean
    ;signal   clk      : in    std_logic
    ;signal   arst_b   : out   std_logic
    ;signal   sbi_if   : inout t_sbi_if
    );

end package tb_spinlock_async_reset_pkg;

package body tb_spinlock_async_reset_pkg is

  procedure run
    (constant owner_id : in    boolean
    ;signal   clk      : in    std_logic
    ;signal   arst_b   : out   std_logic
    ;signal   sbi_if   : inout t_sbi_if
    ) is

    -- Take every lock (and check it is taken)
    procedure take_all is
    begin
      for l in C_LOCKS'range loop
        if not owner_id
        then
          chk(C_LOCKS(l), C_FREE , "Take " & lock_name(l)      , clk, sbi_if);
          chk(C_LOCKS(l), C_TAKEN, lock_name(l) & " taken"     , clk, sbi_if);
        else
          wr (C_LOCKS(l), x"03" , lock_name(l) & " acquire by ID 0x03", clk, sbi_if);
          chk(C_LOCKS(l), x"03" , lock_name(l) & " owner 0x03"        , clk, sbi_if);
        end if;
      end loop;
    end procedure;

  begin
    take_all;
    do_reset(clk, arst_b);
    for l in C_LOCKS'range loop
      chk(C_LOCKS(l), C_FREE, lock_name(l) & " free after reset", clk, sbi_if);
      if not owner_id
      then
        wr(C_LOCKS(l), C_FREE, "Release " & lock_name(l) & " (taken by the read)", clk, sbi_if);
      end if;
    end loop;

    take_all;
    -- Reset pulse between a falling edge and the next rising edge : no
    -- rising edge of the clock while the reset is active
    wait until falling_edge(clk);
    arst_b <= '0';
    wait for C_CLK_PERIOD/4;
    arst_b <= '1';
    wait until rising_edge(clk);
    for l in C_LOCKS'range loop
      chk(C_LOCKS(l), C_FREE, lock_name(l) & " free after a reset without clock edge", clk, sbi_if);
    end loop;
  end procedure;

end package body tb_spinlock_async_reset_pkg;
