/* To allow reading symbols from graphic game, the cells are 5x5 pixels in size. Therefore,each pixel is described by 2 bits in order
to choose a color, therefore each symbol consists of 50 bits.
As a result, each figure is represented using 50 bits (2 bits per pixel). The reading process starts
with the 2  MSBs representing pixel in the matrix position [1][1], then proceeds to read the next pixel [2][1],
and so on. The output is  all the sybol word which will go to graphic game */



module symbol (clock_25, selected_figure, selected_symbol);

input clock_25;
input [3:0]selected_figure;
output reg [49:0]selected_symbol;
reg [49:0] figures[15:0];

initial begin

   
    figures[0]=50'b01000000000101010000011101010001010111110101010101; // head_right
    figures[1]=50'b00000011010000011101000101010100011101010101010101; //head_up
    figures[2]=50'b00000000010000010101000101110111110101010101010101; //head_left
    figures[3]=50'b01010101010001110101000101010100000111010000001101; //head_down

    figures[4]=50'b01010101010101010101010101010101010101010101010101; //body

    figures[5]=50'b00000001010001010101110101010100010101010000000101; //tail_right
    figures[6]=50'b01010101010101010101000101010000010101000000110000; //tail_up
    figures[7]=50'b01010000000101010100010101011101010101000101000000; //tail_left
    figures[8]=50'b00001100000001010100000101010001010101010101010101; //tail_down

    figures[9]=50'b00000100000000010000000100010010100010101010001010; //cherry

    figures[10]=50'd0;
    figures[11]=50'd0;
    figures[12]=50'd0;
    figures[13]=50'd0;
    figures[14]=50'd0;
    figures[15]=50'd0;
end

always @ (posedge clock_25)

	begin
		 selected_symbol <= figures[selected_figure];
	end


endmodule