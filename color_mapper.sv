// main module that controls the drawing FSM, the obstacle collision detection and
// movement/drawing of all objects in the games and increments score for the game
module color_mapper(clk, reset, x, y, groundX, groundY, red, green, blue, birdROM, birdOn, start_game,
			bird_up, obsOn, randNum, en, randNum2, en2, startROM, namesROM, gameoverROM, inc);
	
	// variables required for drawing and game inputs
	input logic clk, reset, start_game, bird_up;
	input logic [10:0] groundX, groundY;
	output logic [7:0] red, green, blue;
	input logic [9:0] x;
	input logic [8:0] y;
	logic collides;
	input logic [23:0] birdROM [0:1408];
	input logic [23:0] startROM [0:10599];
	input logic [23:0] namesROM [0:4799];
	input logic [23:0] gameoverROM [0:5664];
	logic [23:0] RGB;
	input logic [9:0] randNum, randNum2;
	output logic birdOn;
	output logic obsOn;
	output logic en, en2;
	output logic inc;
	
	// parameters for bird
	parameter birdROMLen = 1453;
	parameter bird_w = 44;
	parameter bird_h = 31;	
	
	// parameters and logic for obstacles
	logic [7:0] obs_h1; 
	logic [7:0] obs_h2; 
	assign obs_h1 = (randNum % 100) + 30; // randomizing variable
	assign obs_h2 = 280 - obs_h1;	// constant height sum of 280
	logic [7:0] obsTwo_h1;
	logic [7:0] obsTwo_h2;
	assign obsTwo_h1 = (randNum2 % 70) + 120; // randomizing variable
	assign obsTwo_h2 = 280 - obsTwo_h1;	 // constant height sum of 280
	parameter obs_w = 50; 	
	logic [10:0] x_pos, y_pos, obs1_ypos, obs1_xpos, obs2_ypos;
	logic [10:0] obsTwo1_ypos, obsTwo1_xpos, obsTwo2_ypos;
	
	// parameters for start game banner
	parameter start_xpos = 300;
	parameter start_ypos = 150;
	parameter start_h = 53;
	parameter start_w = 200;
	
	// parameters for names banner
	parameter names_xpos = 300;
	parameter names_ypos = 300;
	parameter names_h = 24;
	parameter names_w = 200;

	// parameters for game over banner
	parameter gameover_xpos = 250;
	parameter gameover_ypos = 200;
	parameter gameover_h = 55;
	parameter gameover_w = 103;		
	
	
	enum {s1, s2, s3} ps, ns; // drawing FSM states and game states
	
	// assignments required
	assign x_pos = 100;
	assign obs1_ypos = 0;
	assign obs2_ypos = groundY - obs_h2; // 400 - h2
	assign obsTwo1_ypos = 0;
	assign obsTwo2_ypos = groundY - obsTwo_h2;
	logic [31:0] clock;
	parameter whichClock = 17;
	clock_divider cdiv (clk, clock);
	
