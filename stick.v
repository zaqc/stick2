module stick(
//system interface
		clk,
		alt_rdy,
		reset_n,
//phy 1 intrface second defectoscope connection
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
//phy 2 interface head connection
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
//com ports
		com0_tx,
		com0_rx,
		com1_tx,
		com1_rx,
//test leds
		led,
//whell synchronization input
		adp,
		bdp,
//high voltage control 3'b111 - 90V; 3'b011 (3'b101, 3b110) - 60V; 3'b001 (3'b010, 3'b100) - 30V; 3'b000 - 0V
		hpwon,
//external rs422 synchronization
		sync,
//stm8s003 interface
		intst,
		outtst,
//channals interface
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
//system interface
input clk;
output alt_rdy;
input reset_n;
//phy 1 intrface second defectoscope connection
input [3:0] rxd_1x;
input rxer_1x;
input rxdv_1x;
input rxclk_1x;
input col_1x;
input crs_1x;
output [3:0] txd_1x;
output txer_1x;
output txen_1x;
input	txclk_1x;
inout mdio_1x;
output mdc_1x;
output nrst_1x;
//phy 2 interface head connection
input [3:0] rxd_2x;
input rxer_2x;
input rxdv_2x;
input rxclk_2x;
input col_2x;
input crs_2x;
output [3:0] txd_2x;
output txer_2x;
output txen_2x;
input txclk_2x;
inout mdio_2x;
output mdc_2x;
output nrst_2x;
//com ports
output com0_tx;
input com0_rx;
output com1_tx;
input com1_rx;
//test leds
output [3:0] led;
//whell synchronization input
input adp;
input bdp;
//high voltage control 3'b111 - 90V; 3'b011 (3'b101, 3b110) - 60V; 3'b001 (3'b010, 3'b100) - 30V; 3'b000 - 0V
output [2:0] hpwon;
//external rs422 synchronization
input sync;
//stm8s003 interface
input intst;
output outtst;
//channals interface
output [3:0] phase_ax;
output [3:0] phase_bx;
output [3:0] phase_cx;
output [3:0] phase_dx;
output [3:0] nenz_0x;
output [3:0] nenz_1x;
output [3:0] nenz_2x;
output [3:0] nenz_3x;
output [3:0] en_0x;
output [3:0] en_1x;
output [3:0] en_2x;
output [3:0] en_3x;
output [3:0] pdwn_x;						//sleep mode to physical channals !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
output [3:0] doffs_x;
output [3:0] soffs_nx;
output [3:0] mclk_x;
input [11:0] d_0x;
input [11:0] d_1x;
input [11:0] d_2x;
input [11:0] d_3x;

	stick_main stick_main_unit(
		.sys_clk(clk)
	);

endmodule
