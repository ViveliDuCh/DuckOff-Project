----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:00:36 12/05/2019 
-- Design Name: 
-- Module Name:    score - Behavioral 
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

entity score is
  port (
   Clk100MHz  : in  STD_LOGIC;
	flag       : in  STD_LOGIC;
	rst      : in  STD_LOGIC;
	anodes     : out STD_LOGIC_VECTOR(3 downto 0);
	Seg_out   : out STD_LOGIC_VECTOR(7 downto 0)
  );
end score;

architecture Behavioral of score is
   constant BoardFreq    : integer := 100_000_000;
	constant DesiredFreq   : integer := 200;
	constant MaxCountM    : integer := BoardFreq/DesiredFreq;
	constant HalfMaxCount: integer := MaxCountM / 2;
	signal Count100M    : integer range 0 to MaxCountM;
	
	-- Other embedded signals
	signal ClkOut : STD_LOGIC;
	signal UniCount: STD_LOGIC_VECTOR(3 downto 0);
	signal DecCount: STD_LOGIC_VECTOR(3 downto 0);
	signal Valor   : STD_LOGIC_VECTOR(3 downto 0);
	signal TC      : STD_LOGIC;


begin
	
--Enables a 200Hz signal
	Frequency_Divider: process(Rst, Clk100MHz)
		begin
			if (rst = '1') then
				Count100M <= 0;
			elsif (rising_edge(Clk100MHz)) then
				if (Count100M = MaxCountM) then
					Count100M <= 0;
				else
					Count100M <= Count100M + 1;
				end if;
			end if;
		end process Frequency_Divider;
	
	ClkOut <= '0' when Count100M < HalfMaxCount else
               '1';

	
	process (Rst,flag, Clk100MHz)
	begin
		if (Rst = '1') then
			UniCount <= (others => '0');
		elsif (rising_edge(Clk100MHz)) then
			if (Flag = '1') then 
				if (UniCount = "1001") then 
					UniCount <= (others => '0');
				else
					UniCount <= UniCount + 1;
				end if;
			end if;
		end if;
		
	end process;
	
	--Terminal count
	TC <= '1' when UniCount = "1001" else
		'0';
	
	
	process (Rst, flag, Clk100MHz)
	begin
		if (Rst = '1') then
			DecCount <= (others => '0');
		elsif (rising_edge(Clk100MHz)) then
			if (flag = '1') then 
				-- Check if hte second units is at terminal count (9)
				if (TC = '1')then
					if (DecCount = "1001") then
							DecCount <= (others => '0');
					else 
						DecCount <= DecCount + 1;
					end if;
				end if;
			end if;
		end if;
	end process;	
	
	
	with ClkOut select
    Valor <= UniCount when '0',
             DecCount when others;
  
  
  
  
  
  process (Valor)
  begin
    case (Valor) is 
      when "0000" => Seg_out <= x"C0";
      when "0001" => Seg_out <= x"F9";
      when "0010" => Seg_out <= x"A4";
      when "0011" => Seg_out <= x"B0";
      when "0100" => Seg_out <= x"99";
      when "0101" => Seg_out <= x"92";
      when "0110" => Seg_out <= x"82";
      when "0111" => Seg_out <= x"F8";
      when "1000" => Seg_out <= x"80";
      when "1001" => Seg_out <= x"90";
      when "1010" => Seg_out <= x"88";
      when "1011" => Seg_out <= x"83";
      when "1100" => Seg_out <= x"C6";
      when "1101" => Seg_out <= x"A1";
      when "1110" => Seg_out <= x"86";
      when "1111" => Seg_out <= x"8E";
      when others => Seg_out <= x"7F";
    end case;
  end process;
  
  Anodes <= "1110" when ClkOut = '0' else
               "1101";

end Behavioral;

