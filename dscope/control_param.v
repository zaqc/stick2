`timescale 1ns/1ps

module control_param(
	input						rst_n,
	
	input						clk,

	input		[31:0]			i_cmd_magic,	// 0xAAFAAF55
	input		[31:0]			i_cmd_command,
	input						i_cmd_vld,
	output						o_cmd_rdy,

	input		[1:0]			i_slot,			// slot number
	
	output		[15:0]			o_ts_time_0,	// time slot periods
	output		[15:0]			o_ts_time_1,
	output		[15:0]			o_ts_time_2,
	output		[15:0]			o_ts_time_3,
	
	output		[3:0]			o_pulse_mask_0,
	output		[3:0]			o_pulse_mask_1,
	output		[3:0]			o_pulse_mask_2,
	output		[3:0]			o_pulse_mask_3,
	
	output		[7:0]			o_pulse_hit_0,
	output		[7:0]			o_pulse_hit_1,
	output		[7:0]			o_pulse_hit_2,
	output		[7:0]			o_pulse_hit_3,
	
	output		[7:0]			o_pulse_gnd_0,
	output		[7:0]			o_pulse_gnd_1,
	output		[7:0]			o_pulse_gnd_2,
	output		[7:0]			o_pulse_gnd_3,
	
	output		[3:0]			o_pulse_count_0,
	output		[3:0]			o_pulse_count_1,
	output		[3:0]			o_pulse_count_2,
	output		[3:0]			o_pulse_count_3,

	output		[15:0]			o_pulse_hush_0,
	output		[15:0]			o_pulse_hush_1,
	output		[15:0]			o_pulse_hush_2,
	output		[15:0]			o_pulse_hush_3,
	
	output		[1:0]			o_adc_vchn_0,
	output		[1:0]			o_adc_vchn_1,
	output		[1:0]			o_adc_vchn_2,
	output		[1:0]			o_adc_vchn_3,
	
	output		[7:0]			o_adc_tick_0,
	output		[7:0]			o_adc_tick_1,
	output		[7:0]			o_adc_tick_2,
	output		[7:0]			o_adc_tick_3,
	
	output		[7:0]			o_adc_ratio_0,
	output		[7:0]			o_adc_ratio_1,
	output		[7:0]			o_adc_ratio_2,
	output		[7:0]			o_adc_ratio_3,
	
	output		[7:0]			o_dac_level_0,
	output		[7:0]			o_dac_level_1,
	output		[7:0]			o_dac_level_2,
	output		[7:0]			o_dac_level_3,
	
	output		[7:0]			o_adc_delay_0,
	output		[7:0]			o_adc_delay_1,
	output		[7:0]			o_adc_delay_2,
	output		[7:0]			o_adc_delay_3,
	
	output		[15:0]			o_in_sync_div,
	output						o_sync_enabled,
	output						o_int_ext_sync,
	output		[7:0]			o_wheel_add,
	output		[7:0]			o_frame_dec,
	
	output		[2:0]			o_high_voltage
);

	assign o_cmd_rdy = 1'b1;
	
	reg			[15:0]		ts_time[0:3];

	reg			[3:0]		pulse_mask[0:15];
	
	reg			[7:0]		pulse_hit[0:15];
	reg			[7:0]		pulse_gnd[0:15];
	reg			[3:0]		pulse_count[0:15];
	reg			[15:0]		pulse_hush[0:15];	// blunch time (327 uSec max)
	
	reg			[1:0]		adc_vchn[0:15];
	reg			[7:0]		adc_tick[0:15];
	reg			[7:0]		adc_ratio[0:15];
	
	reg			[7:0]		dac_level[0:15];
	
	reg			[7:0]		adc_delay[0:15];
	
	reg			[15:0]		in_sync_div;
	reg			[0:0]		sync_enabled;
	reg			[0:0]		int_ext_sync;
	reg			[7:0]		wheel_add;
	reg			[7:0]		frame_dec;
	
	reg			[2:0]		high_voltage;

	reg		 	[5:0]		i;
	
	wire					global_cmd;
	wire		[1:0]		cmd_ch;
	wire		[1:0]		cmd_slot;
	wire		[3:0]		ncmd;

	assign global_cmd = i_cmd_command[31];
	assign cmd_ch = i_cmd_command[30:29];
	assign cmd_slot = i_cmd_command[28:27];
	assign ncmd = i_cmd_command[26:23];
	
	parameter	[3:0]		NCMD_PULSE_MASK = 4'd1,
							NCMD_RX_INDEX = 4'd2,
							NCMD_HIT_LEN = 4'd3,
							NCMD_GND_LEN = 4'd4,
							NCMD_HUSH_LEN = 4'd5,
							NCMD_PULSE_COUNT = 4'd6,
							NCMD_DAC_LEVEL = 4'd7,
							NCMD_ADC_RATIO = 4'd8,
							NCMD_ADC_TICK = 4'd9,
							NCMD_SLOT_TIME = 4'd10,
							NCMD_ADC_DELAY = 4'd11,
							NCMD_HIGH_VOLTAGE = 4'd12;

//	probe32 probe_u0(
//		.probe(i_cmd_magic)
//	);
//	
//	probe32 probe_u1(
//		.probe(i_cmd_command)
//	);
	
	always @ (posedge clk or negedge rst_n)
		if(~rst_n) begin
			`ifdef TESTMODE
			ts_time[2'd0] <= 16'd1200;
			ts_time[2'd1] <= 16'd1200;
			ts_time[2'd2] <= 16'd1200;
			ts_time[2'd3] <= 16'd800;
			`else
			ts_time[2'd0] <= 16'd3600;	// 180 us
			ts_time[2'd1] <= 16'd3600;
			ts_time[2'd2] <= 16'd3600;
			ts_time[2'd3] <= 16'd3600;	// 100 us for PC Channel
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
				
				dac_level[i] <= {i, 3'd0};
				
				adc_delay[i] <= i & 1'b1 ? 8'd10 : 8'd0;
			end
			`else
			for(i = 5'd0; i < 5'd16; i = i + 1'd1) begin
				pulse_mask[i] <= 4'd1 << i[1:0];
				pulse_hit[i] <= i == 5'd15 ? 8'd10 : 8'd20;
				pulse_gnd[i] <= i == 5'd15 ? 8'd30 : 8'd20;
				pulse_count[i] <= i == 5'd15 ? 4'd1 : 4'd4;
				pulse_hush[i] <= 16'd1000;	// 5 uSec (200 ticks == 1 uSec)
				
				adc_vchn[i] <= i[1:0];
				adc_tick[i] <= 8'd64;	// 256
				adc_ratio[i] <= 8'd12;	// 256 * 12 = 153.6 uSec
				
				dac_level[i] <= 8'd120;
				
				adc_delay[i] <= 8'd0;
			end
			
			wheel_add <= 8'd9;
			frame_dec <= 8'd234;
			in_sync_div <= 16'd100;
			sync_enabled <= 1'b1;	// sync enabled
			int_ext_sync <= 1'b1;	// external sync			
			`endif
			
			high_voltage <= 3'b000;
		end
		else
			if(i_cmd_vld && i_cmd_magic == 32'hF0AA550F) begin
				if(global_cmd) begin
					sync_enabled <= i_cmd_command[30];
					int_ext_sync <= i_cmd_command[29];
					in_sync_div <= {3'd0, i_cmd_command[28:16]};
					wheel_add <= i_cmd_command[15:8];
					frame_dec <= i_cmd_command[7:0];
				end
				else begin
					case(ncmd)
						NCMD_PULSE_MASK: pulse_mask[{cmd_ch, cmd_slot}] = i_cmd_command[3:0];
						NCMD_RX_INDEX: adc_vchn[{cmd_ch, cmd_slot}] = i_cmd_command[1:0];
						NCMD_HIT_LEN: pulse_hit[{cmd_ch, cmd_slot}] = i_cmd_command[7:0];
						NCMD_GND_LEN: pulse_gnd[{cmd_ch, cmd_slot}] = i_cmd_command[7:0];
						NCMD_HUSH_LEN: pulse_hush[{cmd_ch, cmd_slot}] = i_cmd_command[15:0];
						NCMD_PULSE_COUNT: pulse_count[{cmd_ch, cmd_slot}] = i_cmd_command[3:0];
						NCMD_DAC_LEVEL: dac_level[{cmd_ch, cmd_slot}] = i_cmd_command[7:0];
						NCMD_ADC_RATIO: adc_ratio[{cmd_ch, cmd_slot}] = i_cmd_command[7:0];
						NCMD_ADC_TICK: adc_tick[{cmd_ch, cmd_slot}] = i_cmd_command[7:0];
						NCMD_SLOT_TIME: ts_time[cmd_slot] = i_cmd_command[15:0];
						NCMD_ADC_DELAY: adc_delay[{cmd_ch, cmd_slot}] = i_cmd_command[7:0];
						NCMD_HIGH_VOLTAGE: high_voltage = i_cmd_command[2:0];
					endcase
				end
			end
		
	assign o_ts_time_0 = ts_time[2'd0];
	assign o_ts_time_1 = ts_time[2'd1];
	assign o_ts_time_2 = ts_time[2'd2];
	assign o_ts_time_3 = ts_time[2'd3];
	
	wire		[3:0]			slot_0;
	assign slot_0 = {2'd0, i_slot};
	wire		[3:0]			slot_1;
	assign slot_1 = {2'd1, i_slot};
	wire		[3:0]			slot_2;
	assign slot_2 = {2'd2, i_slot};
	wire		[3:0]			slot_3;
	assign slot_3 = {2'd3, i_slot};
	
	function [3:0] reverse_bit(input [3:0] bit);
		reverse_bit = {bit[0], bit[1], bit[2], bit[3]};
	endfunction
	
	assign o_pulse_mask_0 = reverse_bit(pulse_mask[slot_0]);
	assign o_pulse_mask_1 = reverse_bit(pulse_mask[slot_1]);
	assign o_pulse_mask_2 = reverse_bit(pulse_mask[slot_2]);
	assign o_pulse_mask_3 = reverse_bit(pulse_mask[slot_3]);
		
	assign o_pulse_hit_0 = pulse_hit[slot_0];
	assign o_pulse_hit_1 = pulse_hit[slot_1];
	assign o_pulse_hit_2 = pulse_hit[slot_2];
	assign o_pulse_hit_3 = pulse_hit[slot_3];
	
	assign o_pulse_gnd_0 = pulse_gnd[slot_0];
	assign o_pulse_gnd_1 = pulse_gnd[slot_1];
	assign o_pulse_gnd_2 = pulse_gnd[slot_2];
	assign o_pulse_gnd_3 = pulse_gnd[slot_3];
	
	assign o_pulse_count_0 = pulse_count[slot_0];
	assign o_pulse_count_1 = pulse_count[slot_1];
	assign o_pulse_count_2 = pulse_count[slot_2];
	assign o_pulse_count_3 = pulse_count[slot_3];
	
	assign o_pulse_hush_0 = pulse_hush[slot_0];
	assign o_pulse_hush_1 = pulse_hush[slot_1];
	assign o_pulse_hush_2 = pulse_hush[slot_2];
	assign o_pulse_hush_3 = pulse_hush[slot_3];
	
	assign o_adc_vchn_0 = adc_vchn[slot_0];
	assign o_adc_vchn_1 = adc_vchn[slot_1];
	assign o_adc_vchn_2 = adc_vchn[slot_2];
	assign o_adc_vchn_3 = adc_vchn[slot_3];
	
	assign o_adc_tick_0 = adc_tick[slot_0];
	assign o_adc_tick_1 = adc_tick[slot_1];
	assign o_adc_tick_2 = adc_tick[slot_2];
	assign o_adc_tick_3 = adc_tick[slot_3];
	
	assign o_adc_ratio_0 = adc_ratio[slot_0];
	assign o_adc_ratio_1 = adc_ratio[slot_1];
	assign o_adc_ratio_2 = adc_ratio[slot_2];
	assign o_adc_ratio_3 = adc_ratio[slot_3];
	
	assign o_dac_level_0 = dac_level[slot_0];
	assign o_dac_level_1 = dac_level[slot_1];
	assign o_dac_level_2 = dac_level[slot_2];
	assign o_dac_level_3 = dac_level[slot_3];
	
	assign o_adc_delay_0 = adc_delay[slot_0];
	assign o_adc_delay_1 = adc_delay[slot_1];
	assign o_adc_delay_2 = adc_delay[slot_2];
	assign o_adc_delay_3 = adc_delay[slot_3];
	
	assign o_in_sync_div = in_sync_div;
	assign o_wheel_add = wheel_add;
	assign o_frame_dec = frame_dec;
	assign o_sync_enabled = sync_enabled;
	assign o_int_ext_sync = int_ext_sync;
	
endmodule
