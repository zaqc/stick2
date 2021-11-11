`timescale 1ns/1ps

module dscope_tb;

	initial begin
		`ifdef TESTMODE
			$display("Defined TESTMODE...");
		`endif
		$dumpfile("dumpfile_clocksync.vcd");
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
	
	reg			[0:0]			hi_clk;
	initial begin
		hi_clk <= 1'b0;
		#1
		forever begin
			#2.5
			hi_clk <= ~hi_clk;
		end
	end
	
	reg			[0:0]			sys_clk;	// 100 MHz
	initial begin
		sys_clk <= 1'b1;
		#2
		forever begin
			#5 
			sys_clk <= ~sys_clk;
		end
	end
	
	reg			[0:0]			adc_clk;	// 20 MHz
	initial begin
		adc_clk <= 1'b1;
		#3
		forever begin
			#25
			adc_clk <= ~adc_clk;
		end
	end
	
	reg			[7:0]			sync;
	initial sync <= 8'd0;
	always @ (posedge sys_clk)
		sync <= sync + 1'd1;
	
	clock_sync clock_sync_u0(
		.rst_n(rst_n),
		.hi_clk(hi_clk),
		.sys_clk(sys_clk),
		.adc_clk(adc_clk),
		
		.i_sync(&{sync})
	);
		
endmodule

