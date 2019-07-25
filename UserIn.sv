// This module is also borrowed from ECE 271 and makes sure that when a button is pressed
// it is only active for one clock cycle
module UserIn(clk, in, out, reset);

	input logic clk, in, reset;
	output logic out;
	parameter on = 1'b1, off = 1'b0;
	logic ns, ps;
	logic prevIn;
	
	// Next State logic
	 always_comb begin
		 case (ps)
		 on: ns = off;			  
		 off: if(in == on & prevIn != on) ns = on;
				else ns = off;
		 default: ns = off;
		 endcase
	 end
	 
	 assign out = ns;
	
	// DFFs
	 always_ff @(posedge clk) begin
		if (reset) begin
			prevIn <= off;
			ps <= off;
		end
		
		else begin
			ps <= ns;
			prevIn <= in;
		end
		
	 end

endmodule 

// testbench for the user_in module
module UserIn_testbench();
	logic clk, reset, in;
	logic out;
	
	UserIn dut (clk, in, out, reset);
	
	// Set up the clock.
	 parameter CLOCK_PERIOD=100;
	 initial begin
	 clk <= 0;
	 forever #(CLOCK_PERIOD/2) clk <= ~clk;
	 end 

	// Set up the inputs to the design. Each line is a clock cycle.
	 initial begin
	 @(posedge clk);
	 reset <= 1; @(posedge clk);
	 reset <= 0; in <= 0; @(posedge clk);
	 @(posedge clk);
	 @(posedge clk);
	 @(posedge clk);
	 in <= 1; @(posedge clk);
	 in <= 0; @(posedge clk);
	 @(posedge clk);
	 @(posedge clk);
	 @(posedge clk);
	 in <= 1; @(posedge clk);
	 @(posedge clk);
	 in <= 0; @(posedge clk);
	 in <= 1; @(posedge clk);
	 @(posedge clk);
	 @(posedge clk);
	 $stop; // End the simulation.
	 end

endmodule 