-------------------------------------------------------------------------------
-- Title      : tb_spinlock_bfm_pkg
-- Project    : spinlock
-------------------------------------------------------------------------------
-- File       : tb_spinlock_bfm_pkg.vhd
-- Author     : Mathieu Rosiere
-------------------------------------------------------------------------------
-- Description: Helpers of the tb_spinlock scenarios : SBI accesses (SBI VIP,
--              zero wait state), checks, reset pulses, lock values
-------------------------------------------------------------------------------
-- Copyright (c) 2026
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author   Description
-- 2026-11-20  1.0      mrosiere Created (helpers of tb_spinlock)
-------------------------------------------------------------------------------

library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library bitvis_vip_sbi;
use     bitvis_vip_sbi.sbi_bfm_pkg.all;

library asylum;
use     asylum.spinlock_csr_pkg.all;

package tb_spinlock_bfm_pkg is

  constant C_TB_SCOPE    : string  := "TB_SPINLOCK_BFM";
  constant C_CLK_PERIOD  : time    := 20 ns;

  subtype  byte_t is std_logic_vector(SPINLOCK_DATA_WIDTH-1 downto 0);

  -- Lock values
  constant C_FREE        : byte_t  := x"00";  -- Free lock (both modes)
  constant C_TAKEN       : byte_t  := x"FF";  -- Taken lock (OWNER_ID = false)
  constant C_RELEASE     : byte_t  := x"80";  -- Release flag (OWNER_ID = true) : write C_RELEASE or ID

  -- Lock registers
  type     addr_array_t is array (natural range <>) of unsigned(SPINLOCK_ADDR_WIDTH-1 downto 0);
  constant C_LOCKS       : addr_array_t(0 to 1) := (SPINLOCK_LOCK0, SPINLOCK_LOCK1);

  -- Zero wait state target : any cycle with ready = '0' is an error
  constant C_SBI_CFG     : t_sbi_bfm_config := (
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

  -- Name of the lock l in the messages ("lock0", "lock1")
  function lock_name
    (constant l        : in    natural
    ) return string;

  -- SBI write
  procedure wr
    (constant addr     : in    unsigned
    ;constant data     : in    byte_t
    ;constant msg      : in    string
    ;signal   clk      : in    std_logic
    ;signal   sbi_if   : inout t_sbi_if
    );

  -- SBI read and check
  procedure chk
    (constant addr     : in    unsigned
    ;constant data     : in    byte_t
    ;constant msg      : in    string
    ;signal   clk      : in    std_logic
    ;signal   sbi_if   : inout t_sbi_if
    );

  -- Reset pulse, released on a falling edge
  procedure do_reset
    (signal   clk      : in    std_logic
    ;signal   arst_b   : out   std_logic
    );

end package tb_spinlock_bfm_pkg;

package body tb_spinlock_bfm_pkg is

  function lock_name
    (constant l        : in    natural
    ) return string is
  begin
    return "lock" & integer'image(l);
  end function;

  procedure wr
    (constant addr     : in    unsigned
    ;constant data     : in    byte_t
    ;constant msg      : in    string
    ;signal   clk      : in    std_logic
    ;signal   sbi_if   : inout t_sbi_if
    ) is
  begin
    sbi_write(addr_value => addr
             ,data_value => data
             ,msg        => msg
             ,clk        => clk
             ,sbi_if     => sbi_if
             ,scope      => C_TB_SCOPE
             ,config     => C_SBI_CFG
             );
  end procedure;

  procedure chk
    (constant addr     : in    unsigned
    ;constant data     : in    byte_t
    ;constant msg      : in    string
    ;signal   clk      : in    std_logic
    ;signal   sbi_if   : inout t_sbi_if
    ) is
  begin
    sbi_check(addr_value  => addr
             ,data_exp    => data
             ,msg         => msg
             ,clk         => clk
             ,sbi_if      => sbi_if
             ,alert_level => error
             ,scope       => C_TB_SCOPE
             ,config      => C_SBI_CFG
             );
  end procedure;

  procedure do_reset
    (signal   clk      : in    std_logic
    ;signal   arst_b   : out   std_logic
    ) is
  begin
    arst_b <= '0';
    wait for 100 ns;
    wait until falling_edge(clk);
    arst_b <= '1';
    wait until rising_edge(clk);
  end procedure;

end package body tb_spinlock_bfm_pkg;
