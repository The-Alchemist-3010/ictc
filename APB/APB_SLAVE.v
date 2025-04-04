module APB_SLAVE ( // Mình thay đổi 1 tí nhé, tao muốn thay đổi tiếp ở dưới máy tính //
	input wire clk,
	input wire rst_n,
	input wire psel,
	input wire penable,
	input wire pwrite,
	input wire [ 3:0] pstrb,
	input wire [31:0] apb_wr_data,
	output wire [31:0] reg_wr_data,
	output reg pready,
	output wire wr_en,
	output wire rd_en
);
	
	//--- Declaring state of FSM
	localparam IDLE     = 2'b00;
	localparam SETUP    = 2'b01;
	localparam ACCESS   = 2'b10;

	//--- Declaring variables
	reg [31:0] data_strb ;
	reg [ 1:0] p_state   ;
	reg [ 1:0] n_state   ;
	reg [ 1:0] p_state_ff;
	
	//--- Procesisng Present State FLIPFLOP
	always @(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			p_state_ff <= IDLE;
		end else begin
			p_state_ff <= p_state;
		end
	end
	
	//--- Processing PREADY AND WRITE INTO REGISTER
	always @(*) begin
		pready = (p_state_ff == SETUP) && (p_state == ACCESS);
	end
	
	assign wr_en = pready &&  pwrite;
	assign rd_en = pready && ~pwrite;
	
	//--- Processing Changing State
	always @(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			p_state <= IDLE    ;
		end else begin
			p_state <= n_state ;
		end
	end
	
	//--- Processing next state
	always @(*) begin
		case(p_state)
			IDLE: begin
				if(psel) begin
					n_state = SETUP;
				end else begin
					n_state = IDLE;
				end
			end
			SETUP: begin
				if(psel && penable) begin
					n_state = ACCESS;
				end else begin
					n_state = SETUP;
				end
			end
			ACCESS: begin
				if(psel && penable) begin
					n_state = ACCESS;
				end else if (psel && ~penable) begin
					n_state = SETUP;
				end else if (~psel && ~penable) begin
					n_state = IDLE;
				end else begin
					n_state = IDLE;
				end
			end
			default:
				n_state = IDLE;
		endcase
	end
	
	//--- Procesisng data_strb
	assign reg_wr_data = apb_wr_data & { {8{pstrb[3]}}, {8{pstrb[2]}}, {8{pstrb[1]}}, {8{pstrb[0]}} };
	
endmodule
