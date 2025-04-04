module rom (
	input  wire [3:0] div_val,
	output reg [7:0] val_overflow
);
	always @(*) begin
		case(div_val) 
			4'b0001:
				val_overflow = 8'b1        ;
			4'b0010:
				val_overflow = 8'b11       ;
			4'b0011:
				val_overflow = 8'b111      ;
			4'b0100:
				val_overflow = 8'b1111     ;
			4'b0101:
				val_overflow = 8'b1_1111   ;
			4'b0110:
				val_overflow = 8'b11_1111  ;
			4'b0111:
				val_overflow = 8'b111_1111 ;
			4'b1000:
				val_overflow = 8'b1111_1111;
			default:
				val_overflow = 8'b0;
		endcase
	end
endmodule 
