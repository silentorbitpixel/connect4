module user_input(Clock, Reset, switches, out);
	input logic Clock, Reset;
	input logic [3:0] switches;
	output logic [3:0] out;

	logic [3:0] flip1;
	
	// first flip flop 
	always_ff @(posedge Clock) begin
		flip1 <= switches;
	end
	
	// output from the second dq flip flop to not have metastability 
	always_ff @(posedge Clock) begin
		out <= flip1;
	end
	
endmodule