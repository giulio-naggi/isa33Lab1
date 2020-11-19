library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FIR is
	port(
		DIN1 : in std_logic_vector(8 downto 0);
		DIN2 : in std_logic_vector(8 downto 0);
		DIN3 : in std_logic_vector(8 downto 0);
		VIN1 : in std_logic;
		VIN2 : in std_logic;
		VIN3 : in std_logic;
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
		DOUT1 : out std_logic_vector(8 downto 0);
		DOUT2 : out std_logic_vector(8 downto 0);
		DOUT3 : out std_logic_vector(8 downto 0);
		VOUT1 : out std_logic;
		VOUT2 : out std_logic;
		VOUT3 : out std_logic);
end entity;

architecture mixed of FIR is

	component REG is 
		port(RST,EN,CLK: in std_logic;
			IN_DATA: in signed(8 downto 0);
			OUT_DATA: out signed(8 downto 0));
	end component;
	
	component FF is
		port(RST,CLK: in std_logic;
			IN_DATA: in std_logic;
			OUT_DATA: out std_logic);
	end component;
	
	component adder is 
		port(A,B : in signed(8 downto 0);
			S: out signed(8 downto 0));
	end component;
	
	component multiplier is 
		port(A,B : in signed(8 downto 0);
			M: out signed(8 downto 0));
	end component;
	-- type used to define all the nodes(22 downto 0) of the 3 unfolded architectures(2 downto 0)
	type N_type is array (2 downto 0,22 downto 0) of signed(8 downto 0);
	-- type used to define the arcs of the 3 unfolded architectures
	type arc_type is array (0 to 2, 0 to 31) of integer;
	-- type used to define the arcs of the 3 vin chains
	type arc_type_vin is array (0 to 2, 0 to 10) of integer;
	-- type used to define all the register chains present in the 3 unfolded architectures
	type chain_type is array (2 downto 0, 31 downto 0,8 downto 0) of signed(8 downto 0);
	
	-- index of the arc destination architecture
	constant j : arc_type :=   ((0,2,1,0,2,1,0,2,1,0,2,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0),
								(1,0,2,1,0,2,1,0,2,1,0,0,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,1),
								(2,1,0,2,1,0,2,1,0,2,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2));
	-- number of registers present in the chain of each arc
	constant wr : arc_type:=   ((0,0,1,2,2,3,4,4,5,6,6,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
								(0,1,1,2,3,3,4,5,5,6,7,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
								(0,1,2,2,3,4,4,5,6,6,7,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0));
	-- destination node of each arc
	constant dest : arc_type:= ((1,2,3,4,5,6,7,8,9,10,11,12,12,13,14,15,16,17,18,19,20,21,13,14,15,16,17,18,19,20,21,22),
								(1,2,3,4,5,6,7,8,9,10,11,12,12,13,14,15,16,17,18,19,20,21,13,14,15,16,17,18,19,20,21,22),
								(1,2,3,4,5,6,7,8,9,10,11,12,12,13,14,15,16,17,18,19,20,21,13,14,15,16,17,18,19,20,21,22));
	-- start node of each arc
	constant start : arc_type:=((0,0,0,0,0,0,0,0,0,0,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21),
								(0,0,0,0,0,0,0,0,0,0,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21),
								(0,0,0,0,0,0,0,0,0,0,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21));
								
	signal node_in_1,node_in_2,node_out: N_type; -- signals defining the input and output ports of the nodes
	signal reg_chain : chain_type; -- signal defining the register chains
	signal reg_vin_chain1 : std_logic_vector(2 downto 0); -- VIN1 register chain
	signal reg_vin_chain2 : std_logic_vector(3 downto 0); -- VIN2 register chain
	signal reg_vin_chain3 : std_logic_vector(3 downto 0); -- VIN3 register chain
	signal vin_internal : std_logic_vector(2 downto 0); -- VIN signals after the input register
	signal node_in_vin : std_logic_vector(2 downto 0); -- destinantion nodes of the VIN chains
	
begin
	
	node_in_2(0,0) <= signed(DIN1); 
	node_in_2(1,0) <= signed(DIN2);
	node_in_2(2,0) <= signed(DIN3);
	
	-- DIN1, DIN2 and DIN3 input registers
	in_reg_1 : REG port map(CLK => CLK, RST => RST_n, EN => VIN1, IN_DATA => node_in_2(0,0), OUT_DATA => node_out(0,0));
	in_reg_2 : REG port map(CLK => CLK, RST => RST_n, EN => VIN2, IN_DATA => node_in_2(1,0), OUT_DATA => node_out(1,0));
	in_reg_3 : REG port map(CLK => CLK, RST => RST_n, EN => VIN3, IN_DATA => node_in_2(2,0), OUT_DATA => node_out(2,0));
	-- VIN1, VIN2 and VIN3 input registers
	in_vin_reg_1 : FF port map (RST => RST_n, CLK => CLK, IN_DATA => VIN1, OUT_DATA => vin_internal(0));
    in_vin_reg_2 : FF port map (RST => RST_n, CLK => CLK, IN_DATA => VIN2, OUT_DATA => vin_internal(1));
    in_vin_reg_3 : FF port map (RST => RST_n, CLK => CLK, IN_DATA => VIN3, OUT_DATA => vin_internal(2));
	-- implementaation of the 3 VIN chains 
	vin_1_0 : FF port map(CLK => CLK, RST => RST_n, IN_DATA => vin_internal(0), OUT_DATA => reg_vin_chain1(0));
	vin_2_0 : FF port map(CLK => CLK, RST => RST_n, IN_DATA => vin_internal(1), OUT_DATA => reg_vin_chain2(0));
	vin_3_0 : FF port map(CLK => CLK, RST => RST_n, IN_DATA => vin_internal(2), OUT_DATA => reg_vin_chain3(0));
	
	chain_gen : for i in 1 to 2 generate
		vin_1_i : FF port map(CLK => CLK, RST => RST_n, IN_DATA => reg_vin_chain1(i-1), OUT_DATA => reg_vin_chain1(i));
		vin_2_i : FF port map(CLK => CLK, RST => RST_n, IN_DATA => reg_vin_chain2(i-1), OUT_DATA => reg_vin_chain2(i));
		vin_3_i : FF port map(CLK => CLK, RST => RST_n, IN_DATA => reg_vin_chain3(i-1), OUT_DATA => reg_vin_chain3(i));
	end generate;
	
	vin_2_3 : FF port map(CLK => CLK, RST => RST_n, IN_DATA => reg_vin_chain2(2), OUT_DATA => reg_vin_chain2(3));
	vin_3_3 : FF port map(CLK => CLK, RST => RST_n, IN_DATA => reg_vin_chain3(2), OUT_DATA => reg_vin_chain3(3));

	pipe_generate: for p in 0 to 2 generate 
		
		-- assignment of the coefficients to one input node of the multipliers
		node_in_1(p,1) <= signed(b0);
		node_in_1(p,2) <= signed(b1);
		node_in_1(p,3) <= signed(b2);
		node_in_1(p,4) <= signed(b3);
		node_in_1(p,5) <= signed(b4);
		node_in_1(p,6) <= signed(b5);
		node_in_1(p,7) <= signed(b6);
		node_in_1(p,8) <= signed(b7);
		node_in_1(p,9) <= signed(b8);
		node_in_1(p,10) <= signed(b9);
		node_in_1(p,11) <= signed(b10);
		-- generation of the multipliers
		multiplier_generate: for i in 1 to 11 generate
			MUL_p_i: multiplier port map (A => node_in_1(p,i), B => node_in_2(p,i), M => node_out(p,i));
		end generate;
		-- generations of the adders
		adder_generate: for i in 12 to 21 generate
			ADD_p_i: adder port map (A => node_in_1(p,i), B => node_in_2(p,i), S => node_out(p,i));
		end generate;
		
	end generate;
	-- loop scanning the 3 architectures
	arc_gen_p: for p in 0 to 2 generate
		-- loop scanning all the arcs inside each architecture
		arc_gen_i : for i in 0 to 31 generate
			-- generation of the register chain
			reg_chain(p,i,0) <= node_out(p,start(p,i));
			ff_chain_0 : for k in 1 to wr(p,i) generate
					reg_gen_k : REG port map(RST => RST_n,EN =>'1',CLK => CLK, IN_DATA => reg_chain(p,i,k-1), OUT_DATA => reg_chain(p,i,k)); 
			end generate;
			-- assignment of the signal coming out from the register chain to one input port of the multiplier or adder depending 
			-- on the start node of the arc
			out_chain_mul : if (start(p,i) > 1 and start(p,i) < 12) or start(p,i) = 0 generate
				node_in_2(j(p,i),dest(p,i)) <= reg_chain(p,i,wr(p,i));
			end generate;
			out_chain_add : if start(p,i) >= 12 or start(p,i) = 1 generate
				node_in_1(j(p,i),dest(p,i)) <= reg_chain(p,i,wr(p,i));
			end generate;
		end generate;
	end generate;
	-- DOUT1, DOUT2 and DOUT3 output registers
	dout_reg_1 : REG port map(CLK => CLK, RST => RST_n, EN => reg_vin_chain2(3), IN_DATA => node_in_1(0,22), OUT_DATA => node_out(0,22));
	dout_reg_2 : REG port map(CLK => CLK, RST => RST_n, EN => reg_vin_chain3(3), IN_DATA => node_in_1(1,22), OUT_DATA => node_out(1,22));
	dout_reg_3 : REG port map(CLK => CLK, RST => RST_n, EN => reg_vin_chain1(2), IN_DATA => node_in_1(2,22), OUT_DATA => node_out(2,22));
	-- VOUT1, VOUT2 and VOUT3 output registers
	vout_reg_1 : FF port map(CLK => CLK, RST => RST_n, IN_DATA => reg_vin_chain2(3), OUT_DATA => VOUT1);
	vout_reg_2 : FF port map(CLK => CLK, RST => RST_n, IN_DATA => reg_vin_chain3(3), OUT_DATA => VOUT2);
	vout_reg_3 : FF port map(CLK => CLK, RST => RST_n, IN_DATA => reg_vin_chain1(2), OUT_DATA => VOUT3);
	
	
	DOUT1 <= std_logic_vector(node_out(0,22));
	DOUT2 <= std_logic_vector(node_out(1,22));
	DOUT3 <= std_logic_vector(node_out(2,22));
	
end architecture;
















