module piece_animation(clock, reset, column, count, make_move, player, green, red, landed);
	// output logic [15:0][15:0] newGreen, newRed; // updated green and red led array matrix
	
	output logic landed; // signal that piece landed and move is complete
	
	output logic [15:0][15:0] red, green; // red and green led array matrix
	input logic make_move, player, clock, reset;
	input logic [3:0] column; // chosen column to place piece 
	
	input logic [3:0] count;
	
	logic [3:0] token_row; // current row where token is located at 
	
	enum {none, falling, land} ns, ps;
	
	// next state logic
	always_comb begin 
		case (ps)
			none:	begin 
				landed = 1'b0;
				if (make_move)  
					ns = falling;
				else 				
					ns = none;
			end 
			
			falling: begin // code for falling
				landed = 1'b0;
				if (count == 4'b1111) begin 
					// move token 1 down if room below and not at last row, else token stays
					if (token_row < 15) begin 
						if (!red[token_row + 1][15 - column] && !green[token_row + 1][15 - column]) 
							ns = falling;
						else 
							ns = land;
					end else 
						ns = land;
				end else 
					ns = falling;
			end 
			
			land: begin 
				landed = 1'b1; // signals that turn is complete 
				ns = none;
			end 
		endcase
	end 
	
	always_ff @(posedge clock) begin
		if (reset) begin 
			ps <= none;
			red <= '0;
			green <= '0;
			token_row <= 4'b0000;
		end else begin
			ps <= ns; 
			
			if (ps == none || ps == land)
				token_row <= 4'b0000;
			else if (ps == falling) begin
				if (count == 4'b1111) begin
					// clears previous row as token is moving down
					if (token_row > 0) begin
						if (player) // green matrix
							green[token_row - 1][15 - column] <= 1'b0;
						else // red matrix 
							red[token_row - 1][15 - column] <= 1'b0;
					end 
						
					token_row <= token_row + 1; // moves token down
					
					// place token at current token row
					if (player) // player = 1 => green
						green[token_row][15 - column] <= 1'b1;
					else // player = 0 => red
						red[token_row][15 - column] <= 1'b1;
				end  
			end 
		end 
	end
endmodule
	
	
// test bench  
module piece_animation_testbench();
	logic clock, reset, make_move, player, landed;
	logic [3:0] column;
	logic [3:0] count;
	logic[15:0][15:0] red, green;
	
	integer i;
	
	piece_animation dut (.*);
	
	// Set up a simulated clock.
	// Set up a simulated clock.
	parameter CLOCK_PERIOD=100;
	
	initial begin
		clock <= 0;
		forever #(CLOCK_PERIOD/2) clock <= ~clock; // Forever toggle the clock
	end
	
	initial begin
		
								  @(posedge clock);
		reset <= 1; 		  @(posedge clock); // Always reset FSMs at start
		
		repeat(5) @(posedge clock);
		
		reset <= 0;
		player <= 1'b0; // red starts 
		column <= 4'b0000;
		count <= 3'b000; 
		
		// make move = true until board full 
		for (i = 0; i < 256; i++) begin
			make_move <= 1'b1;	 @(posedge clock); // make move is true 
			make_move <= 1'b0;
			player <= ~player; 							 // switch to next player 
			column <= column + 4'b0001;				 // player selected next column 
			make_move <= 1'b0;
			
			for (i = 0; i < 128; i++) begin
				count <= count + 4'b0001; @(posedge clock);
			end 
					end
		$stop; // End the simulation.
	end 
endmodule 