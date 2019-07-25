// implements a LSFR as done in ECE 271 to produce a random number whenever 
// enable signal is set to high
module LSFR(clk, reset, randNum, en);
	input logic clk, reset;
	output logic [9:0] randNum;
	logic res;
	input logic en;
	initial randNum = 10'b0000000000;
	
	always @(posedge clk) begin
		if(reset) 
			randNum <= 10'b0000000000;		
		else if(en)
			randNum <= {randNum[8:0], (randNum[6] ~^ randNum[9])};	
		else 
			randNum <= randNum;
	end
	
endmodule 

// testbench for LSFR module
module LSFR_testbench();
	logic clk, reset;
	logic [9:0] randNum;
	
	LSFR dut(.clk, .reset, .randNum);
	
	// Set up the clock.
	parameter CLOCK_PERIOD=100;
	initial begin
	clk <= 0;
	forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	
	initial begin
		reset <= 1; @(posedge clk);
		reset <= 0; @(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		$stop; // End the simulation.
	end
	

endmodule 	