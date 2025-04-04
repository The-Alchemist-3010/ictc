module TCR_REG (
	input wire  clk             ,
	input wire  rst_n           ,
	input wire  wr_en           ,
	input wire  [11:0] addr     ,
	input wire  [31:0] wr_data  ,
	output wire [31:0] rd_data  ,
	output wire        p_error  
);
	//--- Declaring localparemeter
	localparam TCR_ADDR = 12'h0;
	
	//--- Declaring variables
	reg       timer_en ;
	reg       div_en   ;
	reg [3:0] div_val  ;

	//--- Declaring nets
	wire       less_9           ;
	wire       addr_en          ;
	wire       timer_en_mux_sel ;
	wire       div_en_mux_sel   ;
	wire       div_val_mux_sel  ;
	wire       next_timer_en    ;
	wire       next_div_en      ;
	wire [3:0] next_div_val     ;
	wire       more_9_error     ;
	wire       write_error      ;

	//--- Procesing timer_en reg
	always @(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			timer_en <= 1'b0;
		end else if (p_error) begin
			timer_en <= timer_en;
		end else begin
			timer_en <= next_timer_en;
		end
	end

	//--- Processing div_en reg
	always @(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			div_en <= 1'b0;
		end else if (p_error) begin
			div_en <= div_en;
		end else begin
			div_en <= next_div_en;
		end
	end

	//--- Processing div_val reg
	always @(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			div_val <= 4'b0001;
		end else if (p_error) begin
			div_val <= div_val;
		end else begin
			div_val <= next_div_val;
		end
	end
	
	//--- Processing p_error
	assign p_error = write_error || more_9_error;
	
	//--- Processing write_error
	assign write_error = timer_en_mux_sel && (wr_data[0] || timer_en) && ({wr_data[11:8],wr_data[1]} != {div_val,div_en});
	
	//--- Processing more_9_error
	assign more_9_error = ~less_9 && div_en_mux_sel; 
	
	//--- Processing mux timer_en
	assign next_timer_en = timer_en_mux_sel ? wr_data[0] : timer_en;                  //-------------  ASK TEACHER ----------//

	//--- Processing mux div_en
	assign next_div_en = div_en_mux_sel ? wr_data[1] : div_en;

	//--- Processing mux div_val
	assign next_div_val = div_val_mux_sel ? wr_data[11:8] : div_val;

	//--- Processing div_val_mux_sel
	assign div_val_mux_sel = less_9 & div_en_mux_sel;

	//--- Processing div_en_mux_sel
	assign div_en_mux_sel = (~(wr_data[0] || timer_en)) && timer_en_mux_sel;

	//--- Processing timer_en_mux_sel
	assign timer_en_mux_sel = addr_en & wr_en;

	//--- Processing correct addr
	assign addr_en = (addr == TCR_ADDR);
	
	//--- Processing less than 9
	assign less_9 = (~(|wr_data[10:8])) | (~wr_data[11]);

	//--- Processing output data of TCR register
	assign rd_data = {20'h0,div_val,6'b0,div_en,timer_en};
	
endmodule
