------------------------------------------------------
-- Company : Rochester Institute of Technology (RIT)
-- Engineer : William Tom (wzt8618@rit.edu)
--
-- Create Date : 07/29/2021 02:00:00 PM
-- Design Name : NoC_Port_Control
-- Project Name : Hardware Security of Multi-Chip/Multicore Server Systems
--
-- Description : Network-on-Chip Port Control Unit
------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

entity NoC_Port_Control is
	GENERIC(
	------------ GENERICS -------------
	BIT_DEPTH : integer := 32;
	VIRTUAL_CHANNELS : integer := 8
	);
	PORT(
	------------ INPUTS ---------------
	Flit_CU 	: in std_logic_vector(BIT_DEPTH-1 downto 0);
	all_full 	: in std_logic_vector(VIRTUAL_CHANNELS-1 downto 0);	-- Full Signal from the virtual channels
	all_empty   : in std_logic_vector(VIRTUAL_CHANNELS-1 downto 0);
	
	------------ OUTPUTS --------------
	FIFO_we		: out std_logic_vector(VIRTUAL_CHANNELS-1 downto 0);
	vc_id_upstream	: out std_logic_vector (2 downto 0) -- back pressure control
	);
end NoC_Port_Control;

architecture Behavioral of NoC_Port_Control is

	-- Signals
	signal full_sigs : std_logic_vector(VIRTUAL_CHANNELS-1 downto 0); -- full signals from virtual channels
	-- signal empty_sigs : std_logic_vector(VIRTUAL_CHANNELS-1 downto 0); -- empty signals from virtual channels
	signal FIFO_we_sigs : std_logic_vector(VIRTUAL_CHANNELS-1 downto 0); -- FIFO write enable control bit signals
	signal vc_id : std_logic_vector (2 downto 0);
	
begin
	-- Implementation
	-- Initialize the FIFO write enable signals to 0
	full_sigs <= all_full;
	PROC_control : process(Flit_CU)
	begin
		-- Check for Flit type (first two bits determine Flit type)
		-- 00 is a Body Flit, 01 is a Header Flit
		
		if (Flit_CU(BIT_DEPTH-1 downto BIT_DEPTH-2) = "00") then
			-- FIFO_we_sigs <= (others => '0');
			-- If the Flit is a Body Flit
			vc_id <= Flit_CU(BIT_DEPTH-3 downto BIT_DEPTH-5); -- Assign vc id the 3 bits in the Flit
			FIFO_we_sigs <= (others => '0');
			if (full_sigs(to_integer(unsigned(vc_id))) = '0') then -- if virtual channel not full
				FIFO_we_sigs(to_integer(unsigned(vc_id))) <= '1';
			end if;
		elsif (Flit_CU(BIT_DEPTH-1 downto BIT_DEPTH-2) = "01") then   
			-- If the Flit is a Header Flit
			FIFO_we_sigs <= (others => '0');
			-- Assign VCID
			for i in 0 to VIRTUAL_CHANNELS-1 loop
				if (all_empty(i) = '1') then -- 0 = not empty, 1 = empty
					-- set vc id to value of i (convert from integer to binary)
					vc_id <= std_logic_vector(to_unsigned(i, vc_id'length));
					-- if not full
					FIFO_we_sigs <= (others => '0');
					FIFO_we_sigs(i) <= '1'; 
					-- exit the loop
					exit;
				end if;
			end loop;
		end if;
	end process;	
	
	FIFO_we <= FIFO_we_sigs;
	vc_id_upstream <= vc_id;

end Behavioral;