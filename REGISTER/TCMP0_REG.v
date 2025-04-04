module TCMP0_REG (
	input wire clk,
	input wire rst_n,
	input wire [12:0] addr,
	input wire [31:0] wr_data,
	input wire wr_en,
	output wire [31:0] rd_data
);

	//--- Declaring local parameter
	localparam TCMP0_ADDR = 12'h0c;

	//--- Declaring variable
	reg [31:0] tcmp0_reg;

	//--- Declaring nets
	wire next_tcmp0_mux_sel;
	wire [31:0] next_tcmp0;

	//--- Processing tcmp0
	always @(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			tcmp0_reg <= 32'hFFFF_FFFF;
		end else begin
			tcmp0_reg <= next_tcmp0;
		end
	end
	
	//--- Processing mux next_tcmp0
	assign next_tcmp0 = next_tcmp0_mux_sel ? wr_data : tcmp0_reg;

	//--- Processing next_tcmp0_mux_sel
	assign next_tcmp0_mux_sel = wr_en & (addr == TCMP0_ADDR);

	//--- Processing data out
	assign rd_data = tcmp0_reg;

endmodule 

