module spi_dac(
	input						clk,
	
	input		[7:0] 			i_data_spi_0,
	input		[7:0] 			i_data_spi_1,
	input		[7:0] 			i_data_spi_2,
	input		[7:0] 			i_data_spi_3,
	
	input						i_sync,
	
	output						o_dac_data_0,
	output						o_dac_data_1,
	output						o_dac_data_2,
	output						o_dac_data_3,
	
	output						o_dac_cs_n
);


	reg			[15:0] 			Reg_d0;
	reg			[15:0] 			Reg_d1;
	reg			[15:0] 			Reg_d2;
	reg			[15:0] 			Reg_d3;
	
	reg			[15:0] 			Reg_s;

	assign o_dac_data_0 = Reg_d0[15];
	assign o_dac_data_1 = Reg_d1[15];
	assign o_dac_data_2 = Reg_d2[15];
	assign o_dac_data_3 = Reg_d3[15];
	
	assign o_dac_cs_n = Reg_s[15];

	always@(posedge clk)
	begin
		if(i_sync) begin
			Reg_d0 <= {4'b0000, i_data_spi_0, 4'b0000};
			Reg_d1 <= {4'b0000, i_data_spi_1, 4'b0000};
			Reg_d2 <= {4'b0000, i_data_spi_2, 4'b0000};
			Reg_d3 <= {4'b0000, i_data_spi_3, 4'b0000};
			Reg_s <= 0;
		end
		else
			if(~&{Reg_s}) begin
				Reg_d0 <= {Reg_d0[14:0], 1'b0};
				Reg_d1 <= {Reg_d1[14:0], 1'b0};
				Reg_d2 <= {Reg_d2[14:0], 1'b0};
				Reg_d3 <= {Reg_d3[14:0], 1'b0};
				Reg_s <= {Reg_s[14:0], 1'b1};			
			end
	end

endmodule
