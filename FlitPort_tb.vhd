------------------------------------------------------
-- Company : Rochester Institute of Technology (RIT)
-- Engineer : William Tom (wzt8618@rit.edu)
--
-- Create Date : 10/22/2021 05:00:00 PM
-- Design Name : FlitPort_tb
-- Project Name : Hardware Security of Multi-Chip/Multicore Server Systems
--
-- Description : Testbench for Flit Port
------------------------------------------------------

library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity FlitPort_tb is
end FlitPort_tb;

architecture bench of FlitPort_tb is

  constant clock_period : time := 10 ns;
  constant BIT_DEPTH : integer := 32;
  constant VIRTUAL_CHANNELS : integer := 8;

  signal clk: std_logic := '1';
  signal rst: std_logic;
  signal FlitIn: std_logic_vector(BIT_DEPTH-1 downto 0);
  signal Flit_re: std_logic;
  signal FlitOut: std_logic_vector(VIRTUAL_CHANNELS * BIT_DEPTH-1 downto 0);
  signal vc_id_upstream: std_logic_vector (2 downto 0) ;

begin

  -- Insert values for generic parameters !!
  uut: entity work.FlitPort 
  generic map ( 
	BIT_DEPTH => BIT_DEPTH,
    VIRTUAL_CHANNELS => VIRTUAL_CHANNELS
	)
  port map ( 
	clk 			 => clk,
	rst              => rst,
	FlitIn           => FlitIn,
	Flit_re          => Flit_re,
	FlitOut          => FlitOut,
	vc_id_upstream   => vc_id_upstream 
  );

  clk <= not clk after clock_period / 2;

  stimulus: process
  begin
  
	-- Initialize
	Flit_re <= '0';
	FlitIn <= "11000000000000000000000000000000";
	rst <= '0';
	wait until rising_edge(clk);

    -- 1st Header Flit
    Flit_re <= '1';
    wait until rising_edge(clk);  -- Needs this additional wait to account for the write and read
	FlitIn <= "01000110101110111010111010111011";
	wait until rising_edge(clk);
    
    -- Body Flits for VC #1
    FlitIn <= "00000101011010111010101110101010";
	wait until rising_edge(clk);
    FlitIn <= "00000110011010101101010110101010";
	wait until rising_edge(clk);
    FlitIn <= "00000110010110000110100101110011";
	wait until rising_edge(clk);
	-- Should not work
	FlitIn <= "00000110010110000111111101110011";
	wait until rising_edge(clk);
    
    -- Delay for new header flits
    wait until rising_edge(clk);
    
	-- 2nd Header Flit
	FlitIn <= "01000111111010101101010101011101";
	wait until rising_edge(clk);
	
    -- Body Flits for VC #2
    FlitIn <= "00001101011010111001010101010101";
	wait until rising_edge(clk);
    FlitIn <= "00001111110000111100011010010101";
	wait until rising_edge(clk);
    FlitIn <= "00001001100110101010010110010101";
	wait until rising_edge(clk);	
	
	-- Delay for new header flits
    wait until rising_edge(clk);
	
	-- 3rd Header Flit
	wait until rising_edge(clk);  -- Needs this additional wait to account for the write and read
	FlitIn <= "01000001101010101011101010010001";
	wait until rising_edge(clk);

    -- Delay for new header flits
    wait until rising_edge(clk);

	-- 4th Header Flit
	FlitIn <= "01000011101010100101010111010010";
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	
	-- Delay for new header flits
    wait until rising_edge(clk);
	
	-- 5th Header Flit
	FlitIn <= "01000101011001011010101010101010";
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	
	-- Delay for new header flits
    wait until rising_edge(clk);
	
	-- 6th Header Flit
	FlitIn <= "01000110111000011010101101010101";
	wait until rising_edge(clk);
	wait until rising_edge(clk);

    -- Delay for new header flits
    wait until rising_edge(clk);

	-- 7th Header Flit
	FlitIn <= "01000101011001000011010000111010";
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	
	-- Delay for new header flits
    wait until rising_edge(clk);
	
	-- 8th Header Flit
	FlitIn <= "01000011100101010101101010001101";
	wait until rising_edge(clk);
	wait until rising_edge(clk);

	wait;
  end process;


end;