/*
*	Author: Dr. Hansen
*	Date: Feb. 14, 2017
*	Description: implements a negative-edge D-flipflop.
*		On the negative edge of CLKb, Q := D.  
*		Asynchronous, negative-edge reset
*
*	Inputs:	
*		D - D input
*		CLKb - negative edge clock input
*		RSTb - asynchronous, negative edge reset
*
*	Outputs:
*		Q - outputs D on negedge-edge of clk
*		Qb - outputs D' on negedge-edge of clk
*
*	History:
*		Feb. 8, 2019 - update to SV
*		Feb. 21, 2020 - added asynchronous reset
*/

module D_FF_neg(
	input logic D,CLKb,RSTb,
	output logic Q,Qb
);

	always_ff@(negedge CLKb, negedge RSTb)
	begin
	if(RSTb == 1'b0)
		begin
			Q <= 1'b0;
			Qb <= 1'b1;
		end
	else
		begin
			Q <= D;
			Qb <= ~D;
		end
	end

endmodule
