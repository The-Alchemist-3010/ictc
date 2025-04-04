module REGISTER (
	input wire clk            ,
	input wire rst_n          ,
	input wire [11:0] addr    ,
	input wire [31:0] wr_data ,
	input wire wr_en          ,
	input wire rd_en          ,
	input wire [63:0] counter ,
	input wire dbg_mode       ,
	output reg [31:0] rd_data,
	output wire interrupt     ,
	output wire div_en        ,
	output wire [3:0] div_val ,
	output wire halt_req      ,
	output wire timer_en      ,
	output wire tdr0_wr_en    ,
	output wire tdr1_wr_en    ,
	output wire [31:0] wr_count
);
	//--- Declaring some nets
	wire [31:0] rd_data_tcr;
	wire [31:0] rd_data_tdr0;
	wire [31:0] rd_data_tdr1;
	wire [31:0] rd_data_tcmp0;
	wire [31:0] rd_data_tcmp1;
	wire [31:0] rd_data_tier;
	wire [31:0] rd_data_tisr;
	wire [31:0] rd_data_thcsr; 
	wire        cmp;
	
	//--- Procesing signal to counter
	assign div_val  = rd_data_tcr[11:8];
	assign div_en   = rd_data_tcr[1];
	assign halt_req = rd_data_thcsr[1];
	assign timer_en = rd_data_tcr[0];
	
	//--- Processing data out
	always @(*) begin
		if(rd_en) begin
			case(addr)
				12'h00:
					rd_data = rd_data_tcr;
				12'h04:
					rd_data = rd_data_tdr0;
				12'h08:
					rd_data = rd_data_tdr1;
				12'h0c:
					rd_data = rd_data_tcmp0;
				12'h10:
					rd_data = rd_data_tcmp1;
				12'h14:
					rd_data = rd_data_tier;
				12'h18:
					rd_data = rd_data_tisr;
				12'h1c:
					rd_data = rd_data_thcsr;
				default:
					rd_data = 32'h0;
			endcase
		end else begin
			rd_data = 32'h0;
		end
	end 
	
	//--- Processing cmp
	assign cmp = ({rd_data_tdr1,rd_data_tdr0} == counter);
	

	TCR_REG M_TCR_REG (           //--- DONE DATE: 1/4/2025
		.clk     (clk     ),
		.rst_n   (rst_n),
		.addr    (addr),
		.wr_data (wr_data),
		.wr_en   (wr_en),
		.rd_data (rd_data_tcr)
	);
	
	THCSR_REG M_THCSR_REG (     //--- DONE DATE: 1/4/2025
		.clk(clk),
		.rst_n(rst_n),
		.addr(addr),
		.wr_data(wr_data),
		.rd_data(rd_data_thcsr),
		.wr_en(wr_en),
		.dbg_mode(dbg_mode)
	);
	
	TISR_REG M_TISR_REG (     //--- DONE DATE: 1/4/2025
		.clk(clk),
		.rst_n(rst_n),
		.addr(addr),
		.wr_data(wr_data),
		.rd_data(rd_data_tisr),
		.wr_en(wr_en),
		.cmp(cmp),
		.int_en(rd_data_tier[0])
	);
	
	TIER_REG M_TIER_REG (    //DONE DATA: 1/4/2025
		.clk(clk),
		.rst_n(rst_n),
		.addr(addr),
		.wr_data(wr_data),
		.wr_en(wr_en),
		.rd_data(rd_data_tier)
	);
	
	TCMP0_REG M_TCMP0_REG (   //DONE DATA: 1/4/2025
		.clk(clk),
		.rst_n(rst_n),
		.addr(addr),
		.wr_data(wr_data),
		.wr_en(wr_en),
		.rd_data(rd_data_tcmp0)
	);
	
	TCMP1_REG M_TCMP1_REG (   //DONE DATA: 1/4/2025
		.clk(clk),
		.rst_n(rst_n),
		.addr(addr),
		.wr_data(wr_data),
		.wr_en(wr_en),
		.rd_data(rd_data_tcmp1) 
	
	);
	
	TDR0_REG M_TDR0_REG (   //--- DONE DATE: 1/4/2025
		.wr_en(wr_en),
		.addr(addr),
		.wr_data(wr_data),
		.lsb_count(counter[31:0]),
		.rd_data(rd_data_tdr0),
		.wr_count(wr_count),
		.tdr0_wr_en(tdr0_wr_en)
	);
	
	TDR1_REG M_TDR1_REG (    //--- DONE DATA: 1/4/2025
		.wr_en(wr_en),
		.addr(addr),
		.wr_data(wr_data),
		.msb_count(counter[64:32]),
		.rd_data(rd_data_tdr1),
		.wr_count(wr_count),
		.tdr1_wr_en(tdr1_wr_en)
	);
	
	

endmodule
