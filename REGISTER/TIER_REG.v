module TIER_REG (
	input wire clk,
	input wire rst_n,	
	input wire [31:0] wr_data,
	input wire [11:0] addr,
	input wire wr_en,
	output wire [31:0] rd_data
);
	//--- Declaring local parameter
	localparam TIER_ADDR = 12'h14;

	//--- Declaring nets
	wire next_int_en_mux_sel;
	wire next_int_en;

	//--- Declaring variables
	reg int_en;

	//--- Processing int_eb_reg
	always @(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			int_en <= 1'b0;	
		end else begin
			int_en <= next_int_en;
		end
	end

	//--- Processing mux next_en_int
	assign next_int_en = next_int_en_mux_sel ? wr_data[0] : int_en; 

	//--- Processing next_int_en_mux_sel
	assign next_int_en_mux_sel = (addr == TIER_ADDR) & wr_en;

	//--- Processing data out
	assign rd_data = {31'h0,int_en};

endmodule
