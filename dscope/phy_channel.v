`timescale 1ns/1ps

module phy_channel(
	input						rst_n,
	input						clk,
	
	input						sys_clk,
	
	input						i_sync,			// Sync for full cycle
	
	input						i_slot_sync,	// Sync for each slot
		
	input		[7:0]			i_adc_data,		// x4 data from ADC
	input		[7:0]			i_data_len,		// x4 data len in Out Tick (ADC Accumed) 10'd1023 - Max
	input		[7:0]			i_adc_delay,
	
	input		[7:0]			i_ratio,
	
	input		[1:0]			i_wr_vchn,			// virtual channel number
	output		[3:0]			o_ch_mask,		// Channel Mask for RX_Switch

	input						i_complite,		// after full sync cycle
	
	input		[1:0]			i_rd_vchn,
	output		[7:0]			o_data_count,
	output		[31:0]			o_rd_data,
	input		[7:0]			i_rd_addr,
	
	output		[15:0]			o_out_size
);

	reg			[7:0]			data_count_0;
	reg			[7:0]			data_count_1;
	reg			[7:0]			data_count_2;
	reg			[7:0]			data_count_3;
	reg			[15:0]			out_size;
	always @ (posedge clk or negedge rst_n)
		if(~rst_n) begin
			half_for_read <= 1'b0;
			data_count_0 <= 8'd0;
			data_count_1 <= 8'd0;
			data_count_2 <= 8'd0;
			data_count_3 <= 8'd0;
			out_size <= 16'd0;
		end
		else			
			if(i_complite) begin
				half_for_read <= flip_half;
				data_count_0 <= data_count[{flip_half, 2'd0}];
				data_count_1 <= data_count[{flip_half, 2'd1}];
				data_count_2 <= data_count[{flip_half, 2'd2}];
				data_count_3 <= data_count[{flip_half, 2'd3}];
				out_size <= 16'd4 + data_count[{flip_half, 2'd0}] + data_count[{flip_half, 2'd1}] + 
					data_count[{flip_half, 2'd2}] + data_count[{flip_half, 2'd3}];
			end
			
	assign o_out_size = out_size;
			
	assign o_data_count = 
		i_rd_vchn == 2'd0 ? data_count_0 :
		i_rd_vchn == 2'd1 ? data_count_1 :
		i_rd_vchn == 2'd2 ? data_count_2 :
		i_rd_vchn == 2'd3 ? data_count_3 : 8'dX;
		
	reg			[0:0]			flip_half;
	reg			[0:0]			half_for_read;

	reg			[7:0]			addr;
	reg							wr_flag;	
	reg			[0:0]			data_ready;
	wire		[10:0]			wr_addr;	// 2 buf by 1024 bytes
	assign wr_addr = {flip_half, i_wr_vchn, addr};
	
	wire		[10:0]			rd_addr;
	assign rd_addr = {half_for_read, i_rd_vchn, i_rd_addr};
	
	wire						out_adc_vld;
	wire		[31:0]			out_adc_data;
	adc_data adc_data_unit(
		.rst_n(rst_n),
		.clk(clk),
		
		.i_adc_data(i_adc_data),
		.i_ratio(i_ratio),
		
		.i_sync(i_sync),
		.o_out_vld(out_adc_vld),
		.o_out_data(out_adc_data),
		
		.i_complite(i_complite)
	);
	
	reg			[7:0]			data_count[0:7];
		
	reg			[2:0]			i;
	reg			[7:0]			adc_delay;
	always @ (posedge clk or negedge rst_n)
		if(~rst_n) begin
			addr <= 8'd0;
			wr_flag <= 1'b0;
			data_ready <= 1'b0;
			flip_half <= 1'b0;
			for(i = 3'd0; ~|{i}; i = i + 1'd1)
				data_count[i] <= 8'd0;
			adc_delay <= 8'd0;
		end
		else
			if(i_sync) begin				
				for(i = 3'd0; i < 3'd4; i = i + 1'd1)
					data_count[{~flip_half, i[1:0]}] <= 8'd0;
				adc_delay <= 8'd0;
					
				flip_half <= ~flip_half;
			end
			else
				if(i_slot_sync) begin
					addr <= 8'd0;
					wr_flag <= |{i_data_len} ? 1'b1 : 1'b0;
					data_ready <= 1'b0;
					adc_delay <= 8'd0;
				end
				else
					if(wr_flag && out_adc_vld) begin
						if(adc_delay < i_adc_delay)
							adc_delay <= adc_delay + 1'd1;
						else begin
							if(&{addr} || 9'd1 + addr >= i_data_len) begin
								wr_flag <= 1'b0;
								data_ready <= 1'b1;
								data_count[{flip_half, i_wr_vchn}] <= addr + 1'd1;
							end
							else
								addr <= addr + 1'd1;
						end
					end
						
	ch_mem_buf ch_mem_buf_unit(
		.wrclock(clk),
		.wraddress(wr_addr),
		.data(out_adc_data),
		.wren(wr_flag & out_adc_vld),
		
		.rdclock(sys_clk),
		.rdaddress(rd_addr),
		.q(o_rd_data)
	);
	

endmodule
