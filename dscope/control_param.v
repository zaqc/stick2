`timescale 1ns/1ps

module control_param(
	input						rst_n,

	input		[31:0]			i_cmd_magic,	// 0xAAFAAF55
	input		[31:0]			i_cmd_command,
	input						i_cmd_vld,

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
	output		[7:0]			o_dac_level_3
);

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
							NCMD_SLOT_TIME = 4'd10;

	
	always @ (negedge rst_n)
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
			end
			`else
			for(i = 5'd0; i < 5'd16; i = i + 1'd1) begin
				pulse_mask[i] <= 4'd1 << i[1:0];
				pulse_hit[i] <= i == 5'd15 ? 8'd20 : 8'd40;
				pulse_gnd[i] <= i == 5'd15 ? 8'd60 : 8'd40;
				pulse_count[i] <= i == 5'd15 ? 4'd1 : 4'd4;
				pulse_hush[i] <= 16'd1000;	// 5 uSec (200 ticks == 1 uSec)
				
				adc_vchn[i] <= i[1:0];
				adc_tick[i] <= 8'd64;	// 256
				adc_ratio[i] <= 8'd14;	// 256 * 14 = 179.2 uSec
				
				dac_level[i] <= 8'd120;
			end
			`endif
		end
		else
			if(i_cmd_vld && i_cmd_magic == 32'hF0AA550F) begin
				if(global_cmd) begin
				end
				else begin
					case(ncmd)
						NCMD_PULSE_MASK: pulse_mask[{cmd_ch, cmd_slot}] = i_cmd_command[3:0];
						NCMD_RX_INDEX: adc_vchn[{cmd_ch, cmd_slot}] = i_cmd_command[1:0];
						NCMD_HIT_LEN: pulse_hit[{cmd_ch, cmd_slot}] = i_cmd_command[3:0];
						NCMD_GND_LEN: pulse_gnd[{cmd_ch, cmd_slot}] = i_cmd_command[3:0];
						NCMD_HUSH_LEN: pulse_hush[{cmd_ch, cmd_slot}] = i_cmd_command[15:0];
						NCMD_PULSE_COUNT: pulse_count[{cmd_ch, cmd_slot}] = i_cmd_command[3:0];
						NCMD_DAC_LEVEL: dac_level[{cmd_ch, cmd_slot}] = i_cmd_command[7:0];
						NCMD_ADC_RATIO: adc_ratio[{cmd_ch, cmd_slot}] = i_cmd_command[7:0];
						NCMD_ADC_TICK: adc_tick[{cmd_ch, cmd_slot}] = i_cmd_command[7:0];
						NCMD_SLOT_TIME: ts_time[cmd_slot] = i_cmd_command[15:0];
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
	
	assign o_pulse_mask_0 = pulse_mask[slot_0];
	assign o_pulse_mask_1 = pulse_mask[slot_1];
	assign o_pulse_mask_2 = pulse_mask[slot_2];
	assign o_pulse_mask_3 = pulse_mask[slot_3];
		
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
	
endmodule
