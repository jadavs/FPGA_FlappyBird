/* ROM Maker
 * Uses a textfile to read pixel data of sprites into a ROM
 */

module ram
(
		input logic Clk,
		output logic [23:0] data_Out,
		input logic en,
		output logic [23:0] mem [0:1408],
		output logic [23:0] startROM [0:10599],
		output logic [23:0] namesROM[0:4799],
		output logic [23:0] gameoverROM[0:5664]
		
);


initial
	begin
		 $readmemh("bird.txt", mem); // reads bird sprite
		 $readmemh("flappybird.txt", startROM); // reads title sprite
		 $readmemh("start.txt", namesROM); // reads names sprite
		 $readmemh("gameover.txt", gameoverROM); // reads game over sprite
	end	

endmodule 