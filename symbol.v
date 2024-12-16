module symbol (clock_25, selected_figure, selected_symbol);

input clock_25;
input [1:0]selected_figure;
output reg [49:0]selected_symbol;
reg [49:0] figures[3:0];


initial begin

    figures[0]=50'b01000000000101010000011101010001010111110101010101; // head
    figures[1]=50'b01010101010101010101010101010101010101010101010101; //body
    figures[2]=50'b00000000010001010101100101010100010101010000000101; //tail
    figures[3]=50'b00000100000000010000000100010010100010101010001010; //cherry

end

always @ (posedge clock_25)

	begin
		 selected_symbol <= figures[selected_figure];
	end


endmodule