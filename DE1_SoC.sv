// Top-level module that defines the I/Os for the DE-1 SoC board
module DE1_SoC (HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, SW, LEDR, GPIO_1, CLOCK_50);
    output logic [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	 output logic [9:0]  LEDR;
    input  logic [3:0]  KEY;
    input  logic [9:0]  SW;
    output logic [35:0] GPIO_1;
    input logic CLOCK_50;	 
	 
	 
	 logic [3:0] count;					 
	 logic landed;
	 logic [1:0] win; // win state (00: no win, 01: red win, 10: green win, 11: tie)
	 /* Set up system base clock to 1526 Hz (50 MHz / 2**(14+1))
	    ===========================================================*/
	 logic [31:0] clk;
	 logic SYSTEM_CLOCK;
	 
	 clock_divider divider (.clock(CLOCK_50), .divided_clocks(clk));
	 
	 assign SYSTEM_CLOCK = clk[13]; // 1526 Hz clock signal	 
	 
	 /* If you notice flickering, set SYSTEM_CLOCK faster.
	    However, this may reduce the brightness of the LED board. */
	
	 
	 /* Set up LED board driver
	    ================================================================== */
	 logic [15:0][15:0]RedPixels; // 16 x 16 array representing red LEDs
    logic [15:0][15:0]GrnPixels; // 16 x 16 array representing green LEDs
	 logic RST;                   // reset - toggle this on startup
	 
	 assign RST = ~KEY[0];
	 
	 /* Standard LED Driver instantiation - set once and 'forget it'. 
	    See LEDDriver.sv for more info. Do not modify unless you know what you are doing! */
	 LEDDriver Driver (.CLK(SYSTEM_CLOCK), .RST, .EnableCount(1'b1), .RedPixels, .GrnPixels, .GPIO_1);
	 
	 
	 /* LED board test submodule - paints the board with a static pattern.
	    Replace with your own code driving RedPixels and GrnPixels.
		 
	 	 KEY0      : Reset
		 =================================================================== */
	 // LED_test test (.RST(~KEY[0]), .RedPixels, .GrnPixels); 
	 
	 
	 logic pressed; // key pressed
	 // user input flip flops twice
	 dff2 play (.Clock(SYSTEM_CLOCK), .Reset(RST), .press(~KEY[1]), .out(pressed));
	 
	 // user presses key 1 to confirm their move 
	 logic play_signal; // signal that player has made move
	 userIn playSignal (.Clock(SYSTEM_CLOCK), .Reset(RST), .press(pressed), .out(play_signal));
	 
	 // column selection (0-15) determined by 4 bit binary num represented by switches 0-3. 
	 // 		ex SW[3:0] = 4b'0010 would mean column 2 is selected 
	 logic [3:0] switch_input;
	 user_input switches (.Clock(SYSTEM_CLOCK), .Reset(RST), .switches({SW[3], SW[2], SW[1], SW[0]}), .out(switch_input)); 
	 
	 logic valid_column;
	 check_column validate (.clock(SYSTEM_CLOCK), .Reset(RST), .selected_col(switch_input), .red_array(RedPixels), .green_array(GrnPixels), .valid(valid_column));
	 
	 logic make_move; 		  // signal to make move 
	 // logic [1:0] game_state;  // keeps track of the game states: waiting, falling, tie, red win, green win
	 logic player;				  // keeps track of which player's move it is
	 //logic nextPlayer;
	 game_logic game (.clock(SYSTEM_CLOCK), .reset(RST), .landed(landed), .win(win), .userIn(play_signal), 
							.valid_col(valid_column), .player(player), .make_move(make_move));

	 //logic[15:0][15:0] newGreen;
	 //logic[15:0][15:0] newRed;
	 

	 
	 // keeps track of LED display when moves are made 
	 piece_animation ledArray (.clock(SYSTEM_CLOCK), .reset(RST), .column(switch_input), .count(count), .make_move(make_move), .player(player), .green(GrnPixels), 
										.red(RedPixels), .landed(landed));
										
	 up_counter counter (.out(count), .incr(1'b1), .reset(RST), .clk(SYSTEM_CLOCK));
	 
	 
	 
	 find_win winner (.Clock(SYSTEM_CLOCK), .reset(RST), .red(RedPixels), .green(GrnPixels), .win(win));
	 
	 logic [6:0] display [5:0];
	 hexes_display displayHEX (.clock(SYSTEM_CLOCK), .reset(RST), .player(player), .game_state(win), .HEX(display)); // displays game state on seven seg display
	 	 
	 
	 assign LEDR[1:0] = win;
	 assign LEDR[9:6] = switch_input;
	 
	 // hex displays 
    assign HEX0 = display[0];
    assign HEX1 = display[1];
    assign HEX2 = display[2];
    assign HEX3 = display[3];
    assign HEX4 = display[4];
    assign HEX5 = display[5]; 
	 
endmodule

module DE1_SoC_testbench();
	logic CLOCK_50;
	logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	logic [9:0] LEDR;
	logic [3:0] KEY;
	logic [9:0] SW;
	logic [35:0] GPIO_1;
	
	integer i;
	
	DE1_SoC dut (CLOCK_50, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW, GPIO_1);
	
	// Set up a simulated clock.
	parameter CLOCK_PERIOD=100;
	
	initial begin
		CLOCK_50 <= 0;
		forever #(CLOCK_PERIOD/2) CLOCK_50 <= ~CLOCK_50; // Forever toggle the clock
	end
	
	// Test the design.
	initial begin
						 repeat(1) @(posedge CLOCK_50);
		KEY[0] <= 0; repeat(1) @(posedge CLOCK_50); // Always reset FSMs at start
		KEY[0] <= 1; repeat(1) @(posedge CLOCK_50);
		
		SW[3:0] = '0;
		
		// toggle switches and press keys for many cycles 
		for (i = 0; i <= 256; i++) begin
			KEY[1] <= 0; repeat(10) @(posedge CLOCK_50);
			
			KEY[1] <= 1; 
			SW[3:0] <= SW[3:0] + 4'b0001; // selects next column 
			repeat(10) @(posedge CLOCK_50);
		end 
	
	$stop; // End the simulation.
	end

endmodule