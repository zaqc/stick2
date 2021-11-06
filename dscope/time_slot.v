`timescale 1ns/1ps

module time_slot(
	input						rst_n,
	input						clk,
	
	input						i_sync,
	
	input			[15:0]		i_ts0,
	input			[15:0]		i_ts1,
	input			[15:0]		i_ts2,
	input			[15:0]		i_ts3,
	
	output			[1:0]		o_slot,
	output						o_slot_sync,
	
	output						o_complite
);

	parameter		[2:0]		ST_NONE = 3'd0,
								ST_SLOT_0 = 3'd1,
								ST_SLOT_1 = 3'd2,
								ST_SLOT_2 = 3'd3,
								ST_SLOT_3 = 3'd4;
								
	wire						t0_vld;
	assign t0_vld = |{i_ts0};
	wire						t1_vld;
	assign t1_vld = |{i_ts1};
	wire						t2_vld;
	assign t2_vld = |{i_ts2};
	wire						t3_vld;
	assign t3_vld = |{i_ts3};

	function [2:0] GetNextSlot(
		input 	[2:0] 			slot
	);
		case(slot)
			ST_NONE: GetNextSlot = t0_vld ? ST_SLOT_0 : t1_vld ? ST_SLOT_1 : t2_vld ? ST_SLOT_2 : t3_vld ? ST_SLOT_3 : ST_NONE;
			ST_SLOT_0: GetNextSlot = t1_vld ? ST_SLOT_1 : t2_vld ? ST_SLOT_2 : t3_vld ? ST_SLOT_3 : ST_NONE;
			ST_SLOT_1: GetNextSlot = t2_vld ? ST_SLOT_2 : t3_vld ? ST_SLOT_3 : ST_NONE;
			ST_SLOT_2: GetNextSlot = t3_vld ? ST_SLOT_3 : ST_NONE;
			ST_SLOT_3: GetNextSlot = ST_NONE;
			default:  GetNextSlot = ST_NONE;
		endcase
	endfunction
	
	function [15:0] GetSlotLen(
		input 	[2:0] 			slot
	);
		case(slot)
			ST_SLOT_0: GetSlotLen = i_ts0;
			ST_SLOT_1: GetSlotLen = i_ts1;
			ST_SLOT_2: GetSlotLen = i_ts2;
			ST_SLOT_3: GetSlotLen = i_ts3;
			default: GetSlotLen = 16'hXXXX;
		endcase	
	endfunction
	
	function [1:0] GetSlotNumber(
		input	[2:0]			slot
	);
		case(slot)
			ST_SLOT_0: GetSlotNumber = 2'd0;
			ST_SLOT_1: GetSlotNumber = 2'd1;
			ST_SLOT_2: GetSlotNumber = 2'd2;
			ST_SLOT_3: GetSlotNumber = 2'd3;
			default: GetSlotNumber = 2'dX;
		endcase			
	endfunction
	
	reg			[2:0]			slot_num;
	reg			[15:0]			slot_tick_cntr;
	always @ (posedge clk or negedge rst_n)
		if(~rst_n) begin
			slot_num <= ST_NONE;
			slot_tick_cntr <= 16'd0;
		end
		else
			if(i_sync) begin
				slot_num <= GetNextSlot(ST_NONE);
				slot_tick_cntr <= 16'd0;
			end
			else
				if(slot_num != ST_NONE) begin
					if(slot_tick_cntr + 1'd1 < GetSlotLen(slot_num))
						slot_tick_cntr <= slot_tick_cntr + 1'd1;
					else begin
						slot_tick_cntr <= 16'd0;
						slot_num <= GetNextSlot(slot_num);
					end
				end
				
	reg			[2:0]			prev_slot_num;
	always @ (posedge clk) prev_slot_num <= slot_num;
	
	assign o_slot_sync = prev_slot_num != slot_num && slot_num != ST_NONE;
	
	assign o_complite = prev_slot_num != slot_num && slot_num == ST_NONE;
	
	assign o_slot = GetSlotNumber(slot_num);
	
endmodule

