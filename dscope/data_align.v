`timescale 1ns/1ps

module data_align(
	input						rst_n,
	input						clk,
	
	input						i_sync,
	
	input		[7:0]			i_data,
	input						i_wren,
	
	output		[31:0]			o_out_data,
	output						o_out_vld
);

	reg			[23:0]			res;
	
	reg			[1:0]			w_cnt;
	
	assign o_out_data = {res, i_data};
	assign o_out_vld = i_wren && &{w_cnt};
		
	always @ (posedge clk or negedge rst_n)
		if(~rst_n) begin
			w_cnt <= 2'd0;
			res <= 24'd0;			
		end
		else
			if(i_sync)
				w_cnt <= 2'd0;
			else
				if(i_wren)
					if(&{w_cnt})
						w_cnt <= 2'd0;
					else begin
						w_cnt <= w_cnt + 1'd1;
						res <= {res[15:0], i_data};
					end
	
	
endmodule

