module check_column(clock, Reset, selected_col, red_array, green_array, valid);
	input logic [15:0][15:0] red_array, green_array;
	input logic clock, Reset;
	input logic [3:0] selected_col; // 4 bit value of the column selected
	output logic valid; // returns true if column is not full when a move is made
		
	always_ff @(posedge clock) begin
		if (Reset)
			valid <= 0;
		else if (~(red_array[0][15 - selected_col] || green_array[0][15 - selected_col])) // if there is an empty spot in the column
			valid <= 1; // column not full
		else 
			valid <= 0; // column full 
	end
		
endmodule 

// test bench 
module check_column_testbench();
	logic clock, Reset, valid;
	logic [15:0][15:0] red_array, green_array; 
	logic [3:0] selected_col;

	integer i;
	
	check_column dut (clock, Reset, selected_col, red_array, green_array, valid);
	
	// Set up a simulated clock.
	// Set up a simulated clock.
	parameter CLOCK_PERIOD=100;
	
	initial begin
			clock <= 0;
			forever #(CLOCK_PERIOD/2) clock <= ~clock; // Forever toggle the clock
	end
		
	initial begin
			
								  @(posedge clock);
		Reset <= 1; 		  @(posedge clock); // Always reset FSMs at start
			
		repeat(5) @(posedge clock);
			
		// check that for non empty columns, valid should be false 
		// check that if column has chips but no full, valid is true
		// check that for any column that is not full, valid is true
	  
		 //                  FEDCBA9876543210
		red_array[00] <= 16'b1100000100000000;
		red_array[01] <= 16'b1100000100000000;
		red_array[02] <= 16'b1100000100000000;
		red_array[03] <= 16'b1100000100000000;
		red_array[04] <= 16'b1100000100000000;
		red_array[05] <= 16'b1100000100000000;
		red_array[06] <= 16'b1100000100000000;
		red_array[07] <= 16'b1100000100100000;
		red_array[08] <= 16'b1100000100000000;
		red_array[09] <= 16'b1100000100000000;
		red_array[10] <= 16'b1100000100100000;
		red_array[11] <= 16'b1100000000001000;
		red_array[12] <= 16'b1110000000000000;
		red_array[13] <= 16'b1110000000000000;
		red_array[14] <= 16'b1110000000001000;
		red_array[15] <= 16'b1110000000001000;
		  
		//                  FEDCBA9876543210
		green_array[00] <= 16'b0010000000000011;
		green_array[01] <= 16'b0010000000000011;
		green_array[02] <= 16'b0010000000000011;
		green_array[03] <= 16'b0010000000000011;
		green_array[04] <= 16'b0010000000000011;
		green_array[05] <= 16'b0010000000000011;
		green_array[06] <= 16'b0010000000000011;
		green_array[07] <= 16'b0010000000000011;
		green_array[08] <= 16'b0010000000000011;
		green_array[09] <= 16'b0010000000000011;
		green_array[10] <= 16'b0010000000000011;
		green_array[11] <= 16'b0010000100000011;
		green_array[12] <= 16'b0000000100100011;
		green_array[13] <= 16'b0000000100100011;
		green_array[14] <= 16'b0000000100100011;
		green_array[15] <= 16'b0000000100100011;
	  
		for (i = 0; i <= 15; i++)
			selected_col <= i;
			repeat(10) @(posedge clock);
		
		$stop; // End the simulation.
	end
endmodule