module TDR0_REG (
	input wire wr_en,
	input wire [11:0] addr,
	input wire [31:0] wr_data,
	input wire [31:0] lsb_count,
	output wire [31:0] rd_data,
	output wire [31:0] wr_count,
	output wire tdr0_wr_en
);
	//--- Declaring local para
	localparam TDR0_ADDR = 12'h4;
	
	//--- Declaring nets
	wire addr_en;
	
	//--- Processing wr_count
	assign wr_count = wr_data;
	
	//--- Processing tdr0_wr_en
	assign tdr0_wr_en = addr_en && wr_en;

	//--- Processing addr correct ?
	assign addr_en = (addr == TDR0_ADDR);

	//--- Processing output data
	assign rd_data = lsb_count;
	
endmodule

