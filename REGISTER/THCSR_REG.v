module THCSR_REG (
	input wire clk,
	input wire rst_n,
	input wire [11:0] addr,
	input wire wr_en,
	input wire [31:0] wr_data,
	input wire dbg_mode,
	output wire [31:0] rd_data	
);
	//--- Declaring local parameter
	localparam THCSR_ADDR = 12'h1C;

	//--- Declaring nets
	wire next_halt_req_mux_sel;
	wire next_halt_req_mux_out;
	wire halt_ack;

	//--- Declaring variables
	reg halt_req;

	//--- Processing halt_req
	always @(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			halt_req <= 1'b0;
		end else begin
			halt_req <= next_halt_req_mux_out;
		end
	end

	//--- Processing halt_ack
	assign halt_ack = halt_req && dbg_mode;

	//--- Processing next_halt_req_mux_sel
	assign next_halt_req_mux_sel = wr_en & (addr == THCSR_ADDR);

	//--- Processing next_halt_req_mux
	assign next_halt_req_mux_out = next_halt_req_mux_sel ? wr_data[0] : halt_req;

	//--- Processing data out
	assign rd_data = {30'h0,halt_ack,halt_req};

endmodule

