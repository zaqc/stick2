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
	
	reg			[0:0]			tx_rdy;
	initial begin
		tx_rdy <= 1'b1;
		#1267900
		tx_rdy <= 1'b0;
		#100
		tx_rdy <= 1'b1;
	end
	
	dscope_main dscope_main_unit(
		.rst_n(rst_n),
		.hi_clk(hi_clk),
		
		.sys_clk(sys_clk),
		.adc_clk(adc_clk),
		
		.i_sync(sync),
		
		.i_out_rdy(in_rdy & tx_rdy)
	);	

endmodule

