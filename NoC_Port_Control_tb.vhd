------------------------------------------------------
-- Company : Rochester Institute of Technology (RIT)
-- Engineer : William Tom (wzt8618@rit.edu)
--
-- Create Date : 08/05/2021 01:00:00 PM
-- Design Name : NoC_Port_Control_tb
-- Project Name : Hardware Security of Multi-Chip/Multicore Server Systems
--
-- Description : Testbench for Network-on-Chip Port Control Unit
------------------------------------------------------

library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity NoC_Port_Control_tb is
end NoC_Port_Control_tb;

architecture bench of NoC_Port_Control_tb is
  
  constant clock_period : time := 10 ns;
  constant BIT_DEPTH : integer := 32;
  constant VIRTUAL_CHANNELS : integer := 8;
  
  signal clk: std_logic := '1';
  signal Flit_CU: std_logic_vector(BIT_DEPTH-1 downto 0) := (others => '0');
  signal all_full: std_logic_vector(VIRTUAL_CHANNELS-1 downto 0);
  signal all_empty: std_logic_vector(VIRTUAL_CHANNELS-1 downto 0);
  signal FIFO_we: std_logic_vector(VIRTUAL_CHANNELS-1 downto 0);
  signal vc_id_upstream: std_logic_vector (2 downto 0) := Flit_CU(BIT_DEPTH-3 downto BIT_DEPTH-5); -- Send VC ID to body flits

begin

  -- Insert values for generic parameters
  uut: entity work.NoC_Port_Control 
  generic map ( 
	BIT_DEPTH => BIT_DEPTH,
    VIRTUAL_CHANNELS => VIRTUAL_CHANNELS
	)
  port map ( 
    Flit_CU => Flit_CU,
    all_full => all_full,
    all_empty => all_empty,
    FIFO_we => FIFO_we,
	vc_id_upstream => vc_id_upstream
	);

  clk <= not clk after clock_period / 2;
  
  stimulus: process
  begin
    
    -- Initialize
    Flit_CU <= "01000000000000000000000000000000";
	all_full <= (others => '0');
	all_empty <= (others => '1');
	wait for clock_period;
    
--	-- Test Case #1
--	-- Header Flit with Empty Virtual Channels
--	-- Expected: Header Flit goes into the first available virtual channel
	
--	-- First Two Bits are 00 so it's a header, VCID is uninitialized
--	Flit_CU <= "01000010101010010101010101010110";
--	all_full <= (others => '0'); -- 0 virtual channels are full
--	all_empty <= (others => '1'); -- All virtual channels are empty
--	wait for clock_period;
	
--	-- Test Case #2
--	-- Body Flit following the Header Flit
--	-- Expected: Body Flit goes to the same virutal channel as header
--	Flit_CU <= "00000010101010101000010010101010";
--	Flit_CU(BIT_DEPTH-3 downto BIT_DEPTH-5) <= "000"; -- Set VC ID to VC #0
--	wait for clock_period;
	
--	-- Test Csae #3
	
--	-- If the full/empty status of the virtual channels 
--	-- needs to be set before the availability of the Flit,
--	-- there needs to be a delay for the control unit.
	
--	-- Incoming Body Flit with Full Virtual Channel
--	-- Expected Output: Data does not get sent
--	all_full <= "00000001"; -- VC #0 is full
--	all_empty <= "11111110"; -- VC #0 is not empty
--	wait for clock_period;
--	Flit_CU <= "00000010101010100010101000010110";
--	Flit_CU(BIT_DEPTH-3 downto BIT_DEPTH-5) <= "000"; -- Set VC ID to VC #0
--	wait for clock_period;
	
--	-- Test Case #4
--	-- Incoming Header Flit with VC #0 is full but all other VCs are empty
--	all_full <= "00000011"; -- VC #0 is full
--	all_empty <= "11111100"; -- VC #0 is not empty
--	wait for clock_period;
--	Flit_CU <= "01000011110101010111010101100110";
--	wait for clock_period;
	
