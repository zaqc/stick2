module synchronizer(
	input						rst_n,
	input						clk,
	
	input						i_ch_a,
	input						i_ch_b,
	
	input						i_sync_enabled,
	input						i_int_ext_sync,
	
	output						o_sync,
	
	input		[7:0]			i_wheel_add,
	input		[7:0]			i_frame_dec,
	
	input		[15:0]			i_in_sync_div,
	
	output		[31:0]			o_sync_counter,
	output		[31:0]			o_way_meter,
	output		[31:0]			o_system_timer
);

	wire						sync;
	
	reg			[6:0]			cntr_1_MHz;
	
	always @ (posedge clk or negedge rst_n)
		if(~rst_n)
			cntr_1_MHz <= 7'd0;
		else
			cntr_1_MHz <= cntr_1_MHz < 7'd99 ? cntr_1_MHz + 1'd1 : 7'd0;
			
	wire						tick_1MHz;
	assign tick_1MHz = ~|{cntr_1_MHz};
	
	reg			[9:0]			cntr_1_kHz;
	always @ (posedge clk or negedge rst_n)
		if(~rst_n)
			cntr_1_kHz <= 10'd0;
		else
			cntr_1_kHz <= cntr_1_kHz < 10'd999 ? cntr_1_kHz + 1'd1 : 10'd0;
			
	wire						tick_1_kHz;
	assign tick_1_kHz = ~|{cntr_1_kHz} & tick_1MHz;
	
	reg			[31:0]			system_timer;
	always @ (posedge clk or negedge rst_n)
		if(~rst_n)
			system_timer <= 32'd0;
		else
			system_timer <= tick_1MHz ? system_timer + 1'd1 : system_timer;
			
	assign o_system_timer = system_timer;
			
	reg			[15:0]			in_sync_div_cntr;
	always @ (posedge clk or negedge rst_n)
		if(~rst_n)
			in_sync_div_cntr <= 16'd0;
		else
			if(tick_1_kHz)
				in_sync_div_cntr <= in_sync_div_cntr < i_in_sync_div ? in_sync_div_cntr + 1'd1 : 16'd0;
			
	wire						int_sync;
	assign int_sync = ~|{in_sync_div_cntr} & tick_1MHz;
	
	wire						ext_sync;
	
	ext_sync ext_sync_unit(
		.clk(clk),
		.rst_n(rst_n),
		
		.i_ch_a(i_ch_a),
		.i_ch_b(i_ch_b),
		
		.i_wheel_add(i_wheel_add),
		.i_frame_dec(i_frame_dec),
		
		.o_way_meter(o_way_meter),
		.o_ext_sync(ext_sync)
	);
	
	reg			[8:0]			sync_overrun;
	always @ (posedge clk or negedge rst_n)
		if(~rst_n)
			sync_overrun <= 9'd0;
		else
			if(o_sync)
				sync_overrun <= 9'd0;
			else
				sync_overrun <= &{sync_overrun} && tick_1MHz ? sync_overrun : sync_overrun + 1'd1;
				
	assign o_sync =
		~i_sync_enabled || ~&{sync_overrun} ? 1'b0 :
		i_int_ext_sync ? int_sync : ext_sync;

endmodule
