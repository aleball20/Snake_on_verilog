
module random_sequence (

	input reset,
	input clock_25,
	input [6:0] seed,
	output reg [6:0] rnd
);

	wire [6:0] rnd_seq;
    wire rnd_bit;
	reg [2:0] cur_bit;


	PRBS my_prbs (
		.reset(reset),
		.clock_25(clock_25),
		.seed(seed),
		.rnd(rnd_seq)
	);

	assign rnd_bit = rnd_seq[0];

	always @(posedge clock_25)
	begin
		if (~reset)
			rnd <= 40;
			
		else	begin
		
			rnd[cur_bit] <= rnd_bit;

        if(cur_bit == 6)
            cur_bit= 3'b000;
        else
            cur_bit= cur_bit + 1'b1;
		end

	end

endmodule