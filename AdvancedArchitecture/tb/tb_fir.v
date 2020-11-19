//`timescale 1ns

module tb_fir ();

   wire CLK_i;
   wire RST_n_i;
   wire [8:0] DIN1_i;
   wire [8:0] DIN2_i;
   wire [8:0] DIN3_i;
   wire VIN1_i;
   wire VIN2_i;
   wire VIN3_i;
   wire [8:0] b0_i;
   wire [8:0] b1_i;
   wire [8:0] b2_i;
   wire [8:0] b3_i;
   wire [8:0] b4_i;
   wire [8:0] b5_i;
   wire [8:0] b6_i;
   wire [8:0] b7_i;
   wire [8:0] b8_i;
   wire [8:0] b9_i;
   wire [8:0] b10_i;
   wire [8:0] DOUT1_i;
   wire [8:0] DOUT2_i;
   wire [8:0] DOUT3_i;
   wire VOUT1_i;
   wire VOUT2_i;
   wire VOUT3_i;
   wire END_SIM_i;

   clk_gen CG(.END_SIM(END_SIM_i),
  	      .CLK(CLK_i),
	      .RST_n(RST_n_i));

   data_maker SM(.CLK(CLK_i),
	         .RST_n(RST_n_i),
			 .VOUT1(VIN1_i),
			 .VOUT2(VIN2_i),
			 .VOUT3(VIN3_i),
			 .DOUT1(DIN1_i),
			 .DOUT2(DIN2_i),
			 .DOUT3(DIN3_i),
			 .b0(b0_i),
			 .b1(b1_i),
			 .b2(b2_i),
			 .b3(b3_i),
			 .b4(b4_i),
			 .b5(b5_i),
			 .b6(b6_i),
			 .b7(b7_i),
			 .b8(b8_i),
			 .b9(b9_i),
			 .b10(b10_i),
			 .END_SIM(END_SIM_i));

   FIR UUT(.CLK(CLK_i),
	     .RST_n(RST_n_i),
	     .DIN1(DIN1_i),
	     .DIN2(DIN2_i),
	     .DIN3(DIN3_i),
		 .VIN1(VIN1_i),
		 .VIN2(VIN2_i),
		 .VIN3(VIN3_i),
		 .b0(b0_i),
		 .b1(b1_i),
		 .b2(b2_i),
		 .b3(b3_i),
		 .b4(b4_i),
		 .b5(b5_i),
		 .b6(b6_i),
		 .b7(b7_i),
		 .b8(b8_i),
		 .b9(b9_i),
		 .b10(b10_i),
		 .DOUT1(DOUT1_i),
		 .DOUT2(DOUT2_i),
		 .DOUT3(DOUT3_i),
		 .VOUT1(VOUT1_i),
		 .VOUT2(VOUT2_i),
		 .VOUT3(VOUT3_i));

   data_sink DS(.CLK(CLK_i),
		.RST_n(RST_n_i),
		.VIN1(VOUT1_i),
		.VIN2(VOUT2_i),
		.VIN3(VOUT3_i),
		.DIN1(DOUT1_i),  
		.DIN2(DOUT2_i),   
		.DIN3(DOUT3_i));   

endmodule

		   
