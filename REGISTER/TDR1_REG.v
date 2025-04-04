module TDR1_REG (
	input wire wr_en,
	input wire [11:0] addr,
	input wire [31:0] wr_data,
	input wire [31:0] msb_count,
	output wire [31:0] rd_data,
	output wire [31:0] wr_count,
	output wire tdr1_wr_en
);
	//--- Declaring local para
	localparam TDR1_ADDR = 12'h8;
	
	//--- Declaring nets
	wire addr_en;
	
	//--- Processing wr_count
	assign wr_count = wr_data;
	
	//--- Processing tdr1_wr_en
	assign tdr1_wr_en = addr_en && wr_en;

	//--- Processing addr correct ?
	assign addr_en = (addr == TDR1_ADDR);

	//--- Processing output data
	assign rd_data = msb_count;
	
endmodule

