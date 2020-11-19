library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity multiplier is 
	port(A,B : in signed(8 downto 0);
		M: out signed(8 downto 0));
end entity;

architecture behavioral of multiplier is
	signal mul_tmp: signed(17 downto 0);
begin
	mul_tmp <= A * B;
	M <= mul_tmp(16 downto 8);
end architecture;