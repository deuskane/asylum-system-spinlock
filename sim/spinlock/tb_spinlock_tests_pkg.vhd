-------------------------------------------------------------------------------
-- Title      : tb_spinlock_tests_pkg
-- Project    : spinlock
-------------------------------------------------------------------------------
-- File       : tb_spinlock_tests_pkg.vhd
-- Author     : Mathieu Rosiere
-------------------------------------------------------------------------------
-- Description: Scenarios of tb_spinlock : names (valid items of TESTS_LIST)
--              and dispatch (run_test) to the package of each scenario
--              (tb_spinlock_<name>_pkg). Every scenario runs with both
--              values of OWNER_ID.
-------------------------------------------------------------------------------
-- Copyright (c) 2026
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author   Description
-- 2026-11-20  1.0      mrosiere Created
-------------------------------------------------------------------------------

library ieee;
use     ieee.std_logic_1164.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library bitvis_vip_sbi;
use     bitvis_vip_sbi.sbi_bfm_pkg.all;

library asylum;
use     asylum.string_pkg.all;

library work;
use     work.tb_spinlock_bfm_pkg.all;

package tb_spinlock_tests_pkg is

  -- Names of the scenarios (valid items of TESTS_LIST)
  constant C_TESTS : string := "reset_values,acquire_release,independent,write_values,async_reset";

  -- Run the scenario name
  procedure run_test
    (constant name     : in    string
    ;constant owner_id : in    boolean          -- OWNER_ID of the DUT
    ;constant dut_name : in    string           -- NAME of the DUT
    ;signal   tgt_name : in    string           -- sbi_tgt_o.info.name
    ;signal   clk      : in    std_logic
    ;signal   arst_b   : out   std_logic
    ;signal   sbi_if   : inout t_sbi_if
    );

end package tb_spinlock_tests_pkg;

package body tb_spinlock_tests_pkg is

  procedure run_test
    (constant name     : in    string
    ;constant owner_id : in    boolean
    ;constant dut_name : in    string
    ;signal   tgt_name : in    string
    ;signal   clk      : in    std_logic
    ;signal   arst_b   : out   std_logic
    ;signal   sbi_if   : inout t_sbi_if
    ) is
  begin
    if    string_eq(name, "reset_values")
    then
      work.tb_spinlock_reset_values_pkg.run(owner_id, dut_name, tgt_name, clk, sbi_if);
    elsif string_eq(name, "acquire_release")
    then
      work.tb_spinlock_acquire_release_pkg.run(owner_id, clk, sbi_if);
    elsif string_eq(name, "independent")
    then
      work.tb_spinlock_independent_pkg.run(owner_id, clk, sbi_if);
    elsif string_eq(name, "write_values")
    then
      work.tb_spinlock_write_values_pkg.run(owner_id, clk, sbi_if);
    elsif string_eq(name, "async_reset")
    then
      work.tb_spinlock_async_reset_pkg.run(owner_id, clk, arst_b, sbi_if);
    else
      alert(TB_ERROR, "Unknown test " & name, C_TB_SCOPE);
    end if;
  end procedure;

end package body tb_spinlock_tests_pkg;
