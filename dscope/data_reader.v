`timescale 1ns/1ps

module data_reader(
	input						rst_n,
	input						clk,	// 100 MHz
	
	input						i_complite,
	
	output		[1:0]			o_rd_vchn,
	
	input		[7:0]			i_data_len_0,
	input		[31:0]			i_rd_data_0,
	output		[7:0]			o_rd_addr_0,
	
	input		[7:0]			i_data_len_1,
	input		[31:0]			i_rd_data_1,
	output		[7:0]			o_rd_addr_1,
	
	input		[7:0]			i_data_len_2,
	input		[31:0]			i_rd_data_2,
	output		[7:0]			o_rd_addr_2,
	
	input		[7:0]			i_data_len_3,
	input		[31:0]			i_rd_data_3,
	output		[7:0]			o_rd_addr_3,
	
	output		[31:0]			o_out_data,
	output						o_out_vld,
	input						i_out_rdy
);	

	assign o_rd_vchn = rd_channel[1:0];
	
	wire		[7:0]			data_len;
	
	assign data_len =
		rd_channel[3:2] == 2'd0 ? i_data_len_0 :
		rd_channel[3:2] == 2'd1 ? i_data_len_1 :
		rd_channel[3:2] == 2'd2 ? i_data_len_2 :
		rd_channel[3:2] == 2'd3 ? i_data_len_3 : 8'dX;
		
	wire		[31:0]			rd_data;
	assign rd_data =
		rd_channel[3:2] == 2'd0 ? i_rd_data_0 :
		rd_channel[3:2] == 2'd1 ? i_rd_data_1 :
		rd_channel[3:2] == 2'd2 ? i_rd_data_2 :
		rd_channel[3:2] == 2'd3 ? i_rd_data_3 : 32'dX;
	
	reg			[0:0]			prev_complite;
	always @ (posedge clk) prev_complite <= i_complite;
	wire						complite_rise;
	assign complite_rise = prev_complite & ~i_complite;
	
	reg			[3:0]			rd_channel;
	reg			[0:0]			rd_flag;
	reg			[7:0]			i_cntr;
	reg			[0:0]			read_ws;
	reg			[0:0]			ch_info;
	
	always @ (posedge clk or negedge rst_n)
		if(~rst_n) begin
			rd_channel <= 4'd0;
			rd_flag <= 1'b0;
			i_cntr <= 8'd0;
			read_ws <= 1'b0;
			ch_info <= 1'b1;
		end
		else
			if(complite_rise) begin
				rd_flag <= 1'b1;
				rd_channel <= 4'd0;
				i_cntr <= 8'd0;
				read_ws <= 1'b0;
				ch_info <= 1'b1;
			end
			else
				if(rd_flag && i_out_rdy) begin
					if(ch_info) begin
						if(|{data_len}) 
							ch_info <= 1'b0;
						else						
						begin
							if(&{rd_channel})
								rd_flag <= 1'b0;
							else
								rd_channel <= rd_channel + 1'd1;							
						end
					end
					else
						if(i_cntr + 1'd1 < data_len || ~read_ws) begin
							if(read_ws) begin
								i_cntr <= i_cntr + 1'd1;
								read_ws <= 1'b0;
							end
							else
								read_ws <= 1'b1;						
						end
						else begin
							i_cntr <= 8'd0;
							read_ws <= 1'b0;
							
							if(&{rd_channel})  begin
								rd_flag <= 1'b0;
								rd_channel <= 4'd0;
							end
							else begin
								rd_channel <= rd_channel + 1'd1;
								ch_info <= 1'b1;
							end
						end
				end
				
	assign o_out_vld = rd_flag & (ch_info || read_ws);
	assign o_out_data = ch_info ? {22'd0, data_len} : rd_data;
	
	assign o_rd_addr_0 = i_cntr;
	assign o_rd_addr_1 = i_cntr;
	assign o_rd_addr_2 = i_cntr;
	assign o_rd_addr_3 = i_cntr;
	
endmodule

