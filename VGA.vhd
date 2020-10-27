----------------------------------------------------------------------------------
-- Company:        ITESM - CQ
-- Engineer:       My name
-- 
-- Create Date:    09:54:39 11/07/2017 
-- Design Name: 
-- Module Name:    VGA - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description:    Moore FSM that describes the 
--                 behaviour of a 640 x 480
--                 VGA signal @ 60 Hz
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
-- Commonly used libraries
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

entity VGA is
  -- Screen size, including front and back porch's
  generic (MX_HS : NATURAL := 800;
           MX_VS : NATURAL := 521);
  port (
    Clk    : in  STD_LOGIC; -- Board Clock
	 Rst    : in  STD_LOGIC; -- Board Reset
    X      : out STD_LOGIC_VECTOR(9 downto 0); -- X coordinate of the screen
	 Y      : out STD_LOGIC_VECTOR(9 downto 0); -- Y coordinate of the screen
	 Active : out STD_LOGIC; -- When '1', indicates you are in the screen where pixels can be drawn
	 Hsync  : out STD_LOGIC; -- Horizontal synchronization signal
	 Vsync  : out STD_LOGIC);-- Vertical synchronization signal
end VGA;

architecture Behavioral of VGA is
  -- CONSTANT pixelclk : NATURAL := 25000000; -- Time base
  
  -- Constants used for Horizontal Synchonization
  CONSTANT tAL_HS   : NATURAL := 640; -- Horizontal Active Line Time
  CONSTANT tFP_HS   : NATURAL :=  16; -- Horizontal Front Porch
  CONSTANT tPU_HS   : NATURAL :=  96; -- Horizontal Pulse duration
  CONSTANT tBP_HS   : NATURAL :=  48; -- Horizontal Back Porch
  
  -- Constants used for Vertical Synchonization
  CONSTANT tAT_VS   : NATURAL := 480; -- Vertical Active Time
  CONSTANT tFP_VS   : NATURAL :=  10; -- Vertical Front Porch
  CONSTANT tPU_VS   : NATURAL :=   2; -- Vertical Pulse duration
  CONSTANT tBP_VS   : NATURAL :=  29; -- Vertical Back Porch

  -- Define the states for the FSM
  TYPE state is (AL_HS, FP_HS, PU_HS, BP_HS);
  SIGNAL pr_state, nx_state : state;
  
  -- Define a counter that will be used to determine
  -- when to change from a state to another
  SIGNAL Tiempo  : NATURAL RANGE 0 to MX_HS;

  -- Horizontal and Vertical counters
  SIGNAL CuentaH : NATURAL RANGE 0 to MX_HS;
  SIGNAL CuentaV : NATURAL RANGE 0 to MX_VS;
  
  -- Define a signal for the 25MHz timebase
  SIGNAL En_25   : STD_LOGIC;

begin
  -- Determine the coordinates of the pixel
  -- Pixel = Picture Element
  X <= CONV_STD_LOGIC_VECTOR(CuentaH - 1,10);
  Y <= CONV_STD_LOGIC_VECTOR(CuentaV - 1,10);
  
  -- Determine if pixel is in the permitted zone
  Active <= '1' when (pr_state = AL_HS and CuentaV <= tAT_VS) else
            '0';

  -- Frequency divider process
  -- Obtain a 25 MHz timebase from the Nexys3 
  -- 100 MHz Clock
  FreqDiv: process(Clk,Rst)
    variable Count : STD_LOGIC_VECTOR (1 downto 0);
  begin
    if (Rst = '1') then
	   Count := "00";
		En_25 <= '0';
	 elsif (rising_edge(Clk)) then
		Count := Count + 1;
		if (Count = "11") then
		  En_25 <= '1';
		else
		  En_25 <= '0';
		end if;
	 end if;	   
  end process FreqDiv;
  
  -- State Register Process
  -- Holds the current state of the FSM
  -- and changes to the next
  statereg: process (Clk, Rst, En_25)
  begin
    if (Rst = '1') then
	   pr_state <= AL_HS;
	 elsif (rising_edge(Clk) and En_25 = '1') then
	   if (CuentaH = Tiempo) then
		  pr_state <= nx_state;
		  CuentaH  <= 1;
		else
		  CuentaH  <= CuentaH + 1;
		end if;
		
		-- Increment CuentaV
		-- Check if the state machine is leaving the
		-- Horizontal Front Porch State. According to
		-- the VGA specifications, The Vertical Pulse
		-- should be generated accordingly
		if (CuentaH = Tiempo and pr_state = FP_HS) then
		  if (CuentaV = MX_VS) then
		    CuentaV <= 1;
		  else
		    CuentaV <= CuentaV + 1;
		  end if;
		end if;		
	 end if;
  end process statereg;
  
  -- Define the Next-State Logic Process
  -- Will obtain the next state based on the inputs and current state
  fsm: process (pr_state)
  begin
	case (pr_state) is
	  when AL_HS =>
	    nx_state <=  FP_HS;
		 Tiempo   <= tAL_HS;
		 
	  when FP_HS =>
	    nx_state <=  PU_HS;
		 Tiempo   <= tFP_HS;

     when PU_HS =>
	    nx_state <=  BP_HS;
		 Tiempo   <= tPU_HS;

     when BP_HS =>
	    nx_state <=  AL_HS;
		 Tiempo   <= tBP_HS;
		 
	end case;
  end process fsm;  

  -- If implementing a Moore Machine use the following process
  -- The output of a Moore Machine is determined by the present_state only
  output: process (pr_state)
  begin
    case (pr_state) is
	   when AL_HS  => Hsync <= '1';
		when FP_HS  => Hsync <= '1';
		when PU_HS  => Hsync <= '0';
		when BP_HS  => Hsync <= '1';
		when others => Hsync <= '1';
	 end case;
  end process output;
  
  -- Generate the Vsync signal
  Vsync <= '0' when (CuentaV >= 490) and (CuentaV <= 491) else
           '1';
			  

end Behavioral;











