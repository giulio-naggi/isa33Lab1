library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adder is 
	port(A,B : in signed(8 downto 0);
		S: out signed(8 downto 0));
end entity;

architecture behavioral of adder is
begin
	S <= A + B;
end architecture;