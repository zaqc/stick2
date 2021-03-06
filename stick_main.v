module stick_main(
	input						rst_n,
	
	input						hi_clk,		// 200 MHz for Pulse
	
	input						sys_clk,	// 100 MHz for system
	
	input						adc_clk,	// 20 MHz for ADC
	
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
	
	output		[3:0]			o_doffs_x,
	output		[3:0]			o_soffs_nx,
	output		[3:0]			o_mclk_x,
	
	input		[11:0]			i_d_0x,
	input		[11:0]			i_d_1x,
	input		[11:0]			i_d_2x,
	input		[11:0]			i_d_3x,
		
	output		[31:0]			o_tx_data,	// send to Ethernet
	output						o_tx_vld,
	output						o_tx_sop,
	output						o_tx_eop,
	input						i_tx_rdy,
	
	input		[31:0]			i_rx_data,	// receive from Ethernet
	input						i_rx_vld,
	input						i_rx_sop,
	input						i_rx_eop,
	output						o_rx_rdy,
	
	output		[31:0]			o_out_data,
	output						o_out_vld,
	input						i_out_rdy,
	
	output		[3:0]			o_led_cntr,
	
	output		[2:0]			o_high_voltage
);

	wire		[31:0]			frame_data;
	wire						frame_vld;
	wire						frame_rdy;
	
	wire						frame_ready;
	wire		[15:0]			frame_size;
	
	wire						dac_cs_n;
	
	wire		[31:0]			cmd_magic;
	wire		[31:0]			cmd_command;
	wire						cmd_vld;
	wire						cmd_rdy;
	
//	reg			[3:0]			led_cntr;
//	initial led_cntr <= 4'd0;
//	always @ (posedge sys_clk)
//		if(cmd_vld) led_cntr <= led_cntr + 1'd1;
//		
//	assign o_led_cntr = led_cntr;

	dscope_main dscope_main_unit(
		.rst_n(rst_n),
		.hi_clk(hi_clk),
		.sys_clk(sys_clk),
		
		.adc_clk(adc_clk),
				
		.i_ch_a(i_ch_a),
		.i_ch_b(i_ch_b),
		
		.i_cmd_magic(cmd_magic),
		.i_cmd_command(cmd_command),
		.i_cmd_vld(cmd_vld),
		.o_cmd_rdy(cmd_rdy),
		
		.o_phase_ax(o_phase_ax),
		.o_phase_bx(o_phase_bx),
		.o_phase_cx(o_phase_cx),
		.o_phase_dx(o_phase_dx),
		
		.o_nenz_0x(o_nenz_0x),
		.o_nenz_1x(o_nenz_1x),
		.o_nenz_2x(o_nenz_2x),
		.o_nenz_3x(o_nenz_3x),
		
		.o_en_0x(o_en_0x),
		.o_en_1x(o_en_1x),
		.o_en_2x(o_en_2x),
		.o_en_3x(o_en_3x),
		
		.i_d_0x(i_d_0x),
		.i_d_1x(i_d_1x),
		.i_d_2x(i_d_2x),
		.i_d_3x(i_d_3x),
		
		.o_dac_data_0(o_doffs_x[0]),
		.o_dac_data_1(o_doffs_x[1]),
		.o_dac_data_2(o_doffs_x[2]),
		.o_dac_data_3(o_doffs_x[3]),
		
		.o_dac_cs_n(dac_cs_n),
		
		.o_out_data(frame_data),
		.o_out_vld(frame_vld),
		.i_out_rdy(frame_rdy),
		
		.o_frame_ready(frame_ready),
		.o_frame_size(frame_size),
		
		.o_led_cntr(o_led_cntr),
		
		.o_high_voltage(o_high_voltage)
	);
	
	assign o_soffs_nx = {dac_cs_n, dac_cs_n, dac_cs_n, dac_cs_n};
	
	packet_sender packet_sender_unit(
		.rst_n(rst_n),
		.clk(sys_clk),		
		.i_sync(frame_ready),

		.i_rx_data(i_rx_data),
		.i_rx_vld(i_rx_vld),
		.i_rx_sop(i_rx_sop),
		.i_rx_eop(i_rx_eop),
		.o_rx_rdy(o_rx_rdy),
		
		.o_tx_data(o_tx_data),
		.o_tx_vld(o_tx_vld),
		.o_tx_sop(o_tx_sop),
		.o_tx_eop(o_tx_eop),
		.i_tx_rdy(i_tx_rdy),
		
		.i_in_data(frame_data),
		.i_in_vld(frame_vld),
		.o_in_rdy(frame_rdy),
		
		.o_def_addr(cmd_magic),
		.o_def_data(cmd_command),
		.o_def_wren(cmd_vld),
		.i_def_rdy(cmd_rdy),
		
		.i_udp_pkt_len({frame_size[13:0], 2'b00})	// convert 32bit word to bytes (x4)

	);
	
	reg			[0:0]			prev_frame_ready;
	always @ (posedge sys_clk) prev_frame_ready <= frame_ready;
		
	reg			[15:0]			w_cnt;
	always @ (posedge sys_clk or negedge rst_n)
		if(~rst_n)
			w_cnt <= 16'd0;
		else
			if(~prev_frame_ready & frame_ready)
				w_cnt <= 16'd0;
			else
				w_cnt <= frame_rdy & frame_vld ? w_cnt + 1'd1 : w_cnt;

endmodule

