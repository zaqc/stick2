module dac_level(
	input						rst_n,
	input						clk,
	
	input						i_sync,
	
	input		[7:0]			i_dac_data_0,
	input		[7:0]			i_dac_data_1,
	input		[7:0]			i_dac_data_2,
	input		[7:0]			i_dac_data_3,
	
	output						o_sync_delayed,
	
	output						o_dac_data_0,
	output						o_dac_data_1,
	output						o_dac_data_2,
	output						o_dac_data_3,
	
	output						o_dac_cs_n
);

	spi_dac spi_dac_unit_0(
		.clk(clk),
		
		.i_data_spi_0(i_dac_data_0),
		.i_data_spi_1(i_dac_data_1),
		.i_data_spi_2(i_dac_data_2),
		.i_data_spi_3(i_dac_data_3),
		
		.i_sync(i_sync),
		
		.o_dac_data_0(o_dac_data_0),
		.o_dac_data_1(o_dac_data_1),
		.o_dac_data_2(o_dac_data_2),
		.o_dac_data_3(o_dac_data_3),
		
		.o_dac_cs_n(o_dac_cs_n)
	);
	
	reg			[0:0]			prev_sync;
	always @ (posedge clk) prev_sync <= i_sync;
	
	reg			[6:0]			dly_cntr;
	initial dly_cntr <= 7'd0;
	wire						dly_complite;
	assign dly_complite = &{dly_cntr};
	always @ (posedge clk)
		if(~prev_sync & i_sync)
			dly_cntr <= 7'd0;
		else
			dly_cntr <= dly_complite ? dly_cntr : dly_cntr + 1'd1;
			
	reg			[0:0]			prev_dly_complite;
	always @ (posedge clk) prev_dly_complite <= dly_complite;
		
	assign o_sync_delayed = ~prev_dly_complite & dly_complite;

endmodule

