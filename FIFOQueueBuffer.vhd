------------------------------------------------------
-- Company : Rochester Institute of Technology (RIT)
-- Engineer : William Tom (wzt8618@rit.edu)
--
-- Create Date : 6/24/2021 02:30:00 PM
-- Design Name : FIFOQueueBuffer
-- Project Name : Hardware Security of Multi-Chip/Multicore Server Systems
--
-- Description : FIFO Queue Buffer for Network on Chip Switch
-- Reference: https://vhdlwhiz.com/ring-buffer-fifo/ Monday, Jun 17th, 2019
-- Engineer : Jonas Julian Jensen
------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

entity FIFOQueueBuffer is
	GENERIC(
	------------ GENERICS -------------
		BIT_DEPTH : integer := 32;
		LOG_PORT_DEPTH : integer := 4
	);
	PORT (
	------------ INPUTS ---------------
		clk			: in std_logic;		-- clock
		rst			: in std_logic;		-- reset
		
		-- Write Port
		FIFO_we		: in std_logic;		-- FIFO write enable control bit
		FlitIn		: in std_logic_vector(BIT_DEPTH-1 downto 0); -- data to be written
		
		-- Read port
		FIFO_re 	: in std_logic; 	-- FIFO read enable control bit
		
	------------- OUTPUTS -------------
		-- The rd_valid signal is asserted by the FIFO when the rd_data port contains valid data. 
		-- This event is delayed by one clock cycle after a pulse on the FIFO_we signal.
		rd_valid	: out std_logic;		
		
		FlitOut 	: out std_logic_vector(BIT_DEPTH-1 downto 0); -- data read from the port
		
		-- Flags
		empty 		: out std_logic;	-- only active when there are 0 elements in the FIFO
		empty_next 	: out std_logic;	-- asserted when there are 1 or 0 elements left
		full 		: out std_logic;	-- only asserts when the FIFO cannot accommodate another data element
		full_next 	: out std_logic;	-- indicate that there is room for 1 or 0 more elements
		
		vacant		: out std_logic;	-- flag to send to control unit for occupation of tail flit
		
		-- The number of elements in the FIFO
		fill_count	: out integer range LOG_PORT_DEPTH - 1 downto 0
	);
end FIFOQueueBuffer;

architecture Behavioral of FIFOQueueBuffer is
	
	-- Declare new type to model memory
	type mem_type is array (0 to LOG_PORT_DEPTH - 1) of std_logic_vector(FlitIn'range);
	signal mem : mem_type;
 
	subtype index_type is integer range mem_type'range;
	signal reg_head : index_type;
	signal reg_tail : index_type;
 
	signal empty_i : std_logic;
	signal full_i : std_logic;
	signal fill_count_i : integer range BIT_DEPTH - 1 downto 0;
	
	signal FlitOutSig : std_logic_vector(BIT_DEPTH-1 downto 0);
 
	-- Increment and wrap
	procedure incr(signal index : inout index_type) is
	begin
		if index = index_type'high then
			index <= index_type'low;
		else
			index <= index + 1;
		end if;
	end procedure;
	
begin

--Implementation
	 
	-- Set the flags
	empty_i <= '1' when fill_count_i = 0 else '0';
	empty_next <= '1' when fill_count_i <= 1 else '0';
	full_i <= '1' when fill_count_i >= LOG_PORT_DEPTH - 1 else '0';
	full_next <= '1' when fill_count_i >= LOG_PORT_DEPTH - 2 else '0';
	
	-- Update the reg_head pointer in write
	PROC_reg_head : process(clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				reg_head <= 0;
			else
				if FIFO_we = '1' and full_i = '0' then
				    mem(reg_head) <= FlitIn;
					incr(reg_head);
				end if;
			end if;
		end if;
	end process;
 
	-- Update the reg_tail pointer on read and pulse valid
	PROC_reg_tail : process(clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				reg_tail <= 0;
				rd_valid <= '0';
			else
				rd_valid <= '0';
 
				if FIFO_re = '1' and empty_i = '0' then
				    FlitOutSig <= mem(reg_tail);
					-- Check whether Flit is a tail flit
					if (FlitOutSig(BIT_DEPTH-1 downto BIT_DEPTH-2) = "10") then
					-- Create vacant flag and set it to 1
					vacant <= '1';
					-- Pass vacant flag to control unit
					incr(reg_tail);
					rd_valid <= '1';
				    end if;
			     end if;
		    end if;
	     end if;
	end process;
 
	-- Update the fill count
	PROC_COUNT : process(reg_head, reg_tail)
	begin
		if reg_head < reg_tail then
			fill_count_i <= reg_head - reg_tail + BIT_DEPTH;
		else
			fill_count_i <= reg_head - reg_tail;
		end if;
	end process;

    FlitOut <= FlitOutSig;
    -- Copy internal signals to output
	empty <= empty_i;
	full <= full_i;
	fill_count <= fill_count_i;

end Behavioral;