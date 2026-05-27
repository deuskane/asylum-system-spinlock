-------------------------------------------------------------------------------
-- Title      : sbi_spinlock
-- Project    : PicoSOC
-------------------------------------------------------------------------------
-- File       : sbi_spinlock.vhd
-- Author     : Mathieu Rosiere
-- Company    : 
-- Created    : 2025-07-04
-- Last update: 2026-05-27
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description:
-------------------------------------------------------------------------------
-- Copyright (c) 2017
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2025-07-04  0.1      mrosiere Created
-------------------------------------------------------------------------------

library IEEE;
use     IEEE.STD_Logic_1164.ALL;
use     IEEE.numeric_std.ALL;
use     ieee.std_logic_textio.all;
use     std.textio.all;

library asylum;
use     asylum.logic_pkg.all;
use     asylum.sbi_pkg.all;
use     asylum.spinlock_pkg.all;
use     asylum.spinlock_csr_pkg.all;
use     asylum.techmap_pkg.all;

entity sbi_spinlock is
  port   (
    clk_i            : in  std_logic;
    arst_b_i         : in  std_logic; -- asynchronous reset

    -- Bus
    sbi_ini_i        : in  sbi_ini_t;
    sbi_tgt_o        : out sbi_tgt_t
    );

end entity sbi_spinlock;

architecture rtl of sbi_spinlock is

  signal   sw2hw                  : spinlock_sw2hw_t;
  signal   hw2sw                  : spinlock_hw2sw_t;

begin  -- architecture rtl

  ins_csr : spinlock_registers
  port map(
    clk_i     => clk_i           ,
    arst_b_i  => arst_b_i        ,
    sbi_ini_i => sbi_ini_i       ,
    sbi_tgt_o => sbi_tgt_o       ,
    sw2hw_o   => sw2hw           ,
    hw2sw_i   => hw2sw   
    );
  
end architecture rtl;
