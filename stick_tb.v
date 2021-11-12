`timescale 1ns/1ps

module stick_tb;

	initial begin
		`ifdef TESTMODE
			$display("Defined TESTMODE...");
		`endif
		$dumpfile("dumpfile_stick.vcd");
		$dumpvars(0);
		
		#600000
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
		
		#300000
		sync <= 1'b1;
		#200
		sync <= 1'b0;
	end
	
	stick_main stick_main_unit(
		.rst_n(rst_n),
		.hi_clk(hi_clk),
		
		.sys_clk(sys_clk),
		
		.i_tx_rdy(1'b1)
	);

endmodule

