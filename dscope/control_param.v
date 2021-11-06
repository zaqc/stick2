`timescale 1ns/1ps

module control_param(
	input					rst_n,

	input		[1:0]		i_slot,			// slot number
	
	output		[15:0]		o_ts_time_0,	// time slot periods
	output		[15:0]		o_ts_time_1,
	output		[15:0]		o_ts_time_2,
	output		[15:0]		o_ts_time_3,
	
	output		[3:0]		o_pulse_mask_0,
	output		[3:0]		o_pulse_mask_1,
	output		[3:0]		o_pulse_mask_2,
	output		[3:0]		o_pulse_mask_3,
	
	output		[7:0]		o_pulse_hit_0,
	output		[7:0]		o_pulse_hit_1,
	output		[7:0]		o_pulse_hit_2,
	output		[7:0]		o_pulse_hit_3,
	
	output		[7:0]		o_pulse_gnd_0,
	output		[7:0]		o_pulse_gnd_1,
	output		[7:0]		o_pulse_gnd_2,
	output		[7:0]		o_pulse_gnd_3,
	
	output		[3:0]		o_pulse_count_0,
	output		[3:0]		o_pulse_count_1,
	output		[3:0]		o_pulse_count_2,
	output		[3:0]		o_pulse_count_3,
	
	output		[15:0]		o_pulse_hush_0,
	output		[15:0]		o_pulse_hush_1,
	output		[15:0]		o_pulse_hush_2,
	output		[15:0]		o_pulse_hush_3,
	
	output		[1:0]		o_adc_vchn_0,
	output		[1:0]		o_adc_vchn_1,
	output		[1:0]		o_adc_vchn_2,
	output		[1:0]		o_adc_vchn_3,
	
	output		[7:0]		o_adc_tick_0,
	output		[7:0]		o_adc_tick_1,
	output		[7:0]		o_adc_tick_2,
	output		[7:0]		o_adc_tick_3,
	
	output		[7:0]		o_adc_ratio_0,
	output		[7:0]		o_adc_ratio_1,
	output		[7:0]		o_adc_ratio_2,
	output		[7:0]		o_adc_ratio_3
);

	reg			[15:0]		ts_time_0;
	reg			[15:0]		ts_time_1;
	reg			[15:0]		ts_time_2;
	reg			[15:0]		ts_time_3;

	reg			[3:0]		pulse_mask[0:15];
	
	reg			[7:0]		pulse_hit[0:15];
	reg			[7:0]		pulse_gnd[0:15];
	reg			[3:0]		pulse_count[0:15];
	reg			[15:0]		pulse_hush[0:15];	// blunch time (327 uSec max)
	
	reg			[1:0]		adc_vchn[0:15];
	reg			[7:0]		adc_tick[0:15];
	reg			[7:0]		adc_ratio[0:15];

	reg		 	[5:0]		i;
	
	always @ (negedge rst_n)
		if(~rst_n) begin
			`ifdef TESTMODE
			ts_time_0 <= 16'd1200;
			ts_time_1 <= 16'd1200;
			ts_time_2 <= 16'd1200;
			ts_time_3 <= 16'd800;
			`else
			ts_time_0 <= 16'd9000;	// 180 us
			ts_time_1 <= 16'd9000;
			ts_time_2 <= 16'd9000;
			ts_time_3 <= 16'd5000;	// 100 us for PC Channel
			`endif
			
			`ifdef TESTMODE
			for(i = 5'd0; i < 5'd16; i = i + 1'd1) begin
				pulse_mask[i] <= 1'd1 << i[1:0];
				pulse_hit[i] <= i == 5'd15 ? 8'd2 : 8'd10;
				pulse_gnd[i] <= i == 5'd15 ? 8'd18 : 8'd10;
				pulse_count[i] <= i == 5'd15 ? 4'd1 : 4'd4;
				pulse_hush[i] <= 16'd40;	// 5 uSec (200 ticks == 1 uSec)
				
				adc_vchn[i] <= i[1:0];
				adc_tick[i] <= 8'd1 + i;//16;
				adc_ratio[i] <= 8'd4;
			end
			`else
			for(i = 5'd0; i < 5'd16; i = i + 1'd1) begin
				pulse_mask[i] <= 1'd1 << i[1:0];
				pulse_hit[i] <= i == 5'd15 ? 8'd20 : 8'd100;
				pulse_gnd[i] <= i == 5'd15 ? 8'd180 : 8'd100;
				pulse_count[i] <= i == 5'd15 ? 4'd1 : 4'd4;
				pulse_hush[i] <= 16'd1000;	// 5 uSec (200 ticks == 1 uSec)
				
				adc_vchn[i] <= i[1:0];
				adc_tick[i] <= 8'd128;
				adc_ratio[i] <= 8'd8;
			end
			`endif
		end
		
	assign o_ts_time_0 = ts_time_0;
	assign o_ts_time_1 = ts_time_1;
	assign o_ts_time_2 = ts_time_2;
	assign o_ts_time_3 = ts_time_3;
	
	assign o_pulse_mask_0 = pulse_mask[{2'd0, i_slot}];
	assign o_pulse_mask_1 = pulse_mask[{2'd1, i_slot}];
	assign o_pulse_mask_2 = pulse_mask[{2'd2, i_slot}];
	assign o_pulse_mask_3 = pulse_mask[{2'd3, i_slot}];
		
	assign o_pulse_hit_0 = pulse_hit[{2'd0, i_slot}];
	assign o_pulse_hit_1 = pulse_hit[{2'd1, i_slot}];
	assign o_pulse_hit_2 = pulse_hit[{2'd2, i_slot}];
	assign o_pulse_hit_3 = pulse_hit[{2'd3, i_slot}];
	
	assign o_pulse_gnd_0 = pulse_gnd[{2'd0, i_slot}];
	assign o_pulse_gnd_1 = pulse_gnd[{2'd1, i_slot}];
	assign o_pulse_gnd_2 = pulse_gnd[{2'd2, i_slot}];
	assign o_pulse_gnd_3 = pulse_gnd[{2'd3, i_slot}];
	
	assign o_pulse_count_0 = pulse_count[{2'd0, i_slot}];
	assign o_pulse_count_1 = pulse_count[{2'd1, i_slot}];
	assign o_pulse_count_2 = pulse_count[{2'd2, i_slot}];
	assign o_pulse_count_3 = pulse_count[{2'd3, i_slot}];
	
	assign o_pulse_hush_0 = pulse_hush[{2'd0, i_slot}];
	assign o_pulse_hush_1 = pulse_hush[{2'd0, i_slot}];
	assign o_pulse_hush_2 = pulse_hush[{2'd0, i_slot}];
	assign o_pulse_hush_3 = pulse_hush[{2'd0, i_slot}];
	
	assign o_adc_vchn_0 = adc_vchn[{2'd0, i_slot}];
	assign o_adc_vchn_1 = adc_vchn[{2'd1, i_slot}];
	assign o_adc_vchn_2 = adc_vchn[{2'd2, i_slot}];
	assign o_adc_vchn_3 = adc_vchn[{2'd3, i_slot}];
	
	assign o_adc_tick_0 = adc_tick[{2'd0, i_slot}];
	assign o_adc_tick_1 = adc_tick[{2'd1, i_slot}];
	assign o_adc_tick_2 = adc_tick[{2'd2, i_slot}];
	assign o_adc_tick_3 = adc_tick[{2'd3, i_slot}];
	
	assign o_adc_ratio_0 = adc_ratio[{2'd0, i_slot}];
	assign o_adc_ratio_1 = adc_ratio[{2'd1, i_slot}];
	assign o_adc_ratio_2 = adc_ratio[{2'd2, i_slot}];
	assign o_adc_ratio_3 = adc_ratio[{2'd3, i_slot}];
	
endmodule
