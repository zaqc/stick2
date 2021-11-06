`timescale 1ns/1ps

module dscope_tb;

	initial begin
		`ifdef TESTMODE
			$display("Defined TESTMODE...");
		`endif
		$dumpfile("dumpfile_dscope.vcd");
		$dumpvars(0);
		
		#2000000
		$finish();
	end
	
	reg			[0:0]			hi_clk;
	reg			[0:0]			rst_n;
	initial begin
		hi_clk <= 1'b0;
		rst_n <= 1'b0;
		#10
		rst_n <= 1'b1;
		forever begin
			#3
			hi_clk <= ~hi_clk;
		end
	end
	
	reg			[0:0]			sys_clk;	// 100 MHz
	initial begin
		sys_clk <= 1'b1;
		forever begin
			#5 
			sys_clk <= ~sys_clk;
		end
	end
	
	reg			[0:0]			sync;
	initial begin
		sync <= 1'b0;
		#973
		sync <= 1'b1;
		#200
		sync <= 1'b0;
		
		#1000000
		sync <= 1'b1;
		#200
		sync <= 1'b0;
	end
	
	reg			[0:0]			in_rdy;
	initial begin
		in_rdy <= 1'b1;
		#265000
		in_rdy <= 1'b0;
		#100
		in_rdy <= 1'b1;
		#100
		in_rdy <= 1'b0;
		#100
		in_rdy <= 1'b1;
		#100
		in_rdy <= 1'b0;
		#100
		in_rdy <= 1'b1;
	end
	dscope_main dscope_main_unit(
		.rst_n(rst_n),
		.hi_clk(hi_clk),
		
		.sys_clk(sys_clk),
		.i_sync(sync),
		
		.i_out_rdy(in_rdy)
	);	

endmodule

