/*
** This module has 4 bits input and 7 bits output. The input is a binary value of an integer number from 0 to 25
** (the maximum number of cars in the parking lot). The output is a displayed value of HEX on the FPGA board. This 
** module takes in an integer value and outputs a corresponding display value on a HEX. 
*/

module hex(current, out);

input logic [3:0] current;
output logic [6:0] out;

// Set the display value of HEX according to the binary value 
always_comb begin
	//0
	if(current == 4'b0000) out = ~7'b0111111;
	//1
	else if (current == 4'b0001) out = ~7'b0000110;
	//2 
	else if (current  == 4'b0010) out = ~7'b1011011;
	//3
	else if (current  == 4'b0011) out = ~7'b1001111;
	//4
	else if (current  == 4'b0100) out = ~7'b1100110;
	//5 
	else if (current  == 4'b0101) out = ~7'b1101101;
	//6
	else if (current  == 4'b0110) out = ~7'b1111101;
	//7
	else if (current  == 4'b0111) out = ~7'b0000111;
	//8 
	else if (current  == 4'b1000) out = ~7'b1111111;
	//9
	else if (current  == 4'b1001) out = ~7'b1100111;
	else out = 7'bX;					
	end 

endmodule

// Test bench module for hex.sv
module hex_testbench();
logic [3:0] current;
logic [6:0] out;

hex dut(current, out);

integer i;
initial begin
	for(i = 0; i<2**4; i++) begin
		current[3:0] = i; #10;
	end
end

endmodule 



