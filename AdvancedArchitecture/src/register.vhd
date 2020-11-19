library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity REG is 
	port(RST,EN,CLK: in std_logic;
		IN_DATA: in signed(8 downto 0);
		OUT_DATA: out signed(8 downto 0));
end entity;

architecture behavioral of REG is
begin
	reg: process (CLK, RST)
    begin  -- process IR_P
      if RST = '0' then                 -- asynchronous reset (active low)
        OUT_DATA <= (others => '0');
      elsif CLK'event and CLK = '1' then  -- rising clock edge
        if (EN = '1') then
          OUT_DATA <= IN_DATA;
        end if;
      end if;
    end process;
end architecture;