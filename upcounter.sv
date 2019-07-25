/*
** This upcounter.sv module takes in a 4 bits input and also a 4 bits output.
** The input is a binary value of an integer from 0 to 25. It will output a binary 
** value of the integer that is after the original input integer.
*/

module upcounter(current,out);

input logic [3:0] current;
output logic [3:0] out;

assign out[0] = ~current[0];

assign out[1] = ~current[0]&current[1] | ~current[3]&~current[1]&current[0];

assign out[2] = current[2]&~current[1] | current[2]&~current[0] | ~current[2]&current[1]&current[0];

assign out[3] = ~current[0]&current[3] | current[2]&current[1]&current[0];

endmodule

/* Test bench module for upcounter.sv
*/
module upcounter_testbench();
logic [3:0]current;
logic [3:0] out;

upcounter dut(current, out);

integer i;
initial begin
for(i = 0; i < 2**4; i++) begin
	current[3:0] = i; #10;
end
end

endmodule 



