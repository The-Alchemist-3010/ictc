module TISR_REG (
	input wire clk,
	input wire rst_n,
	input wire [31:0] wr_data,
    input wire wr_en,
	input wire [11:0] addr,
	input wire cmp,	
	input wire int_en,
	output wire [31:0] rd_data
);
	//--- Declaring local parameter
	localparam TISR_ADDR = 12'h18;
	
	//--- Declaring nets
	wire int_mux_sel;
	wire clear_mux_sel;
	wire int_mux_out;
	wire clear_mux_out;

	//--- Declaring variables
	reg int_st;

	//--- Processing TISR_REG
	always @(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			int_st <= 1'b0;	
		end else begin
			int_st <= clear_mux_out;
		end
	end

	//--- Processing clear_mux_out
	assign clear_mux_out = clear_mux_sel ? 1'b0 : int_mux_out;

	//--- Processing int_mux_out
	assign int_mux_out = int_mux_sel ? 1'b1 : int_st;

	//--- Processing int_mux_sel
	assign int_mux_sel = int_en && cmp;

	//--- Processing clear_mux_sel
	assign clear_mux_sel = wr_en & wr_data[0] & (addr == TISR_ADDR); 

	//--- Processing data out
	assign rd_data = {31'b0,int_st};

endmodule
