
/* To allow reading numbers, the cells are 10x10 pixels in size. Therefore, each square consists of 100 bits.
As a result, each figure is represented using 100 bits (1 bits per pixel). The reading process starts
with the MSB representing pixel in the matrix position [1][1], then proceeds to read the next pixel [2][1],
and so on. The output is a bit representing the enable color (green (1) or black(0) see VGA controller) of the selected pixel. */

module numbers (number_pixel, clock_25, number_count, selected_number);

input clock_25;
input [3:0] selected_number;   //using selcted_number i decied which number reading
input [7:0]number_count;              
output number_pixel;
reg [99:0] num[0:15];
reg [99:0] s;

initial begin

    
num[0] = 100'b1111111111100000000110000000011000000001100000000110000000011000000001100000000110000000011111111111; // 0
num[1] = 100'b0000000001000000000100000000010000000001000000000100000000010000000001000000000100000000010000000001; // 1
num[2] = 100'b1111111111000000000100000000010000000001111111111110000000001000000000100000000010000000001111111111; // 2
num[3] = 100'b1111111111000000000100000000010000000001001111111100000000010000000001000000000100000000011111111111; // 3
num[4] = 100'b1000000001100000000110000000011000000001111111111100000000010000000001000000000100000000010000000001; // 4
num[5] = 100'b1111111111100000000010000000001000000000111111111100000000010000000001000000000100000000011111111111; // 5
num[6] = 100'b1111111111100000000010000000001000000000111111111110000000011000000001100000000110000000011111111111; // 6
num[7] = 100'b1111111111000000000100000000010000000001000000000100000000010000000001000000000100000000010000000001; // 7
num[8] = 100'b1111111111100000000110000000011000000001111111111110000000011000000001100000000110000000011111111111; // 8
num[9] = 100'b1111111111100000000110000000011000000001111111111100000000010000000001000000000100000000010000000001; // 9


num[10] = 100'd0;
num[11] = 100'd0;
num[12] = 100'd0;
num[13] = 100'd0;
num[14] = 100'd0;
num[15] = 100'd0;



end


always @ (posedge clock_25)
	begin
			s<= num[selected_number];
	end

assign number_pixel= s[99-number_count];



endmodule