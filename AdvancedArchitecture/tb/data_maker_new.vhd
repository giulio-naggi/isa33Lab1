library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;

library std;
use std.textio.all;

entity data_maker is  
  port (
    CLK     : in  std_logic;
    RST_n   : in  std_logic;
    VOUT1    : out std_logic;
    VOUT2    : out std_logic;
    VOUT3    : out std_logic;
    DOUT1    : out std_logic_vector(8 downto 0);
    DOUT2    : out std_logic_vector(8 downto 0);
    DOUT3    : out std_logic_vector(8 downto 0);
	b0 : out std_logic_vector(8 downto 0); 
	b1 : out std_logic_vector(8 downto 0); 
	b2 : out std_logic_vector(8 downto 0); 
	b3 : out std_logic_vector(8 downto 0); 
	b4 : out std_logic_vector(8 downto 0); 
	b5 : out std_logic_vector(8 downto 0); 
	b6 : out std_logic_vector(8 downto 0); 
	b7 : out std_logic_vector(8 downto 0); 
	b8 : out std_logic_vector(8 downto 0); 
	b9 : out std_logic_vector(8 downto 0); 
	b10 : out std_logic_vector(8 downto 0); 
    END_SIM : out std_logic);
end data_maker;

architecture beh of data_maker is

  constant tco : time := 1 ns;

  signal sEndSim : std_logic;
  signal END_SIM_i : std_logic_vector(0 to 10);  

begin 

  b0 <= std_logic_vector(to_signed(-1,9));
  b1 <= std_logic_vector(to_signed(-4,9));
  b2 <= std_logic_vector(to_signed(-7,9));
  b3 <= std_logic_vector(to_signed(16,9));
  b4 <= std_logic_vector(to_signed(70,9));
  b5 <= std_logic_vector(to_signed(101,9));
  b6 <= std_logic_vector(to_signed(70,9));
  b7 <= std_logic_vector(to_signed(16,9));
  b8 <= std_logic_vector(to_signed(-7,9));
  b9 <= std_logic_vector(to_signed(-4,9));
  b10 <= std_logic_vector(to_signed(-1,9));
    

  process (CLK, RST_n)
    file fp_in : text open READ_MODE is "samples.txt";
    variable line_in : line;
    variable x,y,z : integer;
  begin  -- process
    if RST_n = '0' then                 -- asynchronous reset (active low)
      DOUT1 <= (others => '0') after tco;      
      DOUT2 <= (others => '0') after tco;      
      DOUT3 <= (others => '0') after tco;      
      VOUT1 <= '0' after tco;
      VOUT2 <= '0' after tco;
      VOUT3 <= '0' after tco;
      sEndSim <= '0' after tco;
    elsif CLK'event and CLK = '1' then  -- rising clock edge
	  if not endfile(fp_in) then
		readline(fp_in, line_in);
		read(line_in, x);
		if not endfile(fp_in) then
			readline(fp_in, line_in);
			read(line_in, y);
			if not endfile(fp_in) then
				readline(fp_in, line_in);
				read(line_in, z);
				DOUT1 <= std_logic_vector(to_signed(x, 9)) after tco;
				VOUT1 <= '1' after tco;
				DOUT2 <= std_logic_vector(to_signed(y, 9)) after tco;
				VOUT2 <= '1' after tco;
				DOUT3 <= std_logic_vector(to_signed(z, 9)) after tco;
				VOUT3 <= '1' after tco;
				sEndSim <= '0' after tco;
			else
				DOUT1 <= std_logic_vector(to_signed(x, 9)) after tco;
				VOUT1 <= '1' after tco;
				DOUT2 <= std_logic_vector(to_signed(y, 9)) after tco;
				VOUT2 <= '1' after tco;
				VOUT3 <= '0' after tco;        
				sEndSim <= '1' after tco;
			end if;
		else
			DOUT1 <= std_logic_vector(to_signed(x, 9)) after tco;
			VOUT1 <= '1' after tco;
			VOUT2 <= '0' after tco;      
			VOUT3 <= '0' after tco; 
			sEndSim <= '1' after tco;	
		end if;
	  else
		VOUT1 <= '0' after tco;        
		VOUT2 <= '0' after tco;        
		VOUT3 <= '0' after tco;        
		sEndSim <= '1' after tco;
	  end if;
    end if;
  end process;

  process (CLK, RST_n)
  begin  -- process
    if RST_n = '0' then                 -- asynchronous reset (active low)
      END_SIM_i <= (others => '0') after tco;
    elsif CLK'event and CLK = '1' then  -- rising clock edge
      END_SIM_i(0) <= sEndSim after tco;
      END_SIM_i(1 to 10) <= END_SIM_i(0 to 9) after tco;
    end if;
  end process;

  END_SIM <= END_SIM_i(10);  

end beh;
