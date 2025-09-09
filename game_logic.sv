module game_logic(clock, reset, landed, win, userIn, valid_col, player, make_move);
	// output logic [1:0] game_state; // state of the game 
	output logic player; // player turn
	output logic make_move; // make move signal 
	
	input logic clock, reset;
	input logic landed;
	input logic [1:0] win;
	input logic userIn, valid_col;
	
	enum {idle, animate, tie, redWin, greenWin} ps, ns;
	
	always_comb begin
		case(ps)
			idle: begin 
				if (userIn & valid_col) begin// valid conditions for move to be made
					ns = animate;
					make_move = 1;
				end else begin
					 ns = idle;
					 make_move = 0;
				end 
			end 
			
			animate: begin 
				if (landed) begin
					make_move = 0;
					if (win == 2'b11)
						ns = tie; // game ends
					else if (win == 2'b01)
						ns = redWin; // game ends
					else if (win == 2'b10)
						ns = greenWin; // game ends
					else
						ns = idle; // game continues 
				end else begin
					ns = animate;
					make_move = 0;
				end 
			end 
			
			tie: begin 
				ns = tie;
				make_move = 0;
			end 
			
			redWin: begin 
				ns = redWin;
				make_move = 0;
			end 
			
			greenWin: begin 
				ns = greenWin;
				make_move = 0;
			end 
			
		endcase
	end
	
	always_ff @(posedge clock) begin
		if (reset) begin 
			ps <= idle;
			player <= 1'b0;
		end else begin 
			ps <= ns; 
			if (landed && ns == idle) 
				player <= ~player; // next player goes
			else 
				player <= player;
		end
	end
	
endmodule 

// test bench 
module game_logic_testbench();
	logic clock, reset, landed, userIn, valid_col, player, make_move;
	logic [1:0] win;
		
	game_logic dut (clock, reset, landed, win, userIn, valid_col, player, make_move);
	
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

		// make move singal true only when userIn, valid column, and current is idle state 
		//		make move should be false, player should not change 
		win <= 2'b00;
		landed <= 1'b1;
		userIn <= 1'b0;
		valid_col <= 1'b0;
		repeat(10) @(posedge clock);
		
		userIn <= 1'b1;
		repeat(10) @(posedge clock);
		
		userIn <= 1'b0;
		valid_col <= 1'b1;
		repeat(10) @(posedge clock);
		
		userIn <= 1'b1;
		valid_col <= 1'b1; 
		repeat(10) @(posedge clock);
		// make move should be true 
		
		// while landed is false, make sure make move stays false for any user play signal
		userIn <= 1'b0;
		valid_col <= 1'b0;
		repeat(10) @(posedge clock);
		
		userIn <= 1'b1;
		repeat(10) @(posedge clock);
		
		userIn <= 1'b0;
		valid_col <= 1'b1;
		repeat(10) @(posedge clock);
		
		userIn <= 1'b1;
		valid_col <= 1'b1; 
		repeat(10) @(posedge clock);
		
		// when landed, player should switch 
		landed <= 1'b1; 
		repeat(10) @(posedge clock);
		
		// when win, player does not switch, make move stays false 
		win <= 2'b01;
		repeat(10) @(posedge clock);
		
		userIn <= 1'b0;
		valid_col <= 1'b0;
		repeat(10) @(posedge clock);
		
		userIn <= 1'b1;
		repeat(10) @(posedge clock);
		
		userIn <= 1'b0;
		valid_col <= 1'b1;
		repeat(10) @(posedge clock);
		
		userIn <= 1'b1;
		valid_col <= 1'b1; 
		repeat(10) @(posedge clock);
		
		// if green wins
		win <= 2'b11;
		repeat(10) @(posedge clock);
		
		userIn <= 1'b0;
		valid_col <= 1'b0;
		repeat(10) @(posedge clock);
		
		userIn <= 1'b1;
		repeat(10) @(posedge clock);
		
		userIn <= 1'b0;
		valid_col <= 1'b1;
		repeat(10) @(posedge clock);
		
		// if tie
		win <= 2'b01;
		repeat(10) @(posedge clock);
		
		userIn <= 1'b0;
		valid_col <= 1'b0;
		repeat(10) @(posedge clock);
		
		userIn <= 1'b1;
		repeat(10) @(posedge clock);
		
		userIn <= 1'b0;
		valid_col <= 1'b1;
		repeat(10) @(posedge clock);
		
		userIn <= 1'b1;
		valid_col <= 1'b1; 
		repeat(10) @(posedge clock);
		
		$stop; // End the simulation.
	end 
endmodule 