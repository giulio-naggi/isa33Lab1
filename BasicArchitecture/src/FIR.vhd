library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FIR is
	port(
		DIN : in std_logic_vector(8 downto 0);
		VIN : in std_logic;
		RST_n : in std_logic;
		CLK : in std_logic;
		b0 : in std_logic_vector(8 downto 0); 
		b1 : in std_logic_vector(8 downto 0); 
		b2 : in std_logic_vector(8 downto 0); 
		b3 : in std_logic_vector(8 downto 0); 
		b4 : in std_logic_vector(8 downto 0); 
		b5 : in std_logic_vector(8 downto 0); 
		b6 : in std_logic_vector(8 downto 0); 
		b7 : in std_logic_vector(8 downto 0); 
		b8 : in std_logic_vector(8 downto 0); 
		b9 : in std_logic_vector(8 downto 0); 
		b10 : in std_logic_vector(8 downto 0); 
		DOUT : out std_logic_vector(8 downto 0);
		VOUT : out std_logic);
end entity;

architecture BEHAVIORAL of FIR is
	
	component REG is 
		port(RST,EN,CLK: in std_logic;
			IN_DATA: in signed(8 downto 0);
			OUT_DATA: out signed(8 downto 0));
	end component;
	
	component ff is
		port(RST,CLK: in std_logic;
		IN_DATA: in std_logic;
		OUT_DATA: out std_logic);
	end component;
	-- type used to define registers' output
	type reg_type is array (11 downto 0) of signed(8 downto 0);
	-- type used to define adders' output
	type add_type is array (10 downto 0) of signed(8 downto 0);
	-- type used to define multipliers' output
	type mul_type is array (10 downto 0) of signed(17 downto 0);
	-- type used to define the input signals b
	type H_type is array (10 downto 0) of signed(8 downto 0);
	signal reg_pipe : reg_type;
	signal mul_out : mul_type;
	signal add_out : add_type;
	signal H : H_type;
	signal DIN_s : signed(8 downto 0);
	signal VIN_internal: std_logic; -- correspond to vin delayed by one clock cycle
	
begin
	
	-- assign the inputs to signals to easily menage them
	DIN_s <= signed(DIN);
	H(0) <= signed(b0);
	H(1) <= signed(b1);
	H(2) <= signed(b2);
	H(3) <= signed(b3);
	H(4) <= signed(b4);
	H(5) <= signed(b5);
	H(6) <= signed(b6);
	H(7) <= signed(b7);
	H(8) <= signed(b8);
	H(9) <= signed(b9);
	H(10) <= signed(b10);
	
	-- input registers for DIN and VIN
	reg_0 : REG port map(RST => RST_n, EN => VIN, CLK => CLK, IN_DATA => DIN_s, OUT_DATA => reg_pipe(0));
	vin_in : ff port map(RST => RST_n, CLK => CLK, IN_DATA => VIN, OUT_DATA => VIN_internal);
	
	-- FIR generation
	mul_out(0) <= reg_pipe(0) * H(0);
	add_out(0) <= mul_out(0)(16 downto 8);
	
	g1: for i in 1 to 10 generate
		reg_i : REG port map(RST => RST_n, EN => '1', CLK => CLK, IN_DATA => reg_pipe(i-1), OUT_DATA => reg_pipe(i));
		mul_out(i) <= H(i) * reg_pipe(i);
		add_out(i) <= mul_out(i)(16 downto 8) + add_out(i-1);
	end generate;
	
	reg_11 : REG port map(RST => RST_n, EN => VIN_internal, CLK => CLK, IN_DATA => add_out(10), OUT_DATA => reg_pipe(11));
	
	-- output registers for DOUT and VOUT
	DOUT <= std_logic_vector(reg_pipe(11));
	vin_out : ff port map(RST => RST_n, CLK => CLK, IN_DATA => VIN_internal, OUT_DATA => VOUT);
	
	
	
end architecture;
