// this counter is used to slow down animation speed to go at 1/16 the current clock speed 
module up_counter (out, incr, reset, clk);
	output logic [3:0] out;
	input logic incr, reset, clk;
	
	always_ff @(posedge clk) begin
		if (reset)
			out <= 4'b000;
		else if (incr)
			out <= out + 4'b0001;
		else 
			out <= out;
	end 
	
endmodule