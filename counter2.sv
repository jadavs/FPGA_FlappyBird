/*
** This module has 4 inputs: Clock, Reset, inc and dec, and it has 6 outputs of HEX0, HEX1, HEX2, HEX3, HEX4, 
** HEX5. Once the Reset signal is on, it will start counting with an original integer value of 0. The inc input
** will let the system know to add 1 to the current value. The dec on the other hand will tell the system when to
** subtract 1 from the current value. This module uses the downcounter.sv when it gets 1 for the dec input and uses
** upcounter.sv when the inc input is 1. Since there are only 25 spots in the parking lot, the counter will count
** from 0 to 25. When there is no car in the parking lot, this module will output the displayed values for HEX5 as 
** C, HEX4 as L, HEX3 as E, HEX2 as A, HEX1 as R and HEX0 as 0. When the parking lot is full, it will output HEX5 as
** F, HEX4 as U, HEX3 and HEX2 as L, HEX1 and HEX0 will not be displayed in this case. Therefore, when the current 
** number of car in the parking is from 1 to 24, it will display HEX1 and HEX0 as the value of the current number. 
*/

module counter2(Clock, Reset, inc, HEX0, HEX1);

input logic Clock, Reset, inc;
output logic [6:0] HEX0, HEX1;
enum {Empty, Count} ps, ns;
// Current, upcount and downcount values of two integer that will be displayed on HEX
logic [3:0] current1, current0, upcount1, upcount0, downcount1, downcount0;

// Displayed values of HEx1 and HEX0 
logic [6:0] hexout1, hexout0;

// Check the inc and dec inputs to set the next state value
always_comb begin
	case(ps)
		//When there is no car in the parking lot
		Empty: if (inc == 1) begin
					ns = Count;
					HEX1 = hexout1;
					HEX0 = hexout0;
				end
				else begin
					ns = Empty;
					HEX1 = ~7'b0111111;
					HEX0 = ~7'b0111111;
				end
		
		
		// When the number of cars in the parking lot is from 1 to 24
		Count: begin
					ns = Count;
					HEX1 = hexout1;
					HEX0 = hexout0;
				end
		endcase
	end

// calculate the upcount value of the 1st integer
upcounter Up0(current0, upcount0);
// calculate the downcount value of the 1st integer
//downcounter Down0(current0, downcount0);

// calculate the upcount value of the 2nd integer
upcounter Up1(current1, upcount1);
// calculate the downcount value of the 2nd integer
//downcounter Down1(current1, downcount1);

// calculate the displayed value on HEX for the 1st integer
hex h0(current0, hexout0);
// calculate the displayed value on HEX for the 2nd integer
hex h1(current1, hexout1);

/* Check the current values of the two integers and 2 inputs inc and dec to 
** recalculate the current values
*/
always_ff @(posedge Clock) begin

	// Reset will set the two integers to 00 and set the present state back to the initial state
	if(Reset) begin
		current0 <= 4'b0000;
		current1 <= 4'b0000;
		ps <= Empty;

	end
	
	// When Reset is 0, recalculate the two integers and set present state to next state
	else begin
	
		/* When currents are 0 0: if inc = 1, always upcount the 1st current
		**								 if 1st current is 0 after upcount, upcount 2nd current
		**							 	 otherwise 2nd current will stay the same 
		*/
		ps <= ns;
			if(inc == 1) begin
				current0 <= upcount0;
				if (upcount0 == 4'b0000) current1 <= upcount1;
			end
	
		end
	end
	
endmodule

// Test bench module for counter.sv
module counter2_testbench();

logic Clock, Reset, inc, dec;
logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
logic [3:0] current1, current0, upcount1, upcount0, downcount1, downcount0;
logic [6:0] hexout1, hexout0;

counter2 dut(Clock, Reset, inc, dec, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);

parameter CLOCK_PERIOD = 100;
	initial begin
		Clock <= 0;
		forever #(CLOCK_PERIOD/2) Clock <= ~Clock;
	end

initial begin
										@(posedge Clock);
	Reset <= 1; 		  			@(posedge Clock);
	Reset <= 0; 				 	@(posedge Clock);
										@(posedge Clock);
	// Increment
	inc <= 1; dec <= 0;			@(posedge Clock);
										@(posedge Clock);
										@(posedge Clock);
										@(posedge Clock);
										@(posedge Clock);
										@(posedge Clock);
										@(posedge Clock);
										@(posedge Clock);
										@(posedge Clock);
										@(posedge Clock);
										@(posedge Clock);
										@(posedge Clock);
										@(posedge Clock);
										@(posedge Clock);
										@(posedge Clock);
										@(posedge Clock);
										@(posedge Clock);
										@(posedge Clock);
										@(posedge Clock);
										@(posedge Clock);
										@(posedge Clock);
										@(posedge Clock);
										@(posedge Clock);
										@(posedge Clock);
	inc <= 0;						@(posedge Clock);
										@(posedge Clock);
	Reset <= 1; 		  			@(posedge Clock);
	Reset <= 0; 				 	@(posedge Clock);
										@(posedge Clock);
	//Decrement
	inc <= 0; dec <= 1;			@(posedge Clock);
										@(posedge Clock);
	//Increment
	inc <= 1; dec <= 0;			@(posedge Clock);
										@(posedge Clock);
										@(posedge Clock);
										@(posedge Clock);
										@(posedge Clock);
										@(posedge Clock);
										@(posedge Clock);
										@(posedge Clock);
	//Decrement
	inc <= 0; dec <= 1;			@(posedge Clock);
										@(posedge Clock);
										@(posedge Clock);
										@(posedge Clock);
										@(posedge Clock);
										@(posedge Clock);
										@(posedge Clock);
										@(posedge Clock);
										@(posedge Clock);
										@(posedge Clock);
										@(posedge Clock);
										@(posedge Clock);
$stop;
	end
endmodule
	