always_ff @(posedge clk) begin
		if(ps == s1) begin // game not started state
			if ( (x >= groundX && y >= groundY) ) begin // draw ground
				red <= 8'hEC;
				green <= 8'hD3;
				blue <= 8'h89;
				birdOn <= 0;
			end 
			
			else begin // draw sky
			// E6F4FF
				red <= 8'hE6;
				green <= 8'hF4;
				blue <= 8'hFF;
				birdOn <= 0;
			end
			
			if(start_game) begin
					//draw bird at 150,150
					if ( (x >= x_pos && x <= x_pos + bird_w) &&
						(y >= y_pos && y <= y_pos + bird_h) ) begin
							red <= birdROM[(x - x_pos) + (bird_w * (y - y_pos))][23:16];
							green <= birdROM[(x - x_pos) + (bird_w * (y - y_pos))][15:8];
							blue <= birdROM[(x - x_pos) + (bird_w * (y - y_pos))][7:0];
							birdOn <= 1;
					end
			end
		
			else begin
				//draw bird at 150,150
				if ( (x >= 150 && x <= 150 + bird_w) &&
					(y >= 150 && y <= 150 + bird_h) ) begin
						red <= birdROM[(x - 150) + (bird_w * (y - 150))][23:16];
						green <= birdROM[(x - 150) + (bird_w * (y - 150))][15:8];
						blue <= birdROM[(x - 150) + (bird_w * (y - 150))][7:0];
						birdOn <= 1;
				end
			end
			
			// START GAME BANNER HERE WITH FLAPPY BIRD AND NAMES
				if ( (x >= start_xpos && x < start_xpos + start_w) &&
					  (y >= start_ypos && y < start_ypos + start_h)) begin
					   red <= startROM[(x - start_xpos) + (start_w * (y - start_ypos))][23:16];
						green <= startROM[(x - start_xpos) + (start_w * (y - start_ypos))][15:8];
						blue <= startROM[(x - start_xpos) + (start_w * (y - start_ypos))][7:0];
				end
				
				else if ( (x >= names_xpos && x < names_xpos + names_w) &&
					  (y >= names_ypos && y < names_ypos + names_h)) begin
					   red <= namesROM[(x - names_xpos) + (names_w * (y - names_ypos))][23:16];
						green <= namesROM[(x - names_xpos) + (names_w * (y - names_ypos))][15:8];
						blue <= namesROM[(x - names_xpos) + (names_w * (y - names_ypos))][7:0];
				end			
		end
		
		else if(ps == s2) begin //play game state : y_pos always gets updated 
			if ( (x >= groundX && y >= groundY) ) begin // draw ground
				red <= 8'hEC;
				green <= 8'hD3;
				blue <= 8'h89;
				birdOn <= 0;
				obsOn <= 0;
			end 
			
			else if ((x >= x_pos && x <= x_pos + bird_w) && // draw bird
						(y >= y_pos && y <= y_pos + bird_h) ) begin
							red <= birdROM[(x - x_pos) + (bird_w * (y - y_pos))][23:16];
							green <= birdROM[(x - x_pos) + (bird_w * (y - y_pos))][15:8];
							blue <= birdROM[(x - x_pos) + (bird_w * (y - y_pos))][7:0];
							birdOn <= 1;
							obsOn <= 0;
			end
			
			else if((x >= obs1_xpos && x <= obs1_xpos + obs_w) && // draw obstacle1 high
					  (y >= obs1_ypos && y <= obs1_ypos + obs_h1)) begin
							red <= 0;
							green <= 8'h8F;
							blue <= 8'h11;
							birdOn <= 0;
							obsOn <= 1;
			end
			
			else if((x >= obs1_xpos && x <= obs1_xpos + obs_w) && // draw obstacle1 low
					  (y >= obs2_ypos && y <= obs2_ypos + obs_h2)) begin
							red <= 0;
							green <= 8'h8F;
							blue <= 8'h11;
							birdOn <= 0;
							obsOn <= 1;
			end
			
			else if((x >= obsTwo1_xpos && x <= obsTwo1_xpos + obs_w) && // draw obstacle2 high
					  (y >= obsTwo1_ypos && y <= obsTwo1_ypos + obsTwo_h1)) begin
							red <= 0;
							green <= 8'h8F;
							blue <= 8'h11;
							birdOn <= 0;
							obsOn <= 1;				
			end
			
			else if((x >= obsTwo1_xpos && x <= obsTwo1_xpos + obs_w) && // draw obstacle2 low
					  (y >= obsTwo2_ypos && y <= obsTwo2_ypos + obsTwo_h2)) begin
							red <= 0;
							green <= 8'h8F;
							blue <= 8'h11;
							birdOn <= 0;
							obsOn <= 1;
			end
			
			else begin // sky color
			// E6F4FF
				red <= 8'hE6;
				green <= 8'hF4;
				blue <= 8'hFF;
				birdOn <= 0;
				obsOn <= 0;
			end
			
		end // end of state 2
		
		else if (ps == s3) begin // game over state
			if ( (x >= groundX && y >= groundY) ) begin // draw ground
				red <= 8'hEC;
				green <= 8'hD3;
				blue <= 8'h89;
				birdOn <= 0;
				obsOn <= 0;
			end 
			
			else if ((x >= x_pos && x <= x_pos + bird_w) && // draw bird
						(y >= y_pos && y <= y_pos + bird_h) ) begin
							red <= birdROM[(x - x_pos) + (bird_w * (y - y_pos))][23:16];
							green <= birdROM[(x - x_pos) + (bird_w * (y - y_pos))][15:8];
							blue <= birdROM[(x - x_pos) + (bird_w * (y - y_pos))][7:0];
							birdOn <= 1;
							obsOn <= 0;
			end
			
			else if((x >= obs1_xpos && x <= obs1_xpos + obs_w) && // draw obstacle1 high
					  (y >= obs1_ypos && y <= obs1_ypos + obs_h1)) begin
							red <= 0;
							green <= 8'h8F;
							blue <= 8'h11;
							birdOn <= 0;
							obsOn <= 1;
			end
			
			else if((x >= obs1_xpos && x <= obs1_xpos + obs_w) && // draw obstacle1 low
					  (y >= obs2_ypos && y <= obs2_ypos + obs_h2)) begin
							red <= 0;
							green <= 8'h8F;
							blue <= 8'h11;
							birdOn <= 0;
							obsOn <= 1;
			end
			
			else if((x >= obsTwo1_xpos && x <= obsTwo1_xpos + obs_w) && // draw obstacle2 high
					  (y >= obsTwo1_ypos && y <= obsTwo1_ypos + obsTwo_h1)) begin
							red <= 0;
							green <= 8'h8F;
							blue <= 8'h11;
							birdOn <= 0;
							obsOn <= 1;				
			end
			
			else if((x >= obsTwo1_xpos && x <= obsTwo1_xpos + obs_w) && // draw obstacle2 low
					  (y >= obsTwo2_ypos && y <= obsTwo2_ypos + obsTwo_h2)) begin
							red <= 0;
							green <= 8'h8F;
							blue <= 8'h11;
							birdOn <= 0;
							obsOn <= 1;
			end
			
			else begin // sky color
			// E6F4FF
				red <= 8'hE6;
				green <= 8'hF4;
				blue <= 8'hFF;
				birdOn <= 0;
				obsOn <= 0;
			end
			
			
			// Draws GAME OVER banner
			if ( (x >= gameover_xpos && x < gameover_xpos + gameover_w) &&
				  (y >= gameover_ypos && y < gameover_ypos + gameover_h)) begin
					   red <= gameoverROM[(x - gameover_xpos) + (gameover_w * (y - gameover_ypos))][23:16];
						green <= gameoverROM[(x - gameover_xpos) + (gameover_w * (y - gameover_ypos))][15:8];
						blue <= gameoverROM[(x - gameover_xpos) + (gameover_w * (y - gameover_ypos))][7:0];
			end
			
		end
	end
	
	// updates the states
	always_ff @(posedge clk) begin
		if(reset) ps <= s1;
		else 		 ps <= ns;
	end
	
	// Collision detection between bird and obstacles 1 & 2 or Ground
	assign collides = ((((x_pos + bird_w) == obs1_xpos) && (y_pos  <= (obs1_ypos + obs_h1)) && (y_pos  >= obs1_ypos))
						|| (((x_pos + bird_w) >= obs1_xpos) && ((x_pos) <= (obs1_xpos + obs_w)) && (y_pos <= (obs1_ypos + obs_h1))) 
						|| (((x_pos + bird_w) == obs1_xpos) && (y_pos <= (obs2_ypos + obs_h2)) && (y_pos >= obs2_ypos))
						|| (((x_pos + bird_w) >= obs1_xpos) && ((x_pos) <= (obs1_xpos + obs_w)) && (y_pos + bird_h >= obs2_ypos)))
						
						|| (y_pos == (groundY - bird_h))
						
						|| ((((x_pos + bird_w) == obsTwo1_xpos) && (y_pos  <= (obsTwo1_ypos + obsTwo_h1)) && (y_pos  >= obsTwo1_ypos))
						|| (((x_pos + bird_w) >= obsTwo1_xpos) && ((x_pos) <= (obsTwo1_xpos + obs_w)) && (y_pos <= (obsTwo1_ypos + obsTwo_h1))) 
						|| (((x_pos + bird_w) == obsTwo1_xpos) && (y_pos <= (obsTwo2_ypos + obsTwo_h2)) && (y_pos >= obsTwo2_ypos))
						|| (((x_pos + bird_w) >= obsTwo1_xpos) && ((x_pos) <= (obsTwo1_xpos + obs_w)) && (y_pos + bird_h >= obsTwo2_ypos)));
	
	// Updates position of the bird depending on state
	always_ff @(posedge clock[whichClock]) begin
		if(ps == s1) begin // bird stays still
			y_pos <= 150;
			obs1_xpos <= 300;
			en <= 1;
			obsTwo1_xpos <= 500;
			inc <= 0;
			if (start_game) ns <= s2;
			else ns <= s1;
		end
		else if(ps == s2) begin
			en <= 0;
			// handles bird movement //
			if(!collides) begin // no collision
				if(bird_up) begin
					// if already touch the ground in the previous state
					if(y_pos == groundY - bird_h) y_pos <= groundY - bird_h;
					
					else begin
					//if on top, stay top, proceed to move top if not on top
						if(y_pos > 0) y_pos <= y_pos-1;
						else y_pos <= 0;
					end
				end
				else begin
					//if bird does not touch ground, go down
					if(y_pos < (groundY - bird_h)) y_pos <= y_pos+1;
					else y_pos <= groundY - bird_h; // stay on the ground, game over
				end
				
				// handles obstacle movement
				if (obs1_xpos > 0)	obs1_xpos <= obs1_xpos - 2; // move obstacle to the left when not at the left corner
				else begin en <= 1; obs1_xpos <= 500; end				
				if (obsTwo1_xpos > 0) obsTwo1_xpos <= obsTwo1_xpos - 2;
				else begin obsTwo1_xpos <= 500; end
				
				// handles score output
				if ((x_pos == obs1_xpos) | (x_pos == obsTwo1_xpos)) inc <= 1;
				else inc <= 0;
				
				ns <= s2;
				
			end
				
			else begin // collision
				en <= 0;
				y_pos <= y_pos;
				obs1_xpos <= obs1_xpos; // stays still		
				obsTwo1_xpos <= obsTwo1_xpos;
				inc <= 0;
				ns <= s3;
			end
		end
		
		else if (ps == s3) begin // freeze the game objects
				en <= 0;
				y_pos <= y_pos;
				obs1_xpos <= obs1_xpos; // stays still		
				obsTwo1_xpos <= obsTwo1_xpos;
				inc <= 0;
				if (start_game) ns <= s1;
				else ns <= s3;
		end
	end
endmodule 

// divided_clocks[0] = 25MHz, [1] = 12.5Mhz, ... [23] = 3Hz, [24] = 1.5Hz,
//[25] = 0.75Hz, ...
module clock_divider (clock, divided_clocks);
	input logic   clock;
	output logic [31:0] divided_clocks = 0;

	always_ff @(posedge clock) begin
	divided_clocks <= divided_clocks + 1;
 end

endmodule

