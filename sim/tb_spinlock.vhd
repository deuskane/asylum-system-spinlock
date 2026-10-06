-------------------------------------------------------------------------------
-- Title      : tb_spinlock
-- Project    : spinlock
-------------------------------------------------------------------------------
-- File       : tb_spinlock.vhd
-- Author     : Mathieu Rosiere
-------------------------------------------------------------------------------
-- Description: UVVM/SBI self-checking testbench for sbi_spinlock
--              Test-and-set semantics of lock0 / lock1 (rsw0c registers)
-------------------------------------------------------------------------------
-- Copyright (c) 2026
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author   Description
-- 2026-10-05  1.0      mrosiere Created
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
use     asylum.spinlock_pkg.all;
use     asylum.spinlock_csr_pkg.all;

entity tb_spinlock is
end entity tb_spinlock;

architecture sim of tb_spinlock is

  constant C_SCOPE      : string  := "TB_SPINLOCK";
  constant C_ADDR_WIDTH : natural := SPINLOCK_ADDR_WIDTH;
  constant C_DATA_WIDTH : natural := SPINLOCK_DATA_WIDTH;

  constant C_FREE       : std_logic_vector(7 downto 0) := x"00";
  constant C_TAKEN      : std_logic_vector(7 downto 0) := x"FF";

  -- Zero wait state target : any cycle with ready = '0' is an error
  constant C_SBI_CFG    : t_sbi_bfm_config := (
    max_wait_cycles            => 0,
    max_wait_cycles_severity   => error,
    use_fixed_wait_cycles_read => false,
    fixed_wait_cycles_read     => 0,
    clock_period               => -1 ns,
    clock_period_margin        => 0 ns,
    clock_margin_severity      => TB_ERROR,
    setup_time                 => -1 ns,
    hold_time                  => -1 ns,
    bfm_sync                   => SYNC_ON_CLOCK_ONLY,
    match_strictness           => MATCH_EXACT,
    id_for_bfm                 => ID_BFM,
    id_for_bfm_wait            => ID_BFM_WAIT,
    id_for_bfm_poll            => ID_BFM_POLL,
    use_ready_signal           => true
  );

  type t_addr_array is array (natural range <>) of unsigned(C_ADDR_WIDTH-1 downto 0);
  constant C_LOCKS      : t_addr_array(0 to 1) := (SPINLOCK_LOCK0, SPINLOCK_LOCK1);

  signal clk_i          : std_logic := '0';
  signal clk_ena        : boolean   := true;
  signal arst_b_i       : std_logic := '0';

  signal sbi_ini        : sbi_ini_t(addr (C_ADDR_WIDTH-1 downto 0),
                                    wdata(C_DATA_WIDTH-1 downto 0));
  signal sbi_tgt        : sbi_tgt_t(rdata(C_DATA_WIDTH-1 downto 0));

  signal sbi_if         : t_sbi_if(addr (C_ADDR_WIDTH-1 downto 0),
                                   wdata(C_DATA_WIDTH-1 downto 0),
                                   rdata(C_DATA_WIDTH-1 downto 0));

