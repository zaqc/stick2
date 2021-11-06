`timescale 1ns/1ps

module clock_sync(
	input						rst_n,
	input						hi_clk,		// 200 MHz for Pulser
	
	input						sys_clk,	// 125 MHz System Clock
	
	input						i_sync,		// on System Clock
		
	output						o_main_sync,	// on ADC_CLK 
	
	output						o_adc_clk	// 25 MHz for ADC
);

	reg			[0:0]			prev_sync;
	always @ (posedge sys_clk) prev_sync <= i_sync;
	
	reg			[0:0]			sync_latch;
	always @ (posedge sys_clk or negedge rst_n)
		if(~rst_n)
			sync_latch <= 1'b0;
		else
			if(~prev_sync & i_sync)
				sync_latch <= 1'b1;			
			else
				if(sync_latch && prev_sync_latch)
					sync_latch <= 1'b0;
										
	reg			[0:0]			prev_sync_latch;
	always @ (posedge adc_clk) prev_sync_latch <= sync_latch;
	
	assign o_main_sync = sync_latch & ~prev_sync_latch;
			
	wire						adc_clk_flip;
	assign adc_clk_flip = adc_clk_div_cntr == 4'd4;

	
	reg			[3:0]			adc_clk_div_cntr;
	reg			[0:0]			adc_clk;
	always @ (posedge hi_clk or negedge rst_n)
		if(~rst_n) begin
			adc_clk <= 1'b0;
			adc_clk_div_cntr <= 4'd0;
		end
		else
			if(adc_clk_flip) begin
				adc_clk_div_cntr <= 4'd0;
				adc_clk <= ~adc_clk;
			end
			else 
				adc_clk_div_cntr <= adc_clk_div_cntr + 1'd1;
			
	assign o_adc_clk = adc_clk;
	
endmodule

