-- Generated VHDL Module for spinlock


library IEEE;
use     IEEE.STD_LOGIC_1164.ALL;
use     IEEE.NUMERIC_STD.ALL;

library asylum;
use     asylum.spinlock_csr_pkg.ALL;
library asylum;
use     asylum.csr_pkg.ALL;
library asylum;
use     asylum.sbi_pkg.all;

--==================================
-- Module      : spinlock
-- Description : CSR for spinlock
-- Width       : 8
--==================================
entity spinlock_registers is
  port (
    -- Clock and Reset
    clk_i      : in  std_logic;
    arst_b_i   : in  std_logic;
    -- Bus
    sbi_ini_i  : in  sbi_ini_t;
    sbi_tgt_o  : out sbi_tgt_t;
    -- CSR
    sw2hw_o    : out spinlock_sw2hw_t;
    hw2sw_i    : in  spinlock_hw2sw_t
  );
end entity spinlock_registers;

architecture rtl of spinlock_registers is

  signal   sig_wcs   : std_logic;
  signal   sig_we    : std_logic;
  signal   sig_waddr : std_logic_vector(sbi_ini_i.addr'length-1 downto 0);
  signal   sig_wdata : std_logic_vector(sbi_ini_i.wdata'length-1 downto 0);
  signal   sig_wbusy : std_logic;

  signal   sig_rcs   : std_logic;
  signal   sig_re    : std_logic;
  signal   sig_raddr : std_logic_vector(sbi_ini_i.addr'length-1 downto 0);
  signal   sig_rdata : std_logic_vector(sbi_tgt_o.rdata'length-1 downto 0);
  signal   sig_rbusy : std_logic;

  signal   sig_busy  : std_logic;

  function INIT_lock0
    return std_logic_vector is
    variable tmp : std_logic_vector(8-1 downto 0);
  begin  -- function INIT_lock0
    tmp(7 downto 0) := "00000000"; -- value
    return tmp;
  end function INIT_lock0;

  signal   lock0_wcs       : std_logic;
  signal   lock0_we        : std_logic;
  signal   lock0_wdata     : std_logic_vector(8-1 downto 0);
  signal   lock0_wdata_sw  : std_logic_vector(8-1 downto 0);
  signal   lock0_wdata_hw  : std_logic_vector(8-1 downto 0);
  signal   lock0_wbusy     : std_logic;

  signal   lock0_rcs       : std_logic;
  signal   lock0_re        : std_logic;
  signal   lock0_rdata     : std_logic_vector(8-1 downto 0);
  signal   lock0_rdata_sw  : std_logic_vector(8-1 downto 0);
  signal   lock0_rdata_hw  : std_logic_vector(8-1 downto 0);
  signal   lock0_rbusy     : std_logic;

  function INIT_lock1
    return std_logic_vector is
    variable tmp : std_logic_vector(8-1 downto 0);
  begin  -- function INIT_lock1
    tmp(7 downto 0) := "00000000"; -- value
    return tmp;
  end function INIT_lock1;

  signal   lock1_wcs       : std_logic;
  signal   lock1_we        : std_logic;
  signal   lock1_wdata     : std_logic_vector(8-1 downto 0);
  signal   lock1_wdata_sw  : std_logic_vector(8-1 downto 0);
  signal   lock1_wdata_hw  : std_logic_vector(8-1 downto 0);
  signal   lock1_wbusy     : std_logic;

  signal   lock1_rcs       : std_logic;
  signal   lock1_re        : std_logic;
  signal   lock1_rdata     : std_logic_vector(8-1 downto 0);
  signal   lock1_rdata_sw  : std_logic_vector(8-1 downto 0);
  signal   lock1_rdata_hw  : std_logic_vector(8-1 downto 0);
  signal   lock1_rbusy     : std_logic;

begin  -- architecture rtl

  -- Interface 
  sig_wcs   <= sbi_ini_i.cs;
  sig_we    <= sbi_ini_i.we;
  sig_waddr <= sbi_ini_i.addr;
  sig_wdata <= sbi_ini_i.wdata;

  sig_rcs   <= sbi_ini_i.cs;
  sig_re    <= sbi_ini_i.re;
  sig_raddr <= sbi_ini_i.addr;
  sbi_tgt_o.rdata <= sig_rdata;
  sbi_tgt_o.ready <= not sig_busy;

  sig_busy  <= sig_wbusy when sig_we = '1' else
               sig_rbusy when sig_re = '1' else
               '0';

  gen_lock0: if (True)
  generate
  --==================================
  -- Register    : lock0
  -- Description : Lock 0
  -- Address     : 0x0
  -- Width       : 8
  -- Sw Access   : rsw1c
  -- Hw Access   : none
  -- Hw Type     : reg
  --==================================
  --==================================
  -- Field       : value
  -- Description : 0: lock release, 1: lock acquiere
  -- Width       : 8
  --==================================


    lock0_rcs     <= '1' when     (sig_raddr(spinlock_ADDR_WIDTH-1 downto 0) = std_logic_vector(to_unsigned(0,spinlock_ADDR_WIDTH))) else '0';
    lock0_re      <= sig_rcs and sig_re and lock0_rcs;
    lock0_rdata   <= (
      0 => lock0_rdata_sw(0), -- value(0)
      1 => lock0_rdata_sw(1), -- value(1)
      2 => lock0_rdata_sw(2), -- value(2)
      3 => lock0_rdata_sw(3), -- value(3)
      4 => lock0_rdata_sw(4), -- value(4)
      5 => lock0_rdata_sw(5), -- value(5)
      6 => lock0_rdata_sw(6), -- value(6)
      7 => lock0_rdata_sw(7), -- value(7)
      others => '0');

    lock0_wcs     <= '1' when       (sig_waddr(spinlock_ADDR_WIDTH-1 downto 0) = std_logic_vector(to_unsigned(0,spinlock_ADDR_WIDTH)))   else '0';
    lock0_we      <= sig_wcs and sig_we and lock0_wcs;
    lock0_wdata   <= sig_wdata;
    lock0_wdata_sw(7 downto 0) <= lock0_wdata(7 downto 0); -- value

    ins_lock0 : csr_reg
      generic map
        (WIDTH         => 8
        ,INIT          => INIT_lock0
        ,MODEL         => "rsw1c"
        )
      port map
        (clk_i         => clk_i
        ,arst_b_i      => arst_b_i
        ,sw_wd_i       => lock0_wdata_sw
        ,sw_rd_o       => lock0_rdata_sw
        ,sw_we_i       => lock0_we
        ,sw_re_i       => lock0_re
        ,sw_rbusy_o    => lock0_rbusy
        ,sw_wbusy_o    => lock0_wbusy
        ,hw_wd_i       => (others => '0')
        ,hw_rd_o       => open
        ,hw_we_i       => '0'
        ,hw_sw_re_o    => sw2hw_o.lock0.re
        ,hw_sw_we_o    => sw2hw_o.lock0.we
        );

  end generate gen_lock0;

  gen_lock0_b: if not (True)
  generate
    lock0_rcs     <= '0';
    lock0_rbusy   <= '0';
    lock0_rdata   <= (others => '0');
    lock0_wcs      <= '0';
    lock0_wbusy    <= '0';
    sw2hw_o.lock0.re <= '0';
    sw2hw_o.lock0.we <= '0';
  end generate gen_lock0_b;

  gen_lock1: if (True)
  generate
  --==================================
  -- Register    : lock1
  -- Description : Lock 1
  -- Address     : 0x1
  -- Width       : 8
  -- Sw Access   : rsw1c
  -- Hw Access   : none
  -- Hw Type     : reg
  --==================================
  --==================================
  -- Field       : value
  -- Description : 0: lock release, 1: lock acquiere
  -- Width       : 8
  --==================================


    lock1_rcs     <= '1' when     (sig_raddr(spinlock_ADDR_WIDTH-1 downto 0) = std_logic_vector(to_unsigned(1,spinlock_ADDR_WIDTH))) else '0';
    lock1_re      <= sig_rcs and sig_re and lock1_rcs;
    lock1_rdata   <= (
      0 => lock1_rdata_sw(0), -- value(0)
      1 => lock1_rdata_sw(1), -- value(1)
      2 => lock1_rdata_sw(2), -- value(2)
      3 => lock1_rdata_sw(3), -- value(3)
      4 => lock1_rdata_sw(4), -- value(4)
      5 => lock1_rdata_sw(5), -- value(5)
      6 => lock1_rdata_sw(6), -- value(6)
      7 => lock1_rdata_sw(7), -- value(7)
      others => '0');

    lock1_wcs     <= '1' when       (sig_waddr(spinlock_ADDR_WIDTH-1 downto 0) = std_logic_vector(to_unsigned(1,spinlock_ADDR_WIDTH)))   else '0';
    lock1_we      <= sig_wcs and sig_we and lock1_wcs;
    lock1_wdata   <= sig_wdata;
    lock1_wdata_sw(7 downto 0) <= lock1_wdata(7 downto 0); -- value

    ins_lock1 : csr_reg
      generic map
        (WIDTH         => 8
        ,INIT          => INIT_lock1
        ,MODEL         => "rsw1c"
        )
      port map
        (clk_i         => clk_i
        ,arst_b_i      => arst_b_i
        ,sw_wd_i       => lock1_wdata_sw
        ,sw_rd_o       => lock1_rdata_sw
        ,sw_we_i       => lock1_we
        ,sw_re_i       => lock1_re
        ,sw_rbusy_o    => lock1_rbusy
        ,sw_wbusy_o    => lock1_wbusy
        ,hw_wd_i       => (others => '0')
        ,hw_rd_o       => open
        ,hw_we_i       => '0'
        ,hw_sw_re_o    => sw2hw_o.lock1.re
        ,hw_sw_we_o    => sw2hw_o.lock1.we
        );

  end generate gen_lock1;

  gen_lock1_b: if not (True)
  generate
    lock1_rcs     <= '0';
    lock1_rbusy   <= '0';
    lock1_rdata   <= (others => '0');
    lock1_wcs      <= '0';
    lock1_wbusy    <= '0';
    sw2hw_o.lock1.re <= '0';
    sw2hw_o.lock1.we <= '0';
  end generate gen_lock1_b;

  sig_wbusy <= 
    lock0_wbusy when lock0_wcs = '1' else
    lock1_wbusy when lock1_wcs = '1' else
    '0'; -- Bad Address, no busy
  sig_rbusy <= 
    lock0_rbusy when lock0_rcs = '1' else
    lock1_rbusy when lock1_rcs = '1' else
    '0'; -- Bad Address, no busy
  sig_rdata <= 
    lock0_rdata when lock0_rcs = '1' else
    lock1_rdata when lock1_rcs = '1' else
    (others => '0'); -- Bad Address, return 0
  sbi_tgt_o.info.name <= to_sbi_name("spinlock");
end architecture rtl;