begin

  clock_generator(clk_i, clk_ena, 20 ns, "TB Clock");

  ins_dut : sbi_spinlock
    generic map (
      NAME      => "SPINLOCK"
    )
    port map (
      clk_i     => clk_i,
      arst_b_i  => arst_b_i,
      sbi_ini_i => sbi_ini,
      sbi_tgt_o => sbi_tgt
    );

  sbi_ini.cs    <= sbi_if.cs;
  sbi_ini.addr  <= std_logic_vector(sbi_if.addr);
  sbi_ini.re    <= sbi_if.rena;
  sbi_ini.we    <= sbi_if.wena;
  sbi_ini.wdata <= sbi_if.wdata;
  sbi_if.ready  <= sbi_tgt.ready;
  sbi_if.rdata  <= sbi_tgt.rdata;

  p_sequencer : process
    variable v_checks : natural := 0;

    procedure wr(constant addr : in unsigned; constant data : in std_logic_vector; constant msg : in string) is
    begin
      sbi_write(addr, data, msg, clk_i, sbi_if, C_SCOPE, shared_msg_id_panel, C_SBI_CFG);
    end procedure;

    procedure chk(constant addr : in unsigned; constant data : in std_logic_vector; constant msg : in string) is
    begin
      sbi_check(addr, data, msg, clk_i, sbi_if, error, C_SCOPE, shared_msg_id_panel, C_SBI_CFG);
      v_checks := v_checks + 1;
    end procedure;

    procedure do_reset is
    begin
      arst_b_i <= '0';
      wait for 100 ns;
      arst_b_i <= '1';
      wait until rising_edge(clk_i);
    end procedure;

  begin
    sbi_if <= init_sbi_if_signals(C_ADDR_WIDTH, C_DATA_WIDTH);
    do_reset;

    log(ID_LOG_HDR, "T1 : Reset value : every lock is free (the first read returns 0x00 and takes it)", C_SCOPE);
    for l in C_LOCKS'range loop
      chk(C_LOCKS(l), C_FREE , "lock" & integer'image(l) & " reset value : free, now taken");
      chk(C_LOCKS(l), C_TAKEN, "lock" & integer'image(l) & " second read : taken (0xFF)");
    end loop;
    do_reset;

    log(ID_LOG_HDR, "T2 : Test-and-set / release on every lock", C_SCOPE);
    for l in C_LOCKS'range loop
      for i in 0 to 2 loop
        chk(C_LOCKS(l), C_FREE , "lock" & integer'image(l) & " acquire : read returns free");
        chk(C_LOCKS(l), C_TAKEN, "lock" & integer'image(l) & " 2nd try  : read returns taken");
        chk(C_LOCKS(l), C_TAKEN, "lock" & integer'image(l) & " 3rd try  : read returns taken");
        wr (C_LOCKS(l), x"00"  , "lock" & integer'image(l) & " release (write 0x00)");
      end loop;
    end loop;

    log(ID_LOG_HDR, "T3 : Locks are independent", C_SCOPE);
    chk(SPINLOCK_LOCK0, C_FREE , "Take lock0");
    chk(SPINLOCK_LOCK1, C_FREE , "lock1 still free while lock0 is taken (now taken)");
    chk(SPINLOCK_LOCK0, C_TAKEN, "lock0 taken");
    wr (SPINLOCK_LOCK0, x"00"  , "Release lock0");
    chk(SPINLOCK_LOCK1, C_TAKEN, "lock1 still taken after the release of lock0");
    chk(SPINLOCK_LOCK0, C_FREE , "lock0 free again (now taken)");
    wr (SPINLOCK_LOCK1, x"00"  , "Release lock1");
    chk(SPINLOCK_LOCK0, C_TAKEN, "lock0 still taken after the release of lock1");
    chk(SPINLOCK_LOCK1, C_FREE , "lock1 free again (now taken)");
    wr (SPINLOCK_LOCK0, x"00"  , "Release lock0");
    wr (SPINLOCK_LOCK1, x"00"  , "Release lock1");

    log(ID_LOG_HDR, "T4 : Other write values (write-0-to-clear per bit, a write never takes a lock)", C_SCOPE);
    for l in C_LOCKS'range loop
      -- Free lock : non-zero writes keep it free
      wr (C_LOCKS(l), x"FF"  , "lock" & integer'image(l) & " free : write 0xFF");
      wr (C_LOCKS(l), x"A5"  , "lock" & integer'image(l) & " free : write 0xA5");
      chk(C_LOCKS(l), C_FREE , "lock" & integer'image(l) & " still free after non-zero writes (now taken)");
      -- Taken lock : write 0xFF has no effect
      wr (C_LOCKS(l), x"FF"  , "lock" & integer'image(l) & " taken : write 0xFF");
      chk(C_LOCKS(l), C_TAKEN, "lock" & integer'image(l) & " still taken after write 0xFF");
      -- Taken lock : write 0x0F clears bits 7:4 only, the lock stays taken (non-zero)
      wr (C_LOCKS(l), x"0F"  , "lock" & integer'image(l) & " taken : write 0x0F");
      chk(C_LOCKS(l), x"0F"  , "lock" & integer'image(l) & " read after write 0x0F : 0x0F (non-zero = taken), set again");
      chk(C_LOCKS(l), C_TAKEN, "lock" & integer'image(l) & " read again : 0xFF");
      -- Partial clears down to 0x00
      wr (C_LOCKS(l), x"F0"  , "lock" & integer'image(l) & " write 0xF0");
      wr (C_LOCKS(l), x"0F"  , "lock" & integer'image(l) & " write 0x0F");
      chk(C_LOCKS(l), C_FREE , "lock" & integer'image(l) & " 0xF0 then 0x0F clears every bit : free (now taken)");
      wr (C_LOCKS(l), x"00"  , "lock" & integer'image(l) & " release");
    end loop;

    log(ID_LOG_HDR, "T5 : Asynchronous reset releases every lock", C_SCOPE);
    chk(SPINLOCK_LOCK0, C_FREE, "Take lock0");
    chk(SPINLOCK_LOCK1, C_FREE, "Take lock1");
    do_reset;
    chk(SPINLOCK_LOCK0, C_FREE, "lock0 free after reset");
    chk(SPINLOCK_LOCK1, C_FREE, "lock1 free after reset");

    log(ID_LOG_HDR, "Number of checks : " & integer'image(v_checks), C_SCOPE);
    report_alert_counters(FINAL);
    std.env.stop;
    wait;
  end process;

end architecture sim;
