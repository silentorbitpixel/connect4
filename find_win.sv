module find_win (Clock, reset, red, green, win);
	output logic [1:0] win; // 00 no win, 01 red win, 10 green win, 11 tie
	
	input logic Clock, reset;
	input logic [15:0][15:0] red;
	input logic [15:0][15:0] green; 
	
	logic board_full;
	integer row, col;
	
	enum {no_win, red_wins, green_wins, tie} ps, ns;
	
	always_comb begin
		ns = no_win; // defauls that ps stays 
		board_full = 1; // default - starts at true state
							
		// check rows for four in a row
		for (row = 0; row <= 15; row++) // check each row
			for (col = 0; col <= 12; col++)
				if (green[row][col] && green[row][col + 1] && green[row][col + 2] && green[row][col + 3]) 
					ns = green_wins;
				else if (red[row][col] && red[row][col + 1] && red[row][col + 2] && red[row][col + 3]) 
					ns = red_wins;
				
		// check columns for four in a row
		for (col = 0; col <= 15; col++) // check each col
			for (row = 0; row <= 12; row++)                          
				if (green[row][col] && green[row + 1][col] && green[row + 2][col] && green[row + 3][col]) 
					ns = green_wins;
				else if (red[row][col] && red[row + 1][col] && red[row + 2][col] && red[row + 3][col]) 
					ns = red_wins;
				
		// check negative diagonals (\) for four in a row
		for (row = 3; row <= 15; row++) 
			for (col = 0; col <= 12; col++)				        
				if (green[row][col] && green[row - 1][col + 1] && green[row - 2][col + 2] && green[row - 3][col + 3]) 
					ns = green_wins;
				else if (red[row][col] && red[row - 1][col + 1] && red[row - 2][col + 2] && red[row - 3][col + 3]) 
					ns = red_wins;
						
		// check postivie diagonals (/) for four in a row 
		for (row = 0; row <= 12; row++)
			for (col = 0; col <= 12; col++)
				if (green[row][col] && green[row + 1][col + 1] && green[row + 2][col + 2] && green[row + 3][col + 3]) 
					ns = green_wins;
				else if (red[row][col] && red[row + 1][col + 1] && red[row + 2][col + 2] && red[row + 3][col + 3]) 
					ns = red_wins;
				
		// check for a tie
		for (row = 0; row <= 15; row++)
			for (col = 0; col <= 15; col++)
				if (~green[row][col] && ~red[row][col])
					board_full = 0; // board full not true if there is space left
		// after iterating through every index, if there are no empty spots and no win, board remains full
			if (board_full)  ns = tie;				
	end 
	
	always_ff @(posedge Clock) begin
		if (reset) begin
			win <= 2'b00;
			ps <= no_win;
		end else begin
			ps <= ns;
			
			case (ps) 
				red_wins: 		win <= 2'b01;
				green_wins: 	win <= 2'b10;
				tie: 				win <= 2'b11;
				no_win: 			win <= 2'b00;
			endcase
		end 
	end

endmodule 

