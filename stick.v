module stick(
		// system interface
		clk,
		alt_rdy,
		reset_n,
		
		// phy 1 intrface second defectoscope connection
		rxd_1x,
		rxer_1x,
		rxdv_1x,
		rxclk_1x,		
		col_1x,
		crs_1x,
		
		txd_1x,
		txer_1x,
		txen_1x,
		txclk_1x,
		
		mdio_1x,
		mdc_1x,
		nrst_1x,
		
		// phy 2 interface head connection
		rxd_2x,
		rxer_2x,
		rxdv_2x,
		rxclk_2x,
		col_2x,
		crs_2x,
		
		txd_2x,
		txer_2x,
		txen_2x,
		txclk_2x,
		
		mdio_2x,
		mdc_2x,
		nrst_2x,
		
		// com ports
		com0_tx,
		com0_rx,
		com1_tx,
		com1_rx,
		
		// test leds
		led,
		
		// whell synchronization input
		adp,
		bdp,
		
		// high voltage control 3'b111 - 90V; 3'b011 (3'b101, 3b110) - 60V; 3'b001 (3'b010, 3'b100) - 30V; 3'b000 - 0V
		hpwon,
		
		// external rs422 synchronization
		sync,
		
		// stm8s003 interface
		intst,
		outtst,
		
		// channals interface
		phase_ax,
		phase_bx,
		phase_cx,
		phase_dx,
		
		nenz_0x,
		nenz_1x,
		nenz_2x,
		nenz_3x,
		
		en_0x,
		en_1x,
		en_2x,
		en_3x,
		
		pdwn_x,
		doffs_x,
		soffs_nx,
		mclk_x,
		
		d_0x,
		d_1x,
		d_2x,
		d_3x
);

	// system interface
	input						clk;
	output 						alt_rdy;
	input 						reset_n;
	
	// phy 1 intrface second defectoscope connection
	input 		[3:0] 			rxd_1x;
	input 						rxer_1x;
	input 						rxdv_1x;
	input 						rxclk_1x;
	input 						col_1x;
	input 						crs_1x;
	
	output 		[3:0] 			txd_1x;
	output 						txer_1x;
	output 						txen_1x;
	input						txclk_1x;
	
	inout 						mdio_1x;
	output 						mdc_1x;
	
	output 						nrst_1x;
	
	// phy 2 interface head connection
	input 		[3:0] 			rxd_2x;
	input 						rxer_2x;
	input 						rxdv_2x;
	input 						rxclk_2x;
	input 						col_2x;
	input 						crs_2x;
	
	output 		[3:0] 			txd_2x;
	output 						txer_2x;
	output 						txen_2x;
	input 						txclk_2x;
	
	inout 						mdio_2x;
	output 						mdc_2x;
	
	output 						nrst_2x;
	
	// com ports
	output 						com0_tx;
	input 						com0_rx;
	output 						com1_tx;
	input 						com1_rx;
	
	// test leds
	output 		[3:0] 			led;
	
	// whell synchronization input
	input 						adp;
	input 						bdp;
	
	// high voltage control 3'b111 - 90V; 3'b011 (3'b101, 3b110) - 60V; 3'b001 (3'b010, 3'b100) - 30V; 3'b000 - 0V
	output 		[2:0] 			hpwon;
	
	// external rs422 synchronization
	input 						sync;
	
	// stm8s003 interface
	input 						intst;
	output 						outtst;
	
	// channals interface
	output 		[3:0] 			phase_ax;
	output 		[3:0] 			phase_bx;
	output 		[3:0] 			phase_cx;
	output 		[3:0] 			phase_dx;
	
	output 		[3:0] 			nenz_0x;
	output 		[3:0] 			nenz_1x;
	output 		[3:0] 			nenz_2x;
	output 		[3:0] 			nenz_3x;
	
	output 		[3:0] 			en_0x;
	output 		[3:0] 			en_1x;
	output 		[3:0] 			en_2x;
	output 		[3:0] 			en_3x;
	
	output 		[3:0] 			pdwn_x;		//sleep mode to physical channals !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	output 		[3:0] 			doffs_x;
	output 		[3:0] 			soffs_nx;
	output 		[3:0] 			mclk_x;
	
	input 		[11:0] 			d_0x;
	input 		[11:0] 			d_1x;
	input 		[11:0] 			d_2x;
	input 		[11:0] 			d_3x;

	//------------------------------------------------------------------------
	
	//assign hpwon = 3'd1;
	
	wire						sys_clk;
	wire						hi_clk;
	wire						adc_clk;
	wire						rst_n;
	main_pll main_pll_unit(
		.inclk0(clk),
		.c0(sys_clk),
		.c1(hi_clk),
		.c2(adc_clk),
		.locked(rst_n)
	);	
	
	wire		[31:0]			tx_data;
	wire						tx_vld;
	wire						tx_sop;
	wire						tx_eop;
	wire						tx_rdy;
	wire		[31:0]			rx_data;
	wire						rx_vld;
	wire						rx_sop;
	wire						rx_eop;
	wire						rx_rdy;	
	
	stick_main stick_main_unit(
		.rst_n(rst_n),
		
		.sys_clk(sys_clk),
		.hi_clk(hi_clk),
		.adc_clk(adc_clk),
		
		.i_ch_a(adp),
		.i_ch_b(bdp),
				
		.o_phase_ax(phase_ax),
		.o_phase_bx(phase_bx),
		.o_phase_cx(phase_cx),
		.o_phase_dx(phase_dx),
		
		.o_nenz_0x(nenz_0x),
		.o_nenz_1x(nenz_1x),
		.o_nenz_2x(nenz_2x),
		.o_nenz_3x(nenz_3x),
		
		.o_en_0x(en_0x),
		.o_en_1x(en_1x),
		.o_en_2x(en_2x),
		.o_en_3x(en_3x),
		
		.o_doffs_x(doffs_x),
		.o_soffs_nx(soffs_nx),
		
		.i_d_0x(d_0x),
		.i_d_1x(d_1x),
		.i_d_2x(d_2x),
		.i_d_3x(d_3x),
		
		.o_tx_data(tx_data),
		.o_tx_vld(tx_vld),
		.o_tx_sop(tx_sop),
		.o_tx_eop(tx_eop),
		.i_tx_rdy(tx_rdy),
		
		.i_rx_data(rx_data),
		.i_rx_vld(rx_vld),
		.i_rx_sop(rx_sop),
		.i_rx_eop(rx_eop),
		.o_rx_rdy(rx_rdy),
		
		.o_led_cntr(led),
		
		.o_high_voltage(hpwon)
	);
	
	//assign led[0] = adp;
	//assign led[1] = bdp;
	
	assign mclk_x = {adc_clk, adc_clk, adc_clk, adc_clk};
	
	wire						mdio_in_phy_1;
	wire						mdio_out_phy_1;
	wire						mdio_oen_phy_1;

	assign mdio_in_phy_1 = mdio_1x;
	assign mdio_1x = mdio_oen_phy_1 ? 1'bZ : mdio_out_phy_1;
	
	mac mac_unit_0(
		.reset(~rst_n),
		.clk(sys_clk),
		
		.address(phy_ctr_addr_1),
		.readdata(phy_ctr_rd_data_1),
		.read(phy_ctr_rd_1),
		.writedata(phy_ctr_wr_data_1),
		.write(phy_ctr_wr_1),
		.waitrequest(phy_ctr_waitreqest_1),
		
		.set_10(1'b0),
		.set_1000(1'b0),
		
		.rx_clk(rxclk_1x),
		.m_rx_d(rxd_1x),
		.m_rx_en(rxdv_1x),
		.m_rx_err(rxer_1x),
		.m_rx_crs(crs_1x),
		.m_rx_col(col_1x),
		
		.tx_clk(txclk_1x),
		.m_tx_d(txd_1x),
		.m_tx_en(txen_1x),
		.m_tx_err(txer_1x),
		
		.mdc(mdc_1x),
		.mdio_in(mdio_in_phy_1),
		.mdio_out(mdio_out_phy_1),
		.mdio_oen(mdio_oen_phy_1),
		
		.ff_tx_clk(sys_clk),
		.ff_tx_data(tx_data),
		.ff_tx_wren(tx_vld),
		.ff_tx_sop(tx_sop),
		.ff_tx_eop(tx_eop),
		.ff_tx_rdy(tx_rdy),
		.ff_tx_mod(2'd0),
		
		.ff_rx_clk(sys_clk),
		.ff_rx_data(rx_data),
		.ff_rx_dval(rx_vld),
		.ff_rx_sop(rx_sop),
		.ff_rx_eop(rx_eop),
		.ff_rx_rdy(rx_rdy)
	);
	
	assign nrst_1x = rst_n;
	
	wire		[7:0]			phy_ctr_addr_1;
	wire		[31:0]			phy_ctr_wr_data_1;
	wire						phy_ctr_wr_1;
	wire		[31:0]			phy_ctr_rd_data_1;
	wire						phy_ctr_rd_1;
	wire						phy_ctr_waitreqest_1;

	init_phy init_phy_unit_1(
		.clk(sys_clk),
		.rst_n(rst_n),

		.o_phy_ctr_addr(phy_ctr_addr_1),
		.o_phy_ctr_wr_data(phy_ctr_wr_data_1),
		.o_phy_ctr_wr(phy_ctr_wr_1),
		.i_phy_ctr_rd_data(phy_ctr_rd_data_1),
		.o_phy_ctr_rd(phy_ctr_rd_1),
		
		.i_phy_ctr_waitreqest(phy_ctr_waitreqest_1)
	);


endmodule
