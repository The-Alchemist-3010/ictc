module TIMER_TOP (
	input wire        sys_clk,
	input wire        sys_rst_n,
	input wire        tim_psel,
	input wire        tim_write,
	input wire        tim_penable,
	input wire [11:0] tim_paddr,
	input wire [31:0] tim_pwdata,
	output wire [31:0] tim_prdata,
	input  wire [3:0] tim_pstrb,
	output wire tim_pready,
//	output wire tim_pslverr,
	output wire tim_int,
	input wire dbg_mode 
);
	//--- Declaring nets for connection
	wire [31:0] reg_wr_data; 
	wire        wr_en, rd_en;
	wire div_en;
	wire [3:0] div_val;
	wire timer_en;
	wire tdr0_wr_en;
	wire tdr1_wr_en;
	wire [31:0] wr_count;
	wire [63:0] counter;
	wire halt_req;

	APB_SLAVE M_APB_SLAVE (
		.clk(sys_clk),
		.rst_n(sys_rst_n),
		.psel(tim_psel),
		.penable(tim_penable),
		.pwrite(tim_write),
		.pstrb(tim_pstrb),
		.apb_wr_data(tim_pwdata),
		.reg_wr_data(reg_wr_data),
		.pready(tim_pready),
		.wr_en(wr_en),
		.rd_en(rd_en)
	);
	
	REGISTER M_REGISTER (
		.clk     (sys_clk)     ,
		.rst_n   (sys_rst_n)   ,
		.addr    (tim_paddr)   ,
		.wr_data (reg_wr_data) ,
		.wr_en   (wr_en),
		.rd_en   (rd_en),
		.counter (counter),
		.dbg_mode (dbg_mode)    ,
		.rd_data (tim_prdata),
		.interrupt   (tim_int)  ,
		.div_en      (div_en)  ,
		.div_val (div_val),
		.halt_req   (halt_req)   ,
		.timer_en    (timer_en)  ,
		.tdr0_wr_en    (tdr0_wr_en),
		.tdr1_wr_en    (tdr1_wr_en),
		.wr_count	(wr_count)
	);
	
	COUNTER M_COUNTER (
		.clk  (sys_clk)	          ,
		.rst_n       (sys_rst_n)   ,
		.div_val  (div_val),  //--- Control
		.div_en      (div_en)   ,	 //--- Control
		.halt_req     (halt_req)  ,  //--- Control
		.timer_en      (timer_en) ,  //--- Control
		.wr_data (wr_count),
		.tdr1_wr_en     (tdr1_wr_en),
		.tdr0_wr_en   (tdr0_wr_en)  ,
		.counter(counter)
	);



endmodule