// testbench 
module find_win_testbench ();
	logic clock, reset;
	logic [15:0][15:0] red, green;
	logic [1:0] win;
	
	find_win dut (clock, reset, red, green, win);
	
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
		
		// blank board, no win condition
		red <= '0;
		green <= '0;
		repeat(5) @(posedge clock);
		
		// check red's row winning conditions
		red[15] <= 16'b0000100101011110;
		repeat(5) @(posedge clock);
		
		//             FEDCBA9876543210
		red[14] <= 16'b0000100111100000;
		red[15] <= '0;
		repeat(5) @(posedge clock);
		
		//             FEDCBA9876543210
		red[13] <= 16'b0000111100100000;
		red[14] <= '0;
		repeat(5) @(posedge clock);
		
		//             FEDCBA9876543210
		red[12] <= 16'b0111100100100100;
		red[13] <= '0;
		repeat(5) @(posedge clock);
		
		// check row winning condition for green
		//             FEDCBA9876543210
		red[12] <= '0;
		green[15] <= 16'b0000011110000000;
		repeat(5) @(posedge clock);
		
		green[13] <= 16'b0000011110000000;
		green[15] <= 16'b0000010110000000;
		repeat(5) @(posedge clock);
		
		// check column winning condition for red
		green <= '0;
		
		red[00] <= 16'b0000100000000000;
		red[01] <= 16'b0000100000000000;
		red[02] <= 16'b0000100000000000;
		red[03] <= 16'b0000100000000000;
		red[04] <= 16'b0000100000000000;
		repeat(5) @(posedge clock);
		
		red[01] <= 16'b1000000000000000;
		red[02] <= 16'b1000000000000000;
		red[03] <= 16'b1000000000000000;
		red[04] <= 16'b1000000000000000;
		red[05] <= 16'b1000000000000000;
		repeat(5) @(posedge clock);
		
		red[03] <= 16'b0000000000100000;
		red[04] <= 16'b0000000000100000;
		red[05] <= 16'b0000000000100000;
		red[06] <= 16'b0000000000100000;
		repeat(5) @(posedge clock);
		
		
		// check column winning condition for green 
		red <= '0;
		green[00] <= 16'b0000100000000000;
		green[01] <= 16'b0000100000000000;
		green[02] <= 16'b0000100000000000;
		green[03] <= 16'b0000100000000000;
		green[04] <= 16'b0000100000000000;
		repeat(5) @(posedge clock);
		
		green[01] <= 16'b1000000000000000;
		green[02] <= 16'b1000000000000000;
		green[03] <= 16'b1000000000000000;
		green[04] <= 16'b1000000000000000;
		green[05] <= 16'b1000000000000000;
		repeat(5) @(posedge clock);
		
		green[03] <= 16'b0000000000100000;
		green[04] <= 16'b0000000000100000;
		green[05] <= 16'b0000000000100000;
		green[06] <= 16'b0000000000100000;
		repeat(5) @(posedge clock);
		
		// check / diagonals for red four in a row
		green <= '0;
		red[12] <= 16'b0000010000000000;
		red[13] <= 16'b0000100000000000;
		red[14] <= 16'b0001000000000000;
		red[15] <= 16'b0010000000000000;
		repeat(5) @(posedge clock);
		
		// check \ diagonals for red four in a row
		red[12] <= 16'b0000100000000000;
		red[13] <= 16'b0000010000000000;
		red[14] <= 16'b0000001000000000;
		red[15] <= 16'b0000000100000000;
		repeat(5) @(posedge clock);
		
		// check / diagonals for green four in a row
		red <= '0;
		green[12] <= 16'b0000010000000000;
		green[13] <= 16'b0000100000000000;
		green[14] <= 16'b0001000000000000;
		green[15] <= 16'b0010000000000000;
		
		// check \ diagonals for green four in a row 
		green[12] <= 16'b0000100000000000;
		green[13] <= 16'b0000010000000000;
		green[14] <= 16'b0000001000000000;
		green[15] <= 16'b0000000100000000;
		repeat(5) @(posedge clock);
		
		// check for a tie 
		//             FEDCBA9876543210
		red[00] <= 16'b1010101010101010;
		red[01] <= 16'b0101010101010101;
		red[02] <= 16'b1010101010101010;
		red[03] <= 16'b0101010101010101;
		red[04] <= 16'b1010101010101010;
		red[05] <= 16'b0101010101010101;
		red[06] <= 16'b1010101010101010;
		red[07] <= 16'b0101010101010101;
		red[08] <= 16'b1010101010101010;
		red[09] <= 16'b0101010101010101;
		red[10] <= 16'b1010101010101010;
		red[11] <= 16'b0101010101010101;
		red[12] <= 16'b1010101010101010;
		red[13] <= 16'b0101010101010101;
		red[14] <= 16'b1010101010101010;
		red[15] <= 16'b0101010101010101;
		  
		//      	        FEDCBA9876543210
		green[00] <= 16'b0101010101010101;
		green[01] <= 16'b1010101010101010;
		green[02] <= 16'b0101010101010101;
		green[03] <= 16'b1010101010101010;
		green[04] <= 16'b0101010101010101;
		green[05] <= 16'b1010101010101010;
		green[06] <= 16'b0101010101010101;
		green[07] <= 16'b1010101010101010;
		green[08] <= 16'b0101010101010101;
		green[09] <= 16'b1010101010101010;
		green[10] <= 16'b0101010101010101;
		green[11] <= 16'b1010101010101010;
		green[12] <= 16'b0101010101010101;
		green[13] <= 16'b1010101010101010;
		green[14] <= 16'b0101010101010101;
		green[15] <= 16'b1010101010101010;
		
		repeat(5) @(posedge clock);
		
		$stop; // end simulation
	end 
endmodule 
	