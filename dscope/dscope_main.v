`timescale 1ns/1ps

module dscope_main(
	input						rst_n,
	input						hi_clk,
	
	input						sys_clk,
	
	output						o_adc_clk,
	
	input						i_sync,

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
	
	output		[3:0]			o_doffs_x,
	output		[3:0]			o_soffs_nx,
	output		[3:0]			o_mclk_x,
	
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
	
	input		[31:0]			i_command,
	input						i_cmd_vld
);

	wire						adc_clk;
	wire						main_sync;
	clock_sync clock_sync_unit(
		.rst_n(rst_n),
		.hi_clk(hi_clk),
		
		.sys_clk(sys_clk),
		.i_sync(i_sync),
		
		.o_main_sync(main_sync),
		
		.o_adc_clk(adc_clk)
	);
	
	assign o_adc_clk = adc_clk;

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
	
	control_param control_param_unit(
		.rst_n(rst_n),
		
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
		.o_dac_level_3(dac_level_3)
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
		
		.i_sync(main_sync),
		
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
	reg			[7:0]			adc_cntr;
	always @ (posedge adc_clk or negedge rst_n)
		if(~rst_n)
			adc_cntr <= 8'd0;
		else
			adc_cntr <= adc_cntr + 1'd1;
	`endif

	
	wire		[7:0]			data_count_0;
	wire		[7:0]			rd_addr_0;
	wire		[31:0]			rd_data_0;
	wire		[15:0]			out_size_0;
	wire						frame_ready_0;
	phy_channel phy_channel_u0(
		.rst_n(rst_n),
		.clk(adc_clk),
		
		.sys_clk(sys_clk),
		
		.i_sync(main_sync),
		.i_slot_sync(slot_sync),
		
		.i_complite(complite),
		
		.i_wr_vchn(adc_vchn_0),
		
		.i_ratio(adc_ratio_0),
		.i_data_len(adc_tick_0),
		
		`ifdef TESTMODE 
		.i_adc_data(adc_cntr),
		`else
		.i_adc_data(i_d_0x[11:2]),
		`endif
		
		.i_rd_vchn(rd_vchn),
		.o_data_count(data_count_0),
		
		.i_rd_addr(rd_addr_0),
		.o_rd_data(rd_data_0),
		
		.o_out_size(out_size_0),
		.o_frame_ready(frame_ready_0)
	);
	
	wire		[7:0]			data_count_1;
	wire		[7:0]			rd_addr_1;
	wire		[31:0]			rd_data_1;
	wire		[15:0]			out_size_1;
	wire						frame_ready_1;
	phy_channel phy_channel_u1(
		.rst_n(rst_n),
		.clk(adc_clk),
		
		.sys_clk(sys_clk),
		
		.i_sync(main_sync),
		.i_slot_sync(slot_sync),
		
		.i_complite(complite),
		
		.i_wr_vchn(adc_vchn_1),
		
		.i_ratio(adc_ratio_1),
		.i_data_len(adc_tick_1),
		
		`ifdef TESTMODE 
		.i_adc_data(adc_cntr),
		`else
		.i_adc_data(i_d_0x[11:4]),
		`endif
		
		.i_rd_vchn(rd_vchn),
		.o_data_count(data_count_1),
		
		.i_rd_addr(rd_addr_1),
		.o_rd_data(rd_data_1),
		
		.o_out_size(out_size_1),
		.o_frame_ready(frame_ready_1)
	);
	
	wire		[7:0]			data_count_2;
	wire		[7:0]			rd_addr_2;
	wire		[31:0]			rd_data_2;
	wire		[15:0]			out_size_2;
	wire						frame_ready_2;
	phy_channel phy_channel_u2(
		.rst_n(rst_n),
		.clk(adc_clk),
		
		.sys_clk(sys_clk),
		
		.i_sync(main_sync),
		.i_slot_sync(slot_sync),
		
		.i_complite(complite),
		
		.i_wr_vchn(adc_vchn_2),
		
		.i_ratio(adc_ratio_2),
		.i_data_len(adc_tick_2),
		
		`ifdef TESTMODE 
		.i_adc_data(adc_cntr),
		`else
		.i_adc_data(i_d_0x[7:0]),
		`endif
		
		.i_rd_vchn(rd_vchn),
		.o_data_count(data_count_2),
		
		.i_rd_addr(rd_addr_2),
		.o_rd_data(rd_data_2),
		
		.o_out_size(out_size_2),
		.o_frame_ready(frame_ready_2)
	);
	
	wire		[7:0]			data_count_3;
	wire		[7:0]			rd_addr_3;
	wire		[31:0]			rd_data_3;
	wire		[15:0]			out_size_3;
	wire						frame_ready_3;
	phy_channel phy_channel_u3(
		.rst_n(rst_n),
		.clk(adc_clk),
		
		.sys_clk(sys_clk),
		
		.i_sync(main_sync),
		.i_slot_sync(slot_sync),
		
		.i_complite(complite),
		
		.i_wr_vchn(adc_vchn_3),
		
		.i_ratio(adc_ratio_3),
		.i_data_len(adc_tick_3),
		
		`ifdef TESTMODE 
		.i_adc_data(adc_cntr),
		`else
		.i_adc_data(i_d_0x[7:0]),
		`endif
		
		.i_rd_vchn(rd_vchn),
		.o_data_count(data_count_3),
		
		.i_rd_addr(rd_addr_3),
		.o_rd_data(rd_data_3),
		
		.o_out_size(out_size_3),
		.o_frame_ready(frame_ready_3)
	);

	//------------------------------------------------------------------------
	
	assign o_frame_ready = frame_ready_0 & frame_ready_1 & frame_ready_2 & frame_ready_3;
	assign o_frame_size = out_size_0 + out_size_1 + out_size_2 + out_size_3;
	
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
		
		.o_out_data(o_out_data),
		.o_out_vld(o_out_vld),
		.i_out_rdy(i_out_rdy)
	);

endmodule
