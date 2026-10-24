-------------------------------------------------------------------------------
-- Title      : sbi_spinlock_wrapper
-- Project    : Asylum
-------------------------------------------------------------------------------
-- File       : sbi_spinlock_wrapper.vhd
-- Author     : Mathieu Rosiere
-------------------------------------------------------------------------------
-- Description:
-- Wrapper (lint_ghdl, lint_ghdl_synth_*) : sbi_spinlock with flat
-- and constrained ports (sbi_spinlock has unconstrained SBI ports and cannot
-- be a synthesis top). SBI address / data width : SBI_ADDR_WIDTH /
-- SBI_DATA_WIDTH. NAME (only generic) is only in sbi_tgt.info, not
-- connected.
-------------------------------------------------------------------------------
-- Copyright (c) 2026
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author   Description
-- 2026-10-20  1.0      mrosiere Created
-- 2026-10-24  1.1      mrosiere Was sbi_spinlock_synth_top, library asylum
-------------------------------------------------------------------------------

library ieee;
use     ieee.std_logic_1164.all;
library asylum;
use     asylum.sbi_pkg.all;

entity sbi_spinlock_wrapper is
  port (
    clk_i         : in  std_logic;
    arst_b_i      : in  std_logic;

    -- Bus (SBI)
    cs_i          : in  std_logic;
    re_i          : in  std_logic;
    we_i          : in  std_logic;
    addr_i        : in  std_logic_vector(SBI_ADDR_WIDTH-1 downto 0);
    wdata_i       : in  std_logic_vector(SBI_DATA_WIDTH-1 downto 0);
    ready_o       : out std_logic;
    rdata_o       : out std_logic_vector(SBI_DATA_WIDTH-1 downto 0)
  );
end entity sbi_spinlock_wrapper;

architecture rtl of sbi_spinlock_wrapper is

  signal sbi_ini       : sbi_ini_t(addr (SBI_ADDR_WIDTH-1 downto 0),
                                   wdata(SBI_DATA_WIDTH-1 downto 0));
  signal sbi_tgt       : sbi_tgt_t(rdata(SBI_DATA_WIDTH-1 downto 0));

begin

  sbi_ini.cs        <= cs_i;
  sbi_ini.re        <= re_i;
  sbi_ini.we        <= we_i;
  sbi_ini.addr      <= addr_i;
  sbi_ini.wdata     <= wdata_i;
  ready_o           <= sbi_tgt.ready;
  rdata_o           <= sbi_tgt.rdata;

  ins_sbi_spinlock : entity asylum.sbi_spinlock
    port map (
      clk_i           => clk_i,
      arst_b_i        => arst_b_i,
      sbi_ini_i       => sbi_ini,
      sbi_tgt_o       => sbi_tgt
    );

end architecture rtl;
