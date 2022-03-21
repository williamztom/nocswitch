------------------------------------------------------
-- Company : Rochester Institute of Technology (RIT)
-- Engineer : William Tom (wzt8618@rit.edu)
--
-- Create Date : 7/22/2021 02:30:00 PM
-- Design Name : ring_buffer_tb
-- Project Name : Hardware Security of Multi-Chip/Multicore Server Systems
--
-- Description : Testbench for FIFO Queue Buffer (Register File)
------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use std.env.finish;

entity ring_buffer_tb is
end ring_buffer_tb; 

architecture sim of ring_buffer_tb is

  constant clock_period : time := 10 ns;

  -- Generics
  constant BIT_DEPTH : natural := 32;
  constant LOG_PORT_DEPTH : natural := 8;
  
  -- DUT signals
  signal clk : std_logic := '1';
  signal rst : std_logic := '1';
  signal FIFO_we : std_logic := '0';
  signal FlitIn : std_logic_vector(BIT_DEPTH - 1 downto 0) := (others => '0');
  signal FIFO_re : std_logic := '0';
  signal rd_valid : std_logic;
  signal FlitOut : std_logic_vector(BIT_DEPTH - 1 downto 0);
  signal empty : std_logic;
  signal empty_next : std_logic;
  signal full : std_logic;
  signal full_next : std_logic;
  signal fill_count : integer range LOG_PORT_DEPTH - 1 downto 0;

begin

  DUT : entity work.FIFOQueueBuffer
    generic map (
      BIT_DEPTH => BIT_DEPTH,
      LOG_PORT_DEPTH => LOG_PORT_DEPTH
    )
    port map (
      clk => clk,
      rst => rst,
      FIFO_we => FIFO_we,
      FlitIn => FlitIn,
      FIFO_re => FIFO_re,
      rd_valid => rd_valid,
      FlitOut => FlitOut,
      empty => empty,
      empty_next => empty_next,
      full => full,
      full_next => full_next,
      fill_count => fill_count
    );

    clk <= not clk after clock_period / 2;

    PROC_SEQUENCER : process
    begin
      
      wait for 10 * clock_period;
      rst <= '0';
      wait until rising_edge(clk);

      -- Start writing
      FIFO_we <= '1';

      -- Fill the FIFO
      while full_next = '0' loop
        FlitIn <= std_logic_vector(unsigned(FlitIn) + 1);
        wait until rising_edge(clk);
      end loop;
      
      -- Stop writing
      FIFO_we <= '0';

      -- Empty the FIFO
      FIFO_re <= '1';
      wait until empty_next = '1';

      wait for 10 * clock_period;
      finish;
    end process;

end architecture;