--	-- Test Case #5
--	-- Incoming Header Flit with All Full Virtual Channels
--	all_full <= (others => '1');
--	all_empty <= (others => '0');
--	wait for clock_period;
--	Flit_CU <= "01000010111100101011010101010110";
--	wait for clock_period;
    
    -- Test Case #6
    -- Reinitialize Flags
    all_full <= (others => '0');
	all_empty <= (others => '1');
	wait for clock_period;
	
	-- Two Headers
	Flit_CU <= "01000010101010010101010101010110";
    Flit_CU(BIT_DEPTH-3 downto BIT_DEPTH-5) <= "000"; -- Set VC ID to VC #0
    wait for clock_period;
    all_empty <= "11111110"; -- VC #0 is not empty
    wait for clock_period;
    wait for clock_period;
    Flit_CU <= "01000010101011101010101110101010";
	wait for clock_period;
	
    -- Fill VC #0
    Flit_CU <= "01000010101010010101010101010110";
    Flit_CU(BIT_DEPTH-3 downto BIT_DEPTH-5) <= "000"; -- Set VC ID to VC #0
    wait for clock_period;
    all_empty <= "11111110"; -- VC #0 is not empty
    wait for clock_period;
    Flit_CU <= "00000010101011101010101110101010";
    Flit_CU(BIT_DEPTH-3 downto BIT_DEPTH-5) <= "000"; -- Set VC ID to VC #0
    wait for clock_period;
    Flit_CU <= "00000010101111100011110111110111";
    Flit_CU(BIT_DEPTH-3 downto BIT_DEPTH-5) <= "000"; -- Set VC ID to VC #0
    wait for clock_period;
    Flit_CU <= "00000010101011100110010011100010";
    Flit_CU(BIT_DEPTH-3 downto BIT_DEPTH-5) <= "000"; -- Set VC ID to VC #0
    wait for clock_period;
    Flit_CU <= "00000010101010100010110101010110";
    Flit_CU(BIT_DEPTH-3 downto BIT_DEPTH-5) <= "000"; -- Set VC ID to VC #0
    wait for clock_period;
    Flit_CU <= "00000010101010101010010100010110";
    Flit_CU(BIT_DEPTH-3 downto BIT_DEPTH-5) <= "000"; -- Set VC ID to VC #0
    wait for clock_period;
    Flit_CU <= "00000010101010010000011101010110";
    Flit_CU(BIT_DEPTH-3 downto BIT_DEPTH-5) <= "000"; -- Set VC ID to VC #0
    wait for clock_period;
    Flit_CU <= "00000010100101010101100010101110";
    Flit_CU(BIT_DEPTH-3 downto BIT_DEPTH-5) <= "000"; -- Set VC ID to VC #0
    wait for clock_period;
    all_full <= "00000001"; -- VC #0 is full
	wait for clock_period;
	
	-- VC is FULL, write enable should be 0
	Flit_CU <= "00000010101101010101101010001110";
	wait for clock_period;
	
	-- Fill VC #1
	Flit_CU <= "01000010101111110101010101010110";
	Flit_CU(BIT_DEPTH-3 downto BIT_DEPTH-5) <= "001"; -- Set VC ID to VC #1
	wait for clock_period;
	all_empty <= "11111100"; -- VC #1 is not empty
	wait for clock_period;
	Flit_CU <= "00000010101011101010101110101010";
	Flit_CU(BIT_DEPTH-3 downto BIT_DEPTH-5) <= "001"; -- Set VC ID to VC #1
	wait for clock_period;
    Flit_CU <= "00000010101111100011110111110111";
    Flit_CU(BIT_DEPTH-3 downto BIT_DEPTH-5) <= "001"; -- Set VC ID to VC #1
    wait for clock_period;
    Flit_CU <= "00000010101011100110010011100010";
    Flit_CU(BIT_DEPTH-3 downto BIT_DEPTH-5) <= "001"; -- Set VC ID to VC #1
    wait for clock_period;
    Flit_CU <= "00000010101010100010110101010110";
    Flit_CU(BIT_DEPTH-3 downto BIT_DEPTH-5) <= "001"; -- Set VC ID to VC #1
    wait for clock_period;
    Flit_CU <= "00000010101010101010010100010110";
    Flit_CU(BIT_DEPTH-3 downto BIT_DEPTH-5) <= "001"; -- Set VC ID to VC #1
    wait for clock_period;
    Flit_CU <= "00000010101010010000011101010110";
    Flit_CU(BIT_DEPTH-3 downto BIT_DEPTH-5) <= "001"; -- Set VC ID to VC #1
    wait for clock_period;
    Flit_CU <= "00000010100101010101100010101110";
    Flit_CU(BIT_DEPTH-3 downto BIT_DEPTH-5) <= "001"; -- Set VC ID to VC #1
    wait for clock_period;
    all_full <= "00000011"; -- VC #2 is full
	wait for clock_period;
	
	-- VC is FULL, write enable should be 0
	Flit_CU <= "00000010101101010101101010001110";
	wait for clock_period;
    
    -- Fill VC #2
	Flit_CU <= "01000010101110111101110101110110";
	Flit_CU(BIT_DEPTH-3 downto BIT_DEPTH-5) <= "010"; -- Set VC ID to VC #2
	wait for clock_period;
	all_empty <= "11111100"; -- VC #1 is not empty
	wait for clock_period;
	Flit_CU <= "00000010101011101010101110101010";
	Flit_CU(BIT_DEPTH-3 downto BIT_DEPTH-5) <= "010"; -- Set VC ID to VC #2
	wait for clock_period;
    Flit_CU <= "00000010101111100011110111110111";
    Flit_CU(BIT_DEPTH-3 downto BIT_DEPTH-5) <= "010"; -- Set VC ID to VC #2
    wait for clock_period;
    Flit_CU <= "00000010101011100110010011100010";
    Flit_CU(BIT_DEPTH-3 downto BIT_DEPTH-5) <= "010"; -- Set VC ID to VC #2
    wait for clock_period;
    Flit_CU <= "00000010101010100010110101010110";
    Flit_CU(BIT_DEPTH-3 downto BIT_DEPTH-5) <= "010"; -- Set VC ID to VC #2
    wait for clock_period;
    Flit_CU <= "00000010101010101010010100010110";
    Flit_CU(BIT_DEPTH-3 downto BIT_DEPTH-5) <= "010"; -- Set VC ID to VC #2
    wait for clock_period;
    Flit_CU <= "00000010101010010000011101010110";
    Flit_CU(BIT_DEPTH-3 downto BIT_DEPTH-5) <= "010"; -- Set VC ID to VC #2
    wait for clock_period;
    Flit_CU <= "00000010100101010101100010101110";
    Flit_CU(BIT_DEPTH-3 downto BIT_DEPTH-5) <= "010"; -- Set VC ID to VC #2
    wait for clock_period;
    all_full <= "00000111"; -- VC #3 is full
	wait for clock_period;
	
	-- VC is FULL, write enable should be 0
	Flit_CU <= "00000010101101010101101010001110";
	wait for clock_period;
    
    -- End of Testing
	Flit_CU <= "01000000000000000000000000000000";
    wait; 
  end process;
end;