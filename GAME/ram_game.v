

module ram_game
#(parameter DATA_WIDTH=2, parameter ADDR_WIDTH=14)
(
	input [(DATA_WIDTH-1):0] game_position,
   input [(ADDR_WIDTH-1):0] addr,						 //addr=(game_board_y*124)+game_board_x;
	input we, clk,
	output [(DATA_WIDTH-1):0] q
);  
	// Declare the RAM variable
	reg [DATA_WIDTH-1:0] ram[2**ADDR_WIDTH-1:0];

	// Variable to hold the registered read address
	reg [ADDR_WIDTH-1:0] addr_reg;

  initial 
    begin : INIT
		integer i;
		for(i = 0; i < 2**ADDR_WIDTH; i = i + 1)
			ram[i] = {DATA_WIDTH{1'b0}};
	end

	always @ (posedge clk)
	begin
		// Write
		if (we)
			ram[addr] <= game_position;

		addr_reg <= addr;
	end
	
assign q = ram[addr_reg];
endmodule