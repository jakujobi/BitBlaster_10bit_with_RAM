/*
Author: Dr. Hansen
Date: Feb. 9, 2022
Description: takes a 1-bit noisy input and outputs a 1-bit clean signal

Inputs:
	A_noisy - signal to be debounced
	CLK50M  - 50 MHz clock from the DE10 board (PIN_P11)
	
Outputs:
	A	     - debounced signal to be used in your circuit
*/


module debouncer(
	input logic A_noisy,
	input logic CLK50M, 
	output logic A
);

	logic [15:0] COUNT;
	parameter [15:0] COMPARE = 50_000; //1 millisecond
	
	logic t_d, t_r, Anext;
	
	/*
	1 ms timer
	*/
	always_ff@(posedge CLK50M)
	begin
		if(t_r)
			COUNT <= 16'd0;
		else
			COUNT <= COUNT + 16'd1;
	end
	assign t_d = (COUNT >= COMPARE);
	
	//next-state logic 
	assign Anext = (A_noisy & t_d) | (A & ~t_d);
	
	//state
	always_ff@(posedge CLK50M)
		A <= Anext;
	
	//output logic 
	assign t_r = t_d | (~A & ~A_noisy) | (A & A_noisy);
	
endmodule
