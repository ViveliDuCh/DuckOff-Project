----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:38:06 12/03/2019 
-- Design Name: 
-- Module Name:    freqDivider60 - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity freqDividerF is
  port (
	Clk100MHz : in STD_LOGIC;
	reset     : in STD_LOGIC;
	enable2  : out STD_LOGIC
  );
end freqDividerF;

architecture Behavioral of freqDividerF is
  -- Embedded signals used by the Frequency_Divider
  constant BoardFreq   : integer := 100_000_000;
  constant DesiredFreq : integer := 240;
  constant MaxCountM   : integer := BoardFreq/DesiredFreq;
  constant HalfMaxCount: integer := MaxCountM / 2;
  signal Count100M : integer range 0 to MaxCountM;

begin

  -- Implementation of a Frequency Divider
  -- Derive a 200Hz Enable signal from the
  -- 100,000,000 Hz Xtal Oscillator found on
  -- the Nexys 3 board. The Duty Cycle of the
  -- 200Hz Enable signal is 50%
  Frequency_Divider: process(Clk100MHz,Reset)
  begin
    if (Reset = '1') then
	   Count100M <= 0;
    elsif (rising_edge(Clk100MHz)) then
	   if (Count100M = MaxCountM) then
		  Count100M <= 0;
		  enable2   <= '1';
		else
		  Count100M <= Count100M + 1;
		  enable2   <= '0';
		end if;
	 end if;	  
  end process Frequency_Divider;


end Behavioral;

