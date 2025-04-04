module COUNTER (
	input wire clk	          ,
	input wire rst_n          ,
	input wire [3:0] div_val  ,  //--- Control
	input wire div_en         ,	 //--- Control
	input wire halt_req       ,  //--- Control
	input wire timer_en       ,  //--- Control
	input wire [31:0] wr_data ,
	input wire tdr1_wr_en     ,
	input wire tdr0_wr_en     ,
	output wire [63:0] counter
);
	reg        timer_en_reg_neg;
	wire        timer_en_neg;

	//--- Processing timer_en_reg_neg
	always @(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			timer_en_reg_neg <= 1'b0;
		end else begin
			timer_en_reg_neg <= timer_en;
		end
	end

	//--- Procesisng timer_en_neg
	assign timer_en_neg = timer_en_reg_neg && (~timer_en);
	
	/////////////
	// BLOCK 1 //
	/////////////
	
	//--- Declaring variables
	reg [7:0] counter_in;

	//--- Declaring nets
	wire rst_counter_in_mux_sel;
	wire [7:0] next_counter_in;
	wire rst_counter_in;
	wire [7:0] halt_req_mux_out;

	//--- Processing counter_in
	always @(posedge clk or negedge rst_n or posedge timer_en_neg) begin
		if(~rst_n) begin
			counter_in <= 8'b0;
		end else if (timer_en_neg) begin
			counter_in <= 8'h0;
		end else begin
			counter_in <= next_counter_in;
		end
	end

	//--- Processing halt_req
	assign halt_req_mux_out = halt_req ? counter_in : counter_in + 1'b1;

	//--- Processing next_counter_in mux
	assign next_counter_in = rst_counter_in_mux_sel ? 8'h0 : halt_req_mux_out;

	//--- Processing rst_counter_in_mux_sel
//	assign rst_counter_in_mux_sel = (~timer_en) | rst_counter_in;
	assign rst_counter_in_mux_sel = rst_counter_in;
	
	/////////////
	// BLOCK 2 //
	/////////////
	
	//--- Declaring nets
	wire counter_en;
	wire counter_en_mux_sel;
	wire [7:0] val_overflow;

	rom ROM (
	.div_val(div_val),
	.val_overflow(val_overflow)
	);

	//--- Processing counter_en mux
	assign counter_en = counter_en_mux_sel ? halt_req ? 1'b0 : timer_en ? 1'b1 : 1'b0  : rst_counter_in;
	
	//--- Processing rst_counter_in
	assign rst_counter_in = counter_in == val_overflow;

	//--- Processing counter_en_mux_sel
	assign counter_en_mux_sel = (~div_en) | ((div_val == 4'b0000) & div_en);

	//////////////
	// BLOCK 3  //
	//////////////
	
	//--- Declaring nets
	wire [63:0] counter_plus;
	wire [31:0] next_counter_lsb;
	wire [31:0] next_counter_msb;


	//--- Declaring variables
	reg [31:0] counter_lsb;
	reg [31:0] counter_msb;

	
	

	//--- Processing counter
	always @(posedge clk or negedge rst_n or posedge timer_en_neg) begin
		if(~rst_n) begin
			counter_lsb <= 32'b0;
			counter_msb <= 32'b0;
		end else if(timer_en_neg) begin
			counter_lsb <= 32'b0;
			counter_msb <= 32'b0;
		end else begin
			counter_lsb <= next_counter_lsb;
			counter_msb <= next_counter_msb;
		end
	end
	
	//--- Processing counter plus one
	assign counter_plus = {counter_msb,counter_lsb} + 1'b1; 

	//--- Processing counter_lsb
	assign next_counter_lsb = tdr0_wr_en ? wr_data : counter_en ? counter_plus[31: 0] : counter_lsb;

	//--- Processing counter_msb
	assign next_counter_msb = tdr1_wr_en ? wr_data : counter_en ? counter_plus[63:32] : counter_msb;
	
	//--- Processing counter out
	assign counter = {counter_msb, counter_lsb};

endmodule
