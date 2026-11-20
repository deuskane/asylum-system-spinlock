-------------------------------------------------------------------------------
-- Title      : tb_spinlock
-- Project    : spinlock
-------------------------------------------------------------------------------
-- File       : tb_spinlock.vhd
-- Author     : Mathieu Rosiere
-------------------------------------------------------------------------------
-- Description: UVVM/SBI self-checking testbench for sbi_spinlock
--              TESTS_LIST : scenarios run in sequence, separated by ','
--                           (tb_spinlock_tests_pkg), each one after a reset
--                           pulse ; "" : build and elaboration only
--              OWNER_ID   : OWNER_ID of the DUT, the scenarios check the
--                           protocol of this mode
--                           false : test-and-set on read (rsw0c model)
--                           true  : owner ID compare-and-set, reads without
--                                   side effect
-------------------------------------------------------------------------------
-- Copyright (c) 2026
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author   Description
-- 2026-10-05  1.0      mrosiere Created
-- 2026-11-20  2.0      mrosiere TESTS_LIST, one package per scenario
--                               (tb_spinlock_<name>_pkg), helpers in
--                               tb_spinlock_bfm_pkg, reset pulse before
--                               each scenario
-------------------------------------------------------------------------------

library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library bitvis_vip_sbi;
use     bitvis_vip_sbi.sbi_bfm_pkg.all;

library asylum;
use     asylum.sbi_pkg.all;
use     asylum.string_pkg.all;
use     asylum.spinlock_pkg.all;
use     asylum.spinlock_csr_pkg.all;

library work;
use     work.tb_spinlock_bfm_pkg.all;
use     work.tb_spinlock_tests_pkg.all;

entity tb_spinlock is
  generic (
    TESTS_LIST       : string  := ""     -- Scenarios, e.g. "reset_values,acquire_release"
   ;OWNER_ID         : boolean := false  -- Lock protocol of the DUT
  );
end entity tb_spinlock;

architecture sim of tb_spinlock is

  constant C_SCOPE         : string  := "TB_SPINLOCK";
  constant C_NAME          : string  := "SPINLOCK";  -- NAME of the DUT

  signal   clk_i           : std_logic := '0';
  signal   clk_ena         : boolean   := true;
  signal   arst_b_i        : std_logic := '0';

  signal   sbi_ini         : sbi_ini_t(addr (SPINLOCK_ADDR_WIDTH-1 downto 0),
                                       wdata(SPINLOCK_DATA_WIDTH-1 downto 0));
  signal   sbi_tgt         : sbi_tgt_t(rdata(SPINLOCK_DATA_WIDTH-1 downto 0));
  signal   sbi_if          : t_sbi_if (addr (SPINLOCK_ADDR_WIDTH-1 downto 0),
                                       wdata(SPINLOCK_DATA_WIDTH-1 downto 0),
                                       rdata(SPINLOCK_DATA_WIDTH-1 downto 0));

begin

  clock_generator(clk_i, clk_ena, C_CLK_PERIOD, "TB Clock");

  -----------------------------------------------------------------------------
  -- DUT
  -----------------------------------------------------------------------------
  dut : sbi_spinlock
    generic map
    (NAME      => C_NAME
    ,OWNER_ID  => OWNER_ID
    )
    port map
    (clk_i     => clk_i
    ,arst_b_i  => arst_b_i
    ,sbi_ini_i => sbi_ini
    ,sbi_tgt_o => sbi_tgt
    );

  sbi_ini.cs    <= sbi_if.cs;
  sbi_ini.addr  <= std_logic_vector(sbi_if.addr);
  sbi_ini.re    <= sbi_if.rena;
  sbi_ini.we    <= sbi_if.wena;
  sbi_ini.wdata <= sbi_if.wdata;
  sbi_if.ready  <= sbi_tgt.ready;
  sbi_if.rdata  <= sbi_tgt.rdata;

  -----------------------------------------------------------------------------
  -- Sequencer
  -----------------------------------------------------------------------------
  p_sequencer : process
  begin
    log(ID_LOG_HDR, "OWNER_ID = " & boolean'image(OWNER_ID) & ", TESTS_LIST : " & TESTS_LIST, C_SCOPE);

    -- Every name is checked before the first scenario
    for i in 1 to list_length(TESTS_LIST) loop
      if not list_contains(C_TESTS, list_item(TESTS_LIST, i))
      then
        alert(TB_ERROR, "Unknown test """ & list_item(TESTS_LIST, i) & """ (tests : " & C_TESTS & ")", C_SCOPE);
      end if;
    end loop;

    for i in 1 to list_length(TESTS_LIST) loop
      -- Reset pulse, bus inactive : each scenario starts from reset
      sbi_if <= init_sbi_if_signals(SPINLOCK_ADDR_WIDTH, SPINLOCK_DATA_WIDTH);
      do_reset(clk_i, arst_b_i);

      log(ID_LOG_HDR, "TEST " & integer'image(i) & "/" & integer'image(list_length(TESTS_LIST)) & " : " & list_item(TESTS_LIST, i), C_SCOPE);
      run_test(list_item(TESTS_LIST, i), OWNER_ID, C_NAME, sbi_tgt.info.name, clk_i, arst_b_i, sbi_if);
    end loop;

    report_alert_counters(FINAL);
    std.env.stop;
    wait;
  end process p_sequencer;

end architecture sim;
