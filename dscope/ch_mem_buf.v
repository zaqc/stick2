`timescale 1ns/1ps

module ch_mem_buf(
	input						wrclock,
	input		[10:0]			wraddress,
	input		[31:0]			data,
	input						wren,
		
	input						rdclock,
	input		[10:0]			rdaddress,
	output		[31:0]			q
);

	`ifdef TESTMODE
	reg			[31:0]			mem_buf[0:2047];
	
	reg			[31:0]			wrdata;
	
	always @ (posedge wrclock)
		if(wren) begin
			mem_buf[wraddress] <= data;
			wrdata <= data;
		end
			
	assign q = mem_buf[rdaddress];
	`else
	ch_ram ch_ram_unit(
		.wrclock(wrclock),
		.wraddress(wraddress),
		.data(data),
		.wren(wren),
		
		.rdclock(rdclock),
		.rdaddress(rdaddress),
		.q(q)
	);
	`endif

endmodule

