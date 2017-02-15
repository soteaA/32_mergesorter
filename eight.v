/*
*	The version : 1.0.0
*	The Creator : Einsamer-Wolf
*	Affiliation : Westlab
*
*	This set of codes is a template with which you could meet the conditions of AXI Stream protocol(s)
*	Any discription of it might be wrong
*	Nonetheless, I won't take any responsibility for it
*	So it's all your responsibility
*	Be wise, Use it well, mate!!
*
*	written on the 24th of Feb.
*
*** UPDATE REPORT ***
*	TIME : CHANGE : IMPORTANCE(5bit expression : a 11111 is the most and a 00000 least)
*	2016/02/24 15:51 : just created the template codes for AXI Stream protocol(s) : 00001
*
*/
`include "def.h"

module eight(clk, rst_n, in, valid_in, last_in, out, valid_out, last_out);
	input wire clk, rst_n;
	input wire [`DATA_W-1:0] in;
	input wire valid_in, last_in;
	output reg [`DATA_W-1:0] out;
	output reg valid_out, last_out;

/*
*	if you need some FIFOs or regfiles or anything, then add them down here
*/
	reg [`DATA_W-1:0] fifo [`E_DEPTH_W-1:0];
	reg [`E_H_PTR-1:0] head;
	reg [`E_T_PTR-1:0] tail0, tail1;

/*
*	FINITE STATE MACHINE DEFINITION down here
*/
parameter [2:0] S0 = 3'b001, S1 = 3'b010, S2 = 3'b011, S3 = 3'b100, S4 = 3'b101;
	reg [2:0] state;

/*
*	any other wire or register discriptions down here
*/
	reg delay_last;

	wire we;	//write enable for FIFO
	wire S0_enable, S1_enable, S2_enable, S3_enable, S4_enable;
	wire S0toS1;
	wire S1toS2, S1toS3;
	wire S2toS3, S2toS4;
	wire S3toS1, S3toS0;
	wire S4toS1, S4toS0;

	wire [`DATA_W-1:0] mem0, mem1, mem2, mem3, mem4, mem5, mem6, mem7;

/*
*	FINITE STATE MACHINE DISCRIPTION
*/
always @(posedge clk) begin
	if (!rst_n) begin
		state <= S0;
	end else begin
		case (state)
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
			end else if (S1toS3) begin
				state <= S3;
			end else begin
				state <= S1;
			end
		end

		S2 : begin
			if (S2toS3) begin
				state <= S3;
			end else if (S2toS4) begin
				state <= S4;
			end else begin
				state <= S2;
			end
		end

		S3 : begin
			if (S3toS1) begin
				state <= S1;
			end else if (S3toS0) begin
				state <= S0;
			end else begin
				state <= S3;
			end
		end

		S4 : begin
			if (S4toS1) begin
				state <= S1;
			end else if (S4toS0) begin
				state <= S0;
			end else begin
				state <= S4;
			end
		end

		endcase
	end
end

always @(posedge clk) begin
	if (!rst_n) begin
		head <= 0;
		tail0 <= 0;
		tail1 <= 0;
	end else begin
		if (S0_enable) begin
			fifo[head] <= in;
			head <= head + 1;
		end

		else if (S1_enable) begin
			fifo[head] <= (in > fifo[tail0]) ? fifo[tail0] : in;
			out <= (in > fifo[tail0]) ? in : fifo[tail0];
			valid_out <= 1;
			last_out <= 0;
			head <= head + 1;
			tail0 <= (in > fifo[tail0]) ? tail0 : tail0 + 1;
			tail1 <= (in > fifo[tail0]) ? tail1 + 1 : tail1;
		end

		else if (S2_enable) begin
			fifo[head] <= in;
			out <= (fifo[tail1+4] > fifo[tail0]) ? fifo[tail1+4] : fifo[tail0];
			valid_out <= 1;
			last_out <= 0;
			head <= (we) ? head + 1 : head;
			tail0 <= (fifo[tail1+4] > fifo[tail0]) ? tail0 : tail0 + 1;
			tail1 <= (fifo[tail1+4] > fifo[tail0]) ? tail1 + 1 : tail1;
		end

		else if (S3_enable) begin
			fifo[head] <= in;
			out <= fifo[tail0];
			valid_out <= 1;
			last_out <= (S3toS0) ? 1 : 0;
			head <= (we && !delay_last) ? head + 1 : head;
			tail0 <= tail0 + 1;
		end

		else if (S4_enable) begin
			fifo[head] <= in;
			out <= fifo[tail1+4];
			valid_out <= 1;
			last_out <= (S4toS0) ? 1 : 0;
			head <= (we && !delay_last) ? head + 1 : head;
			tail1 <= tail1 + 1;
		end

		else begin
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
		end else if (S3toS0 || S4toS0) begin
			delay_last <= 0;
		end else begin
			delay_last <= delay_last;
		end
	end
end

assign we = valid_in;

assign S0_enable = we & (state == S0);
assign S1_enable = (state == S1);
assign S2_enable = (state == S2);
assign S3_enable = (state == S3);
assign S4_enable = (state == S4);

assign S0toS1 = (state == S0) & (head == 3);
assign S1toS2 = (state == S1) & !(in > fifo[tail0]);
assign S1toS3 = (state == S1) & (in > fifo[tail0]) & (tail1 == 3);
assign S2toS3 = (state == S2) & (fifo[tail1+4] > fifo[tail0]) & (tail1 == 3);
assign S2toS4 = (state == S2) & !(fifo[tail1+4] > fifo[tail0]) & (tail0 == 3);
assign S3toS1 = (state == S3) & (tail0 == 3) & !delay_last;
assign S3toS0 = (state == S3) & (tail0 == 3) & delay_last;
assign S4toS1 = (state == S4) & (tail1 == 3) & !delay_last;
assign S4toS0 = (state == S4) & (tail1 == 3) & delay_last;

assign mem0 = fifo[0];
assign mem1 = fifo[1];
assign mem2 = fifo[2];
assign mem3 = fifo[3];
assign mem4 = fifo[4];
assign mem5 = fifo[5];
assign mem6 = fifo[6];
assign mem7 = fifo[7];

endmodule
