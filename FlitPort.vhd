------------------------------------------------------
-- Company : Rochester Institute of Technology (RIT)
-- Engineer : William Tom (wzt8618@rit.edu)
--
-- Create Date : 7/2/2021 03:00:00 PM
-- Design Name : FlitPort
-- Project Name : Hardware Security of Multi-Chip/Multicore Server Systems
--
-- Description : Flow control unit port of virtual channels
-- (FIFO Queue Buffers), a demux, and a control unit.
------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

entity FlitPort is
	GENERIC(
	------------ GENERICS -------------
		BIT_DEPTH : integer := 32;
		VIRTUAL_CHANNELS : integer := 8 -- Number of Virtual Channels
	);
	PORT(
	------------ INPUTS ---------------
		clk		: in std_logic;
		rst		: in std_logic;
		FlitIn	: in std_logic_vector(BIT_DEPTH-1 downto 0); --write data, din
		Flit_re : in std_logic; 		
	------------ OUTPUTS --------------
		FlitOut : out std_logic_vector(VIRTUAL_CHANNELS * BIT_DEPTH-1 downto 0);
		vc_id_upstream : out std_logic_vector (2 downto 0)
	);
end FlitPort;

architecture Behavioral of FlitPort is
	
	component NoC_Port_Control is
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
    end component;
	
	component FIFOQueueBuffer is
		GENERIC(
		------------ GENERICS -------------
		BIT_DEPTH : integer := 32;
		LOG_PORT_DEPTH : integer := 4 -- Max Number of Flits in Virtual Channel
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
	end component;
	
	signal all_full_connect : std_logic_vector (VIRTUAL_CHANNELS-1 downto 0);
	signal all_empty_connect : std_logic_vector (VIRTUAL_CHANNELS-1 downto 0);
	signal internal_we : std_logic_vector (VIRTUAL_CHANNELS-1 downto 0);
	
begin
	
	Flit_Control : NoC_Port_Control
	generic map(
		------------ GENERICS -------------
		BIT_DEPTH => 32,
		VIRTUAL_CHANNELS => 8
	)
	port map(
		------------ INPUTS ---------------
		Flit_CU => FlitIn,
		all_full => all_full_connect,
		all_empty => all_empty_connect,
		------------ OUTPUTS --------------
		FIFO_we	=> internal_we,
		vc_id_upstream => vc_id_upstream
	);
	
	VC_QUEUES: 
	for i in 0 to (VIRTUAL_CHANNELS-1) generate
		Virtucal_Channel_Queue : FIFOQueueBuffer 
		generic map (
			BIT_DEPTH => 32,
			LOG_PORT_DEPTH => 4 
		)
		port map (
		------------ INPUTS ---------------
		clk => clk,
		rst	=> rst,		
		FIFO_we	=> internal_we(i),
		FlitIn => FlitIn,
		FIFO_re => Flit_re,
		------------- OUTPUTS -------------
		rd_valid => OPEN,
		FlitOut => FlitOut((i+1) * BIT_DEPTH-1 downto (i * BIT_DEPTH)),
		-- Flags
		empty => all_empty_connect(i),
		empty_next => OPEN,
		full => all_full_connect(i),
		full_next => OPEN,
		vacant => OPEN,
		fill_count => OPEN
		);
	end generate VC_QUEUES;

end architecture;