`timescale 1ns/1ps

module adc_data(
	input						rst_n,
	input						clk,
	
	input						i_sync,
	
	input		[7:0]			i_adc_data,
	input		[7:0]			i_ratio,
	
	output		[31:0]			o_out_data,
	output						o_out_vld,
	
	input						i_complite
);

	reg			[0:0]			out_vld;
	reg			[7:0]			out_data;
	reg			[7:0]			adc_data;
	reg			[7:0]			r_cntr;
	
	reg			[0:0]			run;

	always @ (posedge clk or negedge rst_n)
		if(~rst_n) begin
			out_vld <= 1'b0;
			run <= 1'b0;
		end
		else
			if(i_sync) begin
				adc_data <= i_adc_data;
				r_cntr <= 8'd0;
				out_vld <= 1'd0;
				run <= 1'b1;
			end			
			else
			if(i_complite) begin
				out_vld <= 1'b0;
				run <= 1'b0;
			end
			else
				if(run) begin
					if(r_cntr + 1'd1 < i_ratio) begin
						r_cntr <= r_cntr + 1'd1;
						adc_data <= adc_data < i_adc_data ? i_adc_data : adc_data;
						out_vld <= 1'b0;
					end
					else begin
						r_cntr <= 1'd0;
						out_data <= adc_data;
						adc_data <= i_adc_data;
						out_vld <= 1'b1;
					end
				end
				
	data_align data_align_unit(
		.rst_n(rst_n),
		.clk(clk),
		.i_data(out_data),
		.i_wren(out_vld),
		
		.i_sync(i_sync),
		
		.o_out_data(o_out_data),
		.o_out_vld(o_out_vld)
	);
endmodule
