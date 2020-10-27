----------------------------------------------------------------------------------
-- Company:        ITESM - CQ
-- Engineer:       Elmer Homero
-- 
-- Create Date:    07:21:51 11/13/2019 
-- Design Name: 
-- Module Name:    Top - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description:    Video Graphics Adapter (VGA)
--                 controller based on a Moore FSM
--                 Resolution of the screen 640 x 480
--                 Pixel depth = 8 (256 possible colors per pixel)
--                 Refresh rate = 60 Hz
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

entity Top is
    Port ( Clk         : in  STD_LOGIC;
           Rst         : in  STD_LOGIC;
			  rightButton : in  STD_LOGIC;
			  leftButton  : in  STD_LOGIC;
           Red         : out STD_LOGIC_VECTOR (2 downto 0);
           Green       : out STD_LOGIC_VECTOR (2 downto 0);
           Blue        : out STD_LOGIC_VECTOR (1 downto 0);
           Hsync       : out STD_LOGIC;
           Vsync       : out STD_LOGIC;
			  anode       : out STD_LOGIC_VECTOR(3 downto 0);
			  segment     : out STD_LOGIC_VECTOR(7 downto 0));
end Top;

architecture Behavioral of Top is
  -- Component declarations
  
  component freqDivider60 
  port (
	Clk100MHz : in STD_LOGIC;
	reset     : in STD_LOGIC;
	enable60  : out STD_LOGIC
  );
  end component;
  
  component freqDividerF 
  port (
	Clk100MHz : in STD_LOGIC;
	reset     : in STD_LOGIC;
	enable2   : out STD_LOGIC
  );
  end component;
  
  component freqDividerY
  port (
	Clk100MHz : in STD_LOGIC;
	reset     : in STD_LOGIC;
	enable3   : out STD_LOGIC
  );
  end component;
  
  -- VGA controller component
  -- Generated the necessary timing for the VGA signal
  component VGA
  port (
    Clk    : in  STD_LOGIC; -- Board Clock
	 Rst    : in  STD_LOGIC; -- Board Reset
    X      : out STD_LOGIC_VECTOR(9 downto 0); -- X coordinate of the screen
	 Y      : out STD_LOGIC_VECTOR(9 downto 0); -- Y coordinate of the screen
	 Active : out STD_LOGIC; -- When '1', indicates you are in the screen where pixels can be drawn
	 Hsync  : out STD_LOGIC; -- Horizontal synchronization signal
	 Vsync  : out STD_LOGIC);-- Vertical synchronization signal
  end component;

  -- Component that will contain the image/figure that
  -- will appear on the screen
  component VGA_Display
  port (
	 Xin       : in  STD_LOGIC_VECTOR(9 downto 0); -- Column screen coordinate
	 Yin       : in  STD_LOGIC_VECTOR(9 downto 0); -- Row screen coordinate
	 En        : in  STD_LOGIC; -- When '1', pixels can be drawn 
	 Enable60  : in  STD_LOGIC;
	 Enable2   : in  STD_LOGIC;
	 Enable3   : in  STD_LOGIC;
	 rightB    : in  STD_LOGIC;
	 leftB     : in  STD_LOGIC;
	 rst       : in  STD_LOGIC;
	 clk       : in  STD_LOGIC;
	 flagOut      : out STD_LOGIC;
	 R   		  : out STD_LOGIC_VECTOR(2 downto 0); -- 3-bit Red channel
	 G   		  : out STD_LOGIC_VECTOR(2 downto 0); -- 3-bit Green channel
	 B   		  : out STD_LOGIC_VECTOR(1 downto 0));-- 2-bit Blue channel
  end component;
  
  component score
  port (
   Clk100MHz : in STD_LOGIC;
	Flag   : in  STD_LOGIC;
	rst     : in STD_LOGIC;
	anodes     : out STD_LOGIC_VECTOR(3 downto 0);
	Seg_out   : out STD_LOGIC_VECTOR(7 downto 0)
  );
  end component;

  -- Embedded signals to interconnect components
  signal X_emb       : STD_LOGIC_VECTOR(9 downto 0);
  signal Y_emb       : STD_LOGIC_VECTOR(9 downto 0);  
  signal Active_emb  : STD_LOGIC;
  signal en60        : STD_LOGIC;
  signal en140       : STD_LOGIC;
  signal en150       : STD_LOGIC;
  signal scoreFlag   : STD_LOGIC;

begin
  -- Component instantiation (component connecting)
  
  -- New style of instantiation
  C01 : VGA 
  port map (
    Clk,
	 Rst,
	 X_emb,
	 Y_emb,
	 Active_emb,
    Hsync,
	 Vsync);
  
  -- Classic style of instantiation
  C02 : VGA_DISPLAY
  port map (
    Xin => X_emb,
	 Yin => Y_emb,
    En  => Active_emb,
	 Enable60 => En60,
	 Enable2 => En140,
	 Enable3 => En150,
	 rightB => rightButton,
	 leftB  => leftButton,
	 rst => Rst,
	 clk => clk,
	 FlagOut => scoreFlag,
	 R   => Red,
	 G   => Green,
	 B   => Blue);
	 
  C03 : freqDivider60
  port map (
	Clk100MHz => Clk,
	reset     => rst,
	enable60  => en60
  );
  
  C04 : freqDividerF
  port map (
	Clk100MHz  => Clk,
	reset      => rst,
	enable2    => en140
  );
  
  C05 : freqDividerY
  port map (
	Clk100MHz  => Clk,
	reset      => rst,
	enable3    => en150
  );

  C06 : score
  port map (
   Clk100MHz  => Clk,
	flag       => scoreFlag,
	rst      => rst,
	anodes     => anode,
	Seg_out   => segment);
end Behavioral;






