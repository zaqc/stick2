module stick_main(
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
	input						i_out_rdy
);

	wire		[31:0]			frame_data;
	wire						frame_vld;
	wire						frame_rdy;
	
	wire						frame_ready;
	wire		[15:0]			frame_size;

	dscope_main dscope_main_unit(
		.rst_n(rst_n),
		.hi_clk(hi_clk),
		.sys_clk(sys_clk),
		
		.o_adc_clk(o_adc_clk),
		
		.i_sync(i_sync),
		
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
		
		.o_out_data(frame_data),
		.o_out_vld(frame_vld),
		.i_out_rdy(frame_rdy),
		
		.o_frame_ready(frame_ready),
		.o_frame_size(frame_size)		
	);
	
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
		
		.i_udp_pkt_len({frame_size[13:0], 2'b00})	// convert bytes to 32bit word

	);

endmodule

