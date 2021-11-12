module frame_header(
	input						rst_n,
	input						clk,
	
	input						i_sync,
	
	output		[15:0]			o_header_size,
	
	input		[31:0]			i_sync_counter,
	input		[31:0]			i_way_meter,
	input		[31:0]			i_system_timer,
	
	input		[31:0]			i_frame_data,
	input						i_frame_vld,
	output						o_frame_rdy,
	
	output		[31:0]			o_out_data,
	output						o_out_vld,
	input						i_out_rdy
);

	reg			[2:0]			state;
	
	reg			[31:0]			sync_counter;
	reg			[31:0]			way_meter;
	reg			[31:0]			system_timer;
	
	assign o_header_size = 16'd4;
	
	always @ (posedge clk or negedge rst_n)
		if(~rst_n)
			state <= 3'd0;
		else
			if(i_sync) begin
				state <= 3'd1;
				sync_counter <= i_sync_counter;
				way_meter <= i_way_meter;
				system_timer <= i_system_timer;
			end
			else
				if(state < 3'd5 && i_out_rdy)
					state <= state + 1'd1;
			
	assign {o_out_data, o_out_vld, o_frame_rdy} =
		state == 3'd1 ? {32'hEC534F4D, 1'b1, 1'b0} :
		state == 3'd2 ? {sync_counter, 1'b1, 1'b0} :
		state == 3'd3 ? {way_meter, 1'b1, 1'b0} :
		state == 3'd4 ? {system_timer, 1'b1, 1'b0} : 
		state == 3'd5 ? {i_frame_data, i_frame_vld, i_out_rdy} :
			{32'hXXXXXXXX, 1'b0, 1'b0};

endmodule
