// main module that connects together all the audio,video and mouse drivers to all the other segments
module DE1_SoC (HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW,
					 CLOCK_50, VGA_R, VGA_G, VGA_B, VGA_BLANK_N, VGA_CLK, VGA_HS, VGA_SYNC_N, VGA_VS, PS2_CLK, PS2_DAT,
					 CLOCK2_50, FPGA_I2C_SCLK, FPGA_I2C_SDAT, AUD_XCK, AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK, AUD_ADCDAT, AUD_DACDAT);
	// input, output port declarations
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output logic [9:0] LEDR;
	input logic [3:0] KEY;
	input logic [9:0] SW;

	input CLOCK_50, CLOCK2_50;
	output [7:0] VGA_R;
	output [7:0] VGA_G;
	output [7:0] VGA_B;
	output VGA_BLANK_N;
	output VGA_CLK;
	output VGA_HS;
	output VGA_SYNC_N;
	output VGA_VS;
	// I2C Audio/Video config interface
	output FPGA_I2C_SCLK;
	inout FPGA_I2C_SDAT;
	// Audio CODEC
	output AUD_XCK;
	input AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK;
	input AUD_ADCDAT;
	output AUD_DACDAT;
	
	// Local wires.
	logic read_ready, write_ready, read, write;
	logic [23:0] readdata_left, readdata_right;
	logic [23:0] writedata_left, writedata_right;
	//logic reset = ~KEY[0];
	logic record;
	assign record = ~KEY[3] | button_left;	
	assign LEDR[9] = button_left;
	
	// audio driver connections
	assign writedata_left = write_ready && record? readdata_left : 0;
	assign writedata_right = write_ready && record? readdata_right : 0;
	assign read = read_ready && write_ready;
	assign write = read_ready && write_ready;
	
	// color mapper connections
	logic reset, inc;
	logic [9:0] randNum, randNum2;
	logic [9:0] x;
	logic [8:0] y;
	logic [7:0] r, g, b;
	
	// mouse connections
	inout PS2_CLK;
	inout PS2_DAT;
	logic button_left, button_right, button_middle, start_mouse; 
	
	assign reset = ~KEY[0];
	//assign start_game = ~KEY[1];
	assign bird_up =  (button_left) | (~KEY[3]); // CHANGE THIS
	
	video_driver #(.WIDTH(640), .HEIGHT(480))
		v1 (.CLOCK_50, .reset, .x, .y, .r, .g, .b,
			 .VGA_R, .VGA_G, .VGA_B, .VGA_BLANK_N,
			 .VGA_CLK, .VGA_HS, .VGA_SYNC_N, .VGA_VS);
			 
	color_mapper draw (.clk(CLOCK_50), .reset(reset), .x, .y, .groundX(0), .groundY(400), .red(r), .green(g), .blue(b), .birdROM(mem), 
					.birdOn, .start_game, .bird_up, .obsOn, .randNum, .en, .randNum2, .en2, .startROM, .namesROM, .gameoverROM, .inc);
					
	UserIn u1 (clock[whichClock], ~KEY[1], start_game, reset);
	
	logic [31:0] clock;
	logic en, en2;
	parameter whichClock = 17;
	clock_divider cdiv (CLOCK_50, clock);
	// for randomizing numbers
	LSFR(.clk(CLOCK_50), .reset, .randNum, .en);
	LSFR(.clk(CLOCK_50), .reset, .randNum(randNum2), .en(en2));
	
	// for storing all the sprites into ROMs
	logic [23:0] RGB;
	logic birdOn, obsOn;
	logic [23:0] mem [0:1408];
	logic [23:0] startROM [0:10599];
	logic [23:0] namesROM[0:4799];
	logic [23:0] gameoverROM[0:5664];
	ram bram (.Clk(CLOCK_50), .data_Out(RGB), .en(birdOn), .mem, .startROM, .namesROM, .gameoverROM);
	
	// counter for tracking score
	counter2 c (clock[whichClock], (reset | start_game) , inc, HEX0, HEX1);

	assign HEX2 = '1;
	assign HEX3 = '1;
	assign HEX4 = '1;
	assign HEX5 = '1;
	
	// hit KEY[2] only once to start the mouse
	ps2 p(
		~KEY[2],        
		reset,         
		CLOCK_50,      
		PS2_CLK,       
		PS2_DAT,       
		button_left,   
		button_right,  
		button_middle, 
		bin_x,         
		bin_y);
		
	clock_generator my_clock_gen(
		// inputs
		CLOCK2_50,
		reset,

		// outputs
		AUD_XCK
	);

	audio_and_video_config cfg(
		// Inputs
		CLOCK_50,
		reset,

		// Bidirectionals
		FPGA_I2C_SDAT,
		FPGA_I2C_SCLK
	);

	audio_codec codec(
		// Inputs
		CLOCK_50,
		reset,

		read,	write,
		writedata_left, writedata_right,

		AUD_ADCDAT,

		// Bidirectionals
		AUD_BCLK,
		AUD_ADCLRCK,
		AUD_DACLRCK,

		// Outputs
		read_ready, write_ready,
		readdata_left, readdata_right,
		AUD_DACDAT
	);


	
endmodule
