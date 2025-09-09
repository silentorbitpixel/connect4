module dff2 (Clock, Reset, press, out);
	input logic Clock, Reset;
	input logic press;
	output logic out;
	
	logic flip1;
	
	// first flip flop 
	always_ff @(posedge Clock) begin
		flip1 <= press;
	end
	
	// output from the second dq flip flop to not have metastability 
	always_ff @(posedge Clock) begin
		out <= flip1;
	end
		
endmodule 