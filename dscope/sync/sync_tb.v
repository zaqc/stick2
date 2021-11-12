`timescale 1ns/1ps

module dscope_tb;

	initial begin
		`ifdef TESTMODE
			$display("Defined TESTMODE...");
		`endif
		$dumpfile("dumpfile_sync.vcd");
		$dumpvars(0);
		
		#200000
		$finish();
	end
	
	reg			[0:0]			rst_n;
	initial begin
		rst_n <= 1'b0;
		#10
		rst_n <= 1'b1;
	end
	
	reg			[0:0]			clk;
	initial begin
		clk <= 1'b0;
		#1
		forever begin
			#0.5
			clk <= ~clk;
		end
	end
	
	reg			[1:0]			md[0:3];

	initial begin
		md[0] <= 2'b00;
		md[1] <= 2'b10;
		md[2] <= 2'b11;
		md[3] <= 2'b01;		
	end
	
	reg			[7:0]			clk_div;
	reg			[7:0]			cntr;
	reg			[0:0]			inc_dec;
	always @ (posedge clk or negedge rst_n)
		if(~rst_n) begin
			cntr <= 8'd0;
			inc_dec <= 1'b1;
			clk_div <= 8'd0;
		end
		else
			if(clk_div < 8'd100)
				clk_div <= clk_div + 1'd1;
			else begin
				clk_div <= 8'd0;
				if(inc_dec) begin
					if(&{cntr})
						inc_dec <= 1'b0;
					else
						cntr <= cntr + 1'd1;
				end
				else begin
					if(~|{cntr})
						inc_dec <= 1'b1;
					else
						cntr <= cntr - 1'd1;
				end
			end
		
	wire		[1:0]			ab;
	assign ab = md[cntr[1:0]];
		
	synchronizer synchronizer_unit(
		.rst_n(rst_n),
		.clk(clk),
		
		.i_ch_a(ab[1]),
		.i_ch_b(ab[0]),
		
		.i_in_sync_div(16'd100),
		
		.i_wheel_add(8'd3),
		.i_frame_dec(8'd7)
	);
		
endmodule

