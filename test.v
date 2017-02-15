`include "def.h"

module test;
	reg clk, rst_n;
	reg [`DATA_W-1:0] in;
	reg valid_in, last_in;
	wire [`DATA_W-1:0] out;
	wire valid_out, last_out;
	wire ready;

parameter STEP = 10;

always #(STEP/2) clk =~ clk;

top top0(clk, rst_n, in, valid_in, last_in, out, valid_out, last_out, ready);

initial begin
	$dumpfile("test.vcd");
	$dumpvars(0, top0);
	$dumplimit(100000);

	clk = 0;
	rst_n = 0;
#STEP
	rst_n = 1;
	valid_in = 1;
	last_in = 0;
#STEP
#(STEP/2)
	in = 36;
#STEP
	in = 44;
#STEP
	in = 56;
#STEP
	in = 49;
#STEP
	in = 26;
#STEP
	in = 127;
#STEP
	in = 11;
#STEP
	in = 38;
#STEP
	in = 90;
#STEP
	in = 46;
#STEP
	in = 59;
#STEP
	in = 27;
#STEP
	in = 4;
#STEP
	in = 125;
#STEP
	in = 61;
#STEP
	in = 62;
#STEP
	in = 73;
#STEP
	in = 123;
#STEP
	in = 143;
#STEP
	in = 117;
#STEP
	in = 95;
#STEP
	in = 32;
#STEP
	in = 39;
#STEP
	in = 47;
#STEP
	in = 99;
#STEP
	in = 74;
#STEP
	in = 65;
#STEP
	in = 14;
#STEP
	in = 151;
#STEP
	in = 122;
#STEP
	in = 155;
#STEP
	in = 161;
	last_in = 1;
#STEP
	in = 33;
	valid_in = 0;
	last_in = 0;
#(STEP * 100)
$finish;

end

endmodule
