`include "def.h"

module top(clk, rst_n, in, valid_in, last_in, out, valid_out, last_out, ready);
	input wire clk, rst_n;
	input wire [`DATA_W-1:0] in;
	input wire valid_in, last_in;
	output wire [`DATA_W-1:0] out;
	output wire valid_out, last_out;
	output wire ready;

	wire [`DATA_W-1:0] out0, out1, out2, out3;
	wire valid_out0, valid_out1, valid_out2, valid_out3;
	wire last_out0, last_out1, last_out2, last_out3;

two tw0(.clk(clk), .rst_n(rst_n), .in(in), .valid_in(valid_in), .last_in(last_in), .out(out0), .valid_out(valid_out0), .last_out(last_out0), .ready(ready));
four f0(.clk(clk), .rst_n(rst_n), .in(out0), .valid_in(valid_out0), .last_in(last_out0), .out(out1), .valid_out(valid_out1), .last_out(last_out1));
eight e0(.clk(clk), .rst_n(rst_n), .in(out1), .valid_in(valid_out1), .last_in(last_out1), .out(out2), .valid_out(valid_out2), .last_out(last_out2));
steen s0(.clk(clk), .rst_n(rst_n), .in(out2), .valid_in(valid_out2), .last_in(last_out2), .out(out3), .valid_out(valid_out3), .last_out(last_out3));
thtwo t0(.clk(clk), .rst_n(rst_n), .in(out3), .valid_in(valid_out3), .last_in(last_out3), .out(out), .valid_out(valid_out), .last_out(last_out));

endmodule
