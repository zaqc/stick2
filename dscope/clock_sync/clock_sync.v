`timescale 1ns/1ps

module clock_sync(
	input						rst_n,
	input						hi_clk,		// 200 MHz for Pulser	
	input						sys_clk,	// 100 MHz System Clock
	input						adc_clk,		// 25 MHz for ADC
	
	input						i_sync,		// on System Clock 100 MHz
		
	output						o_hi_sync,	// sync on hi_clk
	output						o_sys_sync,	// sync on sys_clk
	output						o_adc_sync	// sync on adc_clk
	
);

	reg			[0:0]			prev_sync;
	always @ (posedge sys_clk) prev_sync <= i_sync;
	
	reg			[0:0]			sync_latch;
	initial sync_latch <= 1'b0;
	
	always @ (posedge sys_clk)
		if(i_sync & ~prev_sync)
			sync_latch <= 1'b1;
		else
			if(hi_latch & adc_latch)
				sync_latch <= 1'b0;
				
	assign o_sys_sync = ~prev_sync & i_sync;

					
	reg			[0:0]			adc_latch;
	always @ (posedge adc_clk)
		adc_latch <= sync_latch;
		
	reg			[0:0]			prev_adc_latch;
	always @ (posedge adc_clk)
		prev_adc_latch <= adc_latch;
		
	assign o_adc_sync = ~prev_adc_latch & adc_latch;
		
	
	reg			[0:0]			hi_latch;
	always @ (posedge hi_clk)
		hi_latch <= adc_latch;
		
	reg			[0:0]			prev_hi_latch;
	always @ (posedge hi_clk)
		prev_hi_latch <= hi_latch;
		
	assign o_hi_sync = ~prev_hi_latch & hi_latch;
		
endmodule

