module hexes_display (clock, reset, player, game_state, HEX);
	output logic [6:0] HEX [5:0];
	
	input logic clock, reset;
	input logic player;
	input logic [1:0] game_state;
	
	logic [6:0] display [5:0];
	
	always_comb begin
		case (game_state)
			2'b00: begin  					 // game in progress
				display[5] = 7'b0000010; // G
				display[4] = 7'b1000000; // O
				display[3] = 7'b1111111; // 	blank			
				
				if (~player) begin 			 // if player == 0: red move, "GO rEd"
					display[2] = 7'b0101111; // r
					display[1] = 7'b0000110; // E
					display[0] = 7'b0100001; // d
				end else begin 				 // if player == 1: green move "GO Grn"
					display[2] = 7'b0000010; // G
					display[1] = 7'b0101111; // r
					display[0] = 7'b0101011; // n
				end 
			end 
				
			2'b01: begin 				    // red wins
				display[5] = 7'b0101111; // r
				display[4] = 7'b0000110; // E
				display[3] = 7'b0100001; // d
				display[2] = 7'b1111111; //   blank
				display[1] = 7'b1111001; // 1
				display[0] = 7'b1111111; // 	blank
			end 
			
			2'b10: begin 					 // green wins
				display[5] = 7'b0000010; // G
				display[4] = 7'b0101111; // r
				display[3] = 7'b0101011; // n
				display[2] = 7'b1111111; // 	blank
				display[1] = 7'b1111001; // 1
				display[0] = 7'b1111111; // 	blank			
			end 
			
			2'b11: begin 					 // tie 
				display[5] = 7'b0001110; // F
				display[4] = 7'b1000001; // U
				display[3] = 7'b1000111; // L
				display[2] = 7'b1000111; // L
				display[1] = 7'b1111111; // 	blank
				display[0] = 7'b1111111; // 	blank 
			end 
		endcase 
	end 
	
	always_ff @(posedge clock) begin
		if (reset) begin
		// default state when reset is red's turn 
			HEX[5] <= 7'b0000010; // G
			HEX[4] <= 7'b1000000; // O
			HEX[3] <= 7'b1111111; // 	blank
			HEX[2] <= 7'b0101111; // r
			HEX[1] <= 7'b0000110; // E
			HEX[0] <= 7'b0100001; // d
		end else 
			HEX <= display;
	end
	
endmodule 