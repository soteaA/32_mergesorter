/*
*	The version : 1.0.1
*	The Creator : Einsamer-Wolf
*	Affiliation : Westlab
*
*	This set of codes is a template with which you could meet the conditions of AXI Stream protocol(s)
*	Any discription of it might be wrong
*	Nonetheless, I won't take any responsibility for it
*	So it's all your responsibility
*	Be wise, Use it well, mate!!
*
*	first written on the 24th of Feb.
*
*** UPDATE REPORT ***
*	TIME : CHANGE : IMPORTANCE(5bit expression : a 11111 is the most and a 00000 least)
*	2016/02/24 15:51 : just created the template codes for AXI Stream protocol(s) : 00001
*	2016/02/25 00:50 : added the FSM definition & discription, buffer def, and wire & reg def & discription
*
*/
`include "def.h"

module two(clk, rst_n, in, valid_in, last_in, out, valid_out, last_out, ready);
	input wire clk, rst_n;
	input wire [`DATA_W-1:0] in;
	input wire valid_in, last_in;
	output reg [`DATA_W-1:0] out;
	output reg valid_out, last_out;
	output wire ready;

/*
*	if you need some FIFOs or regfiles or anything, then add them down here
*/
	reg [`DATA_W-1:0] buff;

/*
*	FINITE STATE MACHINE DEFINITION down here
*/
parameter [1:0] IDLE = 2'b00, S0 = 2'b01, S1 = 2'b10, S2 = 2'b11;
	reg [1:0] state;

/*
*	any wire discriptions down here
*/
	reg delay_last;

	wire we;
	wire S0_enable;
	wire S1_enable;
	wire S2_enable;

	wire S0toS1;
	wire S1toS2;
	wire S2toS1, S2toIDLE;

/*
*	FSM discription down here
*/
always @(posedge clk) begin
	if (!rst_n) begin
		state <= IDLE;
	end else begin
		case (state)
		IDLE : begin
			if (valid_in) begin
				state <= S0;
			end else begin
				state <= IDLE;
			end
		end

		S0 : begin
			if (S0toS1) begin
				state <= S1;
			end else begin
				state <= S0;
			end
		end

		S1 : begin
			if (S1toS2) begin
				state <= S2;
			end else begin
				state <= S1;
			end
		end

		S2 : begin
			if (S2toIDLE) begin
				state <= IDLE;
			end else if (S2toS1) begin
				state <= S1;
			end else begin
				state <= S2;
			end
		end

		endcase
	end
end

/*
*	User programs should be added down here
*/
always @(posedge clk) begin
	if (!rst_n) begin
		buff <= 0;
	end else begin
		if (S0_enable) begin
			buff <= in;
			valid_out <= 0;
			last_out <= 0;
		end else if (S1_enable) begin
			out <= (in > buff) ? in : buff;
			valid_out <= 1;
			last_out <= 0;
			buff <= (in > buff) ? buff : in;
		end else if (S2_enable) begin
			out <= buff;
			valid_out <= 1;
			last_out <= (S2toIDLE) ? 1 : 0;
			buff <= (we) ? in : buff;
		end else begin
			valid_out <= 0;
			last_out <= 0;
		end
	end
end

always @(posedge clk) begin
	if (!rst_n) begin
		delay_last <= 0;
	end else begin
		if (last_in) begin
			delay_last <= 1;
		end else if (S2toIDLE) begin
			delay_last <= 0;
		end else begin
			delay_last <= 0;
		end
	end
end

/*
*	any wire dicription down here
*/
assign ready = (state != IDLE) & valid_in;
assign we = ready;

assign S0_enable = (state == S0) & we;
assign S1_enable = (state == S1) & we;
assign S2_enable = (state == S2);

assign S0toS1 = (state == S0) & we;
assign S1toS2 = (state == S1) & we;
assign S2toS1 = (state == S2) & we & !delay_last;
assign S2toIDLE = (state == S2) & delay_last;

endmodule
