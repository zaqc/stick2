`timescale 1ns/1ps

module pulse_channel(
	input						rst_n,
	
	input						hi_clk,		// 200 MHz Clock
	
	input						i_sync,
	
	input		[7:0]			i_hit_len,	// hi/lo state time in 5ns tick
	input		[7:0]			i_gnd_len,	// gnd state time in 5 ns tick
	
	input		[3:0]			i_pulse_count,	// Pulse (Hi,Gnd,Lo,Gnd cycle) count 
	input		[15:0]			i_hush_len,		// Hush time (Gnd) after all pulses (in 5 ns tick)
	
	output						o_znd_hi,
	output						o_znd_lo_n,
	output						o_znd_gnd,
	output						o_znd_gnd_n
);

	reg			[0:0]			prev_sync;
	always @ (posedge hi_clk) prev_sync <= i_sync;
	
	wire						sync_pulse;
	assign sync_pulse = ~prev_sync & i_sync;

	assign o_znd_hi = znd_state == ZS_HI ? 1'b1 : 1'b0;
	assign o_znd_lo_n = znd_state == ZS_LO ? 1'b0 : 1'b1;
	assign o_znd_gnd = znd_state == ZS_HI_GND || znd_state == ZS_LO_GND || 
						znd_state == ZS_HUSH_GND ? 1'b1 : 1'b0;
	assign o_znd_gnd_n = ~o_znd_gnd;
	
	parameter	[2:0]			ZS_NONE = 3'd0,
								ZS_HI = 3'd1,
								ZS_HI_GND = 3'd2,
								ZS_LO = 3'd3,
								ZS_LO_GND = 3'd4,
								ZS_HUSH_GND = 3'd5;
								
	parameter	[1:0]			PS_NONE = 2'd0,
								PS_HITTING = 2'd1,
								PS_HUSHING = 2'd2;
								
	reg			[1:0]			pulse_state;	// Pulse State (Pulsing or Hushing)
	always @ (posedge hi_clk or negedge rst_n)
		if(~rst_n)
			pulse_state <= PS_NONE;
		else
			if(sync_pulse)
				pulse_state <= |{i_pulse_count} ? PS_HITTING : PS_NONE;
				
			
	wire		[2:0]			next_znd_state;
	wire		[7:0]			next_znd_len;

	assign {next_znd_state, next_znd_len} = 
		znd_state == ZS_NONE ? (sync_pulse ? {ZS_HI, i_hit_len} : {ZS_NONE, 8'dX})  :
		znd_state == ZS_HI ? {ZS_HI_GND, i_gnd_len} :
		znd_state == ZS_HI_GND ? {ZS_LO, i_hit_len} :
		znd_state == ZS_LO ? {ZS_LO_GND, i_gnd_len} :
		znd_state == ZS_LO_GND ? (pulse_count + 1'd1 < i_pulse_count ? {ZS_HI, i_hit_len} : 
									(|{i_hush_len} ? {ZS_HUSH_GND, 8'dX} : {ZS_NONE, 8'dX})) : 
		{ZS_NONE, 8'dX};
				
	
				
	reg			[7:0]			znd_cntr;
	reg			[7:0]			znd_len;
	reg			[2:0]			znd_state;
	reg			[3:0]			pulse_count;
	reg			[15:0]			hush_cntr;
	always @ (posedge hi_clk or negedge rst_n)
		if(~rst_n) begin
			pulse_state <= PS_NONE;
			znd_state <= ZS_NONE;
			pulse_count <= 4'd0;
			znd_cntr <= 8'd0;
			znd_len <= 8'd0;
		end
		else
			if(sync_pulse) begin
				pulse_state <= PS_HITTING;
				pulse_count <= 4'd0;
				znd_state <= ZS_HI;
				znd_cntr <= 8'd0;
				znd_len <= i_hit_len;
				hush_cntr <= 16'd0;
			end
			else
				case(pulse_state)
					PS_HITTING: 
						if(znd_cntr + 1'd1 < znd_len)
							znd_cntr <= znd_cntr + 1'd1;
						else begin
							znd_cntr <= 8'd0;
							znd_len <= next_znd_len;
							znd_state <= next_znd_state;
							case(next_znd_state)
								ZS_HI: pulse_count <= pulse_count + 1'd1;
								ZS_HUSH_GND: pulse_state <= PS_HUSHING;
								ZS_NONE: pulse_state <= PS_NONE;
							endcase
						end
					
					PS_HUSHING:
						if(hush_cntr + 1'd1 < i_hush_len)
							hush_cntr <= hush_cntr + 1'd1;
						else begin
							pulse_state <= PS_NONE;
							znd_state <= ZS_NONE;
						end
				endcase
endmodule

