`timescale 1ns/1ps

module dscope_main(
	input						rst_n,
	input						hi_clk,	
	input						sys_clk,	
	input						adc_clk,
	
	input						i_sync,
	
	input						i_ch_a,
	input						i_ch_b,

	output		[3:0]			o_phase_ax,
	output		[3:0]			o_phase_bx,
	output		[3:0]			o_phase_cx,
	output		[3:0]			o_phase_dx,
	
	output		[3:0]			o_nenz_0x,
	output		[3:0]			o_nenz_1x,
	output		[3:0]			o_nenz_2x,
	output		[3:0]			o_nenz_3x,
	
	output		[3:0]			o_en_0x,
	output		[3:0]			o_en_1x,
	output		[3:0]			o_en_2x,
	output		[3:0]			o_en_3x,
	
//	output		[3:0]			o_doffs_x,
//	output		[3:0]			o_soffs_nx,
//	output		[3:0]			o_mclk_x,
	
	input		[11:0]			i_d_0x,
	input		[11:0]			i_d_1x,
	input		[11:0]			i_d_2x,
	input		[11:0]			i_d_3x,
	
	output						o_dac_data_0,
	output						o_dac_data_1,
	output						o_dac_data_2,
	output						o_dac_data_3,

	output						o_dac_cs_n,
	
	output		[31:0]			o_out_data,
	output						o_out_vld,
	input						i_out_rdy,
	
	output						o_frame_ready,
	output		[15:0]			o_frame_size,
	
	input		[31:0]			i_cmd_magic,	// 0xF0AA550F
	input		[31:0]			i_cmd_command,
	input						i_cmd_vld,
	output						o_cmd_rdy,
	
	output		[3:0]			o_led_cntr
);

	wire						adc_sync;
	wire						sys_sync;
	wire						hi_sync;
	
	wire						sync;
	
	clock_sync clock_sync_unit(
		.rst_n(rst_n),
		.hi_clk(hi_clk),		
		.sys_clk(sys_clk),
		.adc_clk(adc_clk),
		
		.i_sync(sync),
		
		.o_hi_sync(hi_sync),
		.o_sys_sync(sys_sync),
		.o_adc_sync(adc_sync)
	);
	
	wire		[1:0]			slot;
	
	wire		[15:0]			ts_time_0;
	wire		[15:0]			ts_time_1;
	wire		[15:0]			ts_time_2;
	wire		[15:0]			ts_time_3;
	
	wire		[7:0]			pulse_hit_0;
	wire		[7:0]			pulse_hit_1;
	wire		[7:0]			pulse_hit_2;
	wire		[7:0]			pulse_hit_3;
	
	wire		[7:0]			pulse_gnd_0;
	wire		[7:0]			pulse_gnd_1;
	wire		[7:0]			pulse_gnd_2;
	wire		[7:0]			pulse_gnd_3;
	
	wire		[15:0]			pulse_hush_0;
	wire		[15:0]			pulse_hush_1;
	wire		[15:0]			pulse_hush_2;
	wire		[15:0]			pulse_hush_3;
	
	wire		[3:0]			pulse_count_0;
	wire		[3:0]			pulse_count_1;
	wire		[3:0]			pulse_count_2;
	wire		[3:0]			pulse_count_3;
	
	wire		[1:0]			adc_vchn_0;
	wire		[1:0]			adc_vchn_1;
	wire		[1:0]			adc_vchn_2;
	wire		[1:0]			adc_vchn_3;
	
	wire		[7:0]			adc_tick_0;
	wire		[7:0]			adc_tick_1;
	wire		[7:0]			adc_tick_2;
	wire		[7:0]			adc_tick_3;
	
	wire		[7:0]			adc_ratio_0;
	wire		[7:0]			adc_ratio_1;
	wire		[7:0]			adc_ratio_2;
	wire		[7:0]			adc_ratio_3;
	
	wire		[3:0]			pulse_mask_0;
	wire		[3:0]			pulse_mask_1;
	wire		[3:0]			pulse_mask_2;
	wire		[3:0]			pulse_mask_3;
	
	wire		[7:0]			dac_level_0;
	wire		[7:0]			dac_level_1;
	wire		[7:0]			dac_level_2;
	wire		[7:0]			dac_level_3;
	
	wire						sync_enabled;
	wire						int_ext_sync;
	wire		[15:0]			in_sync_div;
	wire		[7:0]			wheel_add;
	wire		[7:0]			frame_dec;
	
	control_param control_param_unit(
		.rst_n(rst_n),
		
		.clk(sys_clk),
		
		.i_cmd_magic(i_cmd_magic),
		.i_cmd_command(i_cmd_command),
		.i_cmd_vld(i_cmd_vld),
		.o_cmd_rdy(o_cmd_rdy),
		
		.i_slot(slot),
		
		.o_ts_time_0(ts_time_0),
		.o_ts_time_1(ts_time_1),
		.o_ts_time_2(ts_time_2),
		.o_ts_time_3(ts_time_3),
		
		.o_pulse_mask_0(pulse_mask_0),
		.o_pulse_mask_1(pulse_mask_1),
		.o_pulse_mask_2(pulse_mask_2),
		.o_pulse_mask_3(pulse_mask_3),
		
		.o_pulse_hit_0(pulse_hit_0),
		.o_pulse_hit_1(pulse_hit_1),
		.o_pulse_hit_2(pulse_hit_2),
		.o_pulse_hit_3(pulse_hit_3),

		.o_pulse_gnd_0(pulse_gnd_0),
		.o_pulse_gnd_1(pulse_gnd_1),
		.o_pulse_gnd_2(pulse_gnd_2),
		.o_pulse_gnd_3(pulse_gnd_3),

		.o_pulse_hush_0(pulse_hush_0),
		.o_pulse_hush_1(pulse_hush_1),
		.o_pulse_hush_2(pulse_hush_2),
		.o_pulse_hush_3(pulse_hush_3),

		.o_pulse_count_0(pulse_count_0),
		.o_pulse_count_1(pulse_count_1),
		.o_pulse_count_2(pulse_count_2),
		.o_pulse_count_3(pulse_count_3),
		
		.o_adc_vchn_0(adc_vchn_0),
		.o_adc_vchn_1(adc_vchn_1),
		.o_adc_vchn_2(adc_vchn_2),
		.o_adc_vchn_3(adc_vchn_3),

		.o_adc_tick_0(adc_tick_0),
		.o_adc_tick_1(adc_tick_1),
		.o_adc_tick_2(adc_tick_2),
		.o_adc_tick_3(adc_tick_3),

		.o_adc_ratio_0(adc_ratio_0),
		.o_adc_ratio_1(adc_ratio_1),
		.o_adc_ratio_2(adc_ratio_2),
		.o_adc_ratio_3(adc_ratio_3),
		
		.o_dac_level_0(dac_level_0),
		.o_dac_level_1(dac_level_1),
		.o_dac_level_2(dac_level_2),
		.o_dac_level_3(dac_level_3),
		
		.o_sync_enabled(sync_enabled),
		.o_int_ext_sync(int_ext_sync),
		.o_in_sync_div(in_sync_div),
		.o_wheel_add(wheel_add),
		.o_frame_dec(frame_dec)
	);
	
	assign o_en_0x = 1'b1 << adc_vchn_0;
	assign o_en_1x = 1'b1 << adc_vchn_1;
	assign o_en_2x = 1'b1 << adc_vchn_2;
	assign o_en_3x = 1'b1 << adc_vchn_3;
	
	assign o_nenz_0x = ~pulse_mask_0;
	assign o_nenz_1x = ~pulse_mask_1;
	assign o_nenz_2x = ~pulse_mask_2;
	assign o_nenz_3x = ~pulse_mask_3;
	
	wire						slot_changed;
	wire						complite;
	time_slot time_slot_unit(
		.rst_n(rst_n),
		.clk(adc_clk),
		
		.i_sync(adc_sync),
		
		.i_ts0(ts_time_0),
		.i_ts1(ts_time_1),
		.i_ts2(ts_time_2),
		.i_ts3(ts_time_3),
		
		.o_slot(slot),
		.o_slot_sync(slot_changed),
		
		.o_complite(complite)
	);
	
	wire						slot_sync;
	dac_level dac_level_unit(
		.rst_n(rst_n),
		.clk(adc_clk),
		
		.i_sync(slot_changed),
		
		.i_dac_data_0(dac_level_0),
		.i_dac_data_1(dac_level_1),
		.i_dac_data_2(dac_level_2),
		.i_dac_data_3(dac_level_3),
		
		.o_sync_delayed(slot_sync),
		
		.o_dac_data_0(o_dac_data_0),
		.o_dac_data_1(o_dac_data_1),
		.o_dac_data_2(o_dac_data_2),
		.o_dac_data_3(o_dac_data_3),
		
		.o_dac_cs_n(o_dac_cs_n)
	);
			
	pulse_channel pulse_channel_u0(
		.rst_n(rst_n),
		.hi_clk(hi_clk),
		
		.i_sync(slot_sync),
		
		.i_hit_len(pulse_hit_0),
		.i_gnd_len(pulse_gnd_0),
		.i_hush_len(pulse_hush_0),
		.i_pulse_count(pulse_count_0),
		
		.o_znd_hi(o_phase_ax[0]),
		.o_znd_lo_n(o_phase_bx[0]),
		.o_znd_gnd(o_phase_cx[0]),
		.o_znd_gnd_n(o_phase_dx[0])
	);
	
	pulse_channel pulse_channel_u1(
		.rst_n(rst_n),
		.hi_clk(hi_clk),
		
		.i_sync(slot_sync),
		
		.i_hit_len(pulse_hit_1),
		.i_gnd_len(pulse_gnd_1),
		.i_hush_len(pulse_hush_1),
		.i_pulse_count(pulse_count_1),
		
		.o_znd_hi(o_phase_ax[1]),
		.o_znd_lo_n(o_phase_bx[1]),
		.o_znd_gnd(o_phase_cx[1]),
		.o_znd_gnd_n(o_phase_dx[1])
	);

	pulse_channel pulse_channel_u2(
		.rst_n(rst_n),
		.hi_clk(hi_clk),
		
		.i_sync(slot_sync),
		
		.i_hit_len(pulse_hit_2),
		.i_gnd_len(pulse_gnd_2),
		.i_hush_len(pulse_hush_2),
		.i_pulse_count(pulse_count_2),
		
		.o_znd_hi(o_phase_ax[2]),
		.o_znd_lo_n(o_phase_bx[2]),
		.o_znd_gnd(o_phase_cx[2]),
		.o_znd_gnd_n(o_phase_dx[2])
	);

	pulse_channel pulse_channel_u3(
		.rst_n(rst_n),
		.hi_clk(hi_clk),
		
		.i_sync(slot_sync),
		
		.i_hit_len(pulse_hit_3),
		.i_gnd_len(pulse_gnd_3),
		.i_hush_len(pulse_hush_3),
		.i_pulse_count(pulse_count_3),
		
		.o_znd_hi(o_phase_ax[3]),
		.o_znd_lo_n(o_phase_bx[3]),
		.o_znd_gnd(o_phase_cx[3]),
		.o_znd_gnd_n(o_phase_dx[3])
	);

	wire		[1:0]			rd_vchn;
	
	`ifdef TESTMODE 
	reg			[11:0]			adc_cntr;
	always @ (posedge adc_clk or negedge rst_n)
		if(~rst_n)
			adc_cntr <= 12'd0;
		else
			adc_cntr <= adc_cntr + 1'd1;
	`endif

	
	wire		[7:0]			data_count_0;
	wire		[7:0]			rd_addr_0;
	wire		[31:0]			rd_data_0;
	wire		[15:0]			out_size_0;
	phy_channel phy_channel_u0(
		.rst_n(rst_n),
		.clk(adc_clk),
		
		.sys_clk(sys_clk),
		
		.i_sync(adc_sync),
		.i_slot_sync(slot_sync),
		
		.i_complite(complite),
		
		.i_wr_vchn(adc_vchn_0),
		
		.i_ratio(adc_ratio_0),
		.i_data_len(adc_tick_0),
		
		`ifdef TESTMODE 
		.i_adc_data(adc_cntr[11:4]),
		`else
		.i_adc_data(i_d_0x[11:4]),
		`endif
		
		.i_rd_vchn(rd_vchn),
		.o_data_count(data_count_0),
		
		.i_rd_addr(rd_addr_0),
		.o_rd_data(rd_data_0),
		
		.o_out_size(out_size_0)
	);
	
	wire		[7:0]			data_count_1;
	wire		[7:0]			rd_addr_1;
	wire		[31:0]			rd_data_1;
	wire		[15:0]			out_size_1;
	phy_channel phy_channel_u1(
		.rst_n(rst_n),
		.clk(adc_clk),
		
		.sys_clk(sys_clk),
		
		.i_sync(adc_sync),
		.i_slot_sync(slot_sync),
		
		.i_complite(complite),
		
		.i_wr_vchn(adc_vchn_1),
		
		.i_ratio(adc_ratio_1),
		.i_data_len(adc_tick_1),
		
		`ifdef TESTMODE 
		.i_adc_data(adc_cntr[11:4]),
		`else
		.i_adc_data(i_d_1x[11:4]),
		`endif
		
		.i_rd_vchn(rd_vchn),
		.o_data_count(data_count_1),
		
		.i_rd_addr(rd_addr_1),
		.o_rd_data(rd_data_1),
		
		.o_out_size(out_size_1)
	);
	
	wire		[7:0]			data_count_2;
	wire		[7:0]			rd_addr_2;
	wire		[31:0]			rd_data_2;
	wire		[15:0]			out_size_2;
	phy_channel phy_channel_u2(
		.rst_n(rst_n),
		.clk(adc_clk),
		
		.sys_clk(sys_clk),
		
		.i_sync(adc_sync),
		.i_slot_sync(slot_sync),
		
		.i_complite(complite),
		
		.i_wr_vchn(adc_vchn_2),
		
		.i_ratio(adc_ratio_2),
		.i_data_len(adc_tick_2),
		
		`ifdef TESTMODE 
		.i_adc_data(adc_cntr[11:4]),
		`else
		.i_adc_data(i_d_2x[11:4]),
		`endif
		
		.i_rd_vchn(rd_vchn),
		.o_data_count(data_count_2),
		
		.i_rd_addr(rd_addr_2),
		.o_rd_data(rd_data_2),
		
		.o_out_size(out_size_2)
	);
	
	wire		[7:0]			data_count_3;
	wire		[7:0]			rd_addr_3;
	wire		[31:0]			rd_data_3;
	wire		[15:0]			out_size_3;
	phy_channel phy_channel_u3(
		.rst_n(rst_n),
		.clk(adc_clk),
		
		.sys_clk(sys_clk),
		
		.i_sync(adc_sync),
		.i_slot_sync(slot_sync),
		
		.i_complite(complite),
		
		.i_wr_vchn(adc_vchn_3),
		
		.i_ratio(adc_ratio_3),
		.i_data_len(adc_tick_3),
		
		`ifdef TESTMODE 
		.i_adc_data(adc_cntr[11:4]),
		`else
		.i_adc_data(i_d_3x[11:4]),
		`endif
		
		.i_rd_vchn(rd_vchn),
		.o_data_count(data_count_3),
		
		.i_rd_addr(rd_addr_3),
		.o_rd_data(rd_data_3),
		
		.o_out_size(out_size_3)
	);

	//------------------------------------------------------------------------

	reg			[0:0]			frame_ready;
	always @ (posedge sys_clk or negedge rst_n)
		if(~rst_n) 
			frame_ready <= 1'b0;
		else
			if(sys_sync)
				frame_ready <= 1'b0;
			else
				if(complite)
					frame_ready <= 1'b1;

	wire		[15:0]			header_size;

	assign o_frame_ready = frame_ready;
	assign o_frame_size = header_size + out_size_0 + out_size_1 + out_size_2 + out_size_3;
	
	wire		[31:0]			frame_data;
	wire						frame_vld;
	wire						frame_rdy;
	
	data_reader data_reader_unit(
		.rst_n(rst_n),
		.clk(sys_clk),
		
		.i_complite(complite),
		
		.o_rd_vchn(rd_vchn),
		
		.i_data_len_0(data_count_0),
		.i_rd_data_0(rd_data_0),
		.o_rd_addr_0(rd_addr_0),
		
		.i_data_len_1(data_count_1),
		.i_rd_data_1(rd_data_1),
		.o_rd_addr_1(rd_addr_1),
		
		.i_data_len_2(data_count_2),
		.i_rd_data_2(rd_data_2),
		.o_rd_addr_2(rd_addr_2),
		
		.i_data_len_3(data_count_3),		
		.i_rd_data_3(rd_data_3),
		.o_rd_addr_3(rd_addr_3),
		
		.o_out_data(frame_data),
		.o_out_vld(frame_vld),
		.i_out_rdy(frame_rdy)
	);
	
	wire		[31:0]			sync_counter;
	wire		[31:0]			way_meter;
	wire		[31:0]			system_timer;
	
	synchronizer sychronizer_unit(
		.rst_n(rst_n),
		.clk(sys_clk),
		
		.i_ch_a(i_ch_a),
		.i_ch_b(i_ch_b),
		
		.i_sync_enabled(sync_enabled),
		.i_int_ext_sync(int_ext_sync),
		.i_wheel_add(wheel_add),
		.i_frame_dec(frame_dec),
		.i_in_sync_div(in_sync_div),
		
		.o_sync_counter(sync_counter),
		.o_way_meter(way_meter),
		.o_system_timer(system_timer),
		
		.o_sync(sync)
	);
	
	assign o_led_cntr = way_meter[3:0];
	
	frame_header frame_header_unit(
		.rst_n(rst_n),
		.clk(sys_clk),
		
		.i_sync(complite),
		
		.o_header_size(header_size),
		
		.i_sync_counter(sync_counter),
		.i_way_meter(way_meter),
		.i_system_timer(system_timer),
		
		.i_frame_data(frame_data),
		.i_frame_vld(frame_vld),
		.o_frame_rdy(frame_rdy),
		
		
		.o_out_data(o_out_data),
		.o_out_vld(o_out_vld),
		.i_out_rdy(i_out_rdy)
	);
	

endmodule
