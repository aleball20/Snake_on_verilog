module numbers (number_pixel, clock_25, count, selected_number);

/*per permettere la lettura dei numeri, le celle sono di dimensione 10x10 pixel. Quindi ogni quadrato ha 100 bit.
di conseguenza ogni figura è rappresentata con 200 bit (2 per ogni pixel). La lettura avviene partendo  
dalla coppie dei 2 MSB che rappresentano il pixel [1][1], per poi procedere leggendo il pixel successivo [2][1]
e cosi via. In uscita si ha un vettore di 2 bit raffigurante il colore del pixel selezionato */
input clock_25;
input [4:0] selected_number;   //Tramite selective decido quale numero prelevare dalla ROM
input [7:0]count;              
output [1:0]number_pixel;
reg [199:0] num[0:9];
reg [199:0] s;

initial begin

    
num[0] = 200'b00001111111111110000001100000000000011001100000000000000001111000000000000000011110000000000000000111100000000000000001111000000000000000011110000000000000000110011000000000000110000001111111111110000; // 0
num[1] = 200'b00000000001100000000000000001111000000000000001100110000000000001100001100000000000000000011000000000000000000110000000000000000001100000000000000000011000000000000000000110000000000000000001100000000;//1
num[2] = 200'b00000011111111110000000011000000000011000011000000000000110000000000000000110000000000000000110000000000000000110000000000000000110000000000000000110000000000000000110000000000000000111111111111111111; // 2
num[3] = 200'b000011111111111100000000000000000000110000000000000000000011000000000000000011111111100000001111111111100000000000000000000011001100000000000011000000000000110000001111111111110000; // 3
num[4] = 200'b11001100000000000000011001100000000000011001100000000000011111111111111100000011111111110000000000000000001100000000000000011000000000000110000001111111111110000; // 4
num[5] = 200'b11111111111111110000000001100000000000000011000000000000001111111111110000001111111111110000000000000000000000000000000000000011000000000000001100000000000001111111111111111110000; // 5
num[6] = 200'b00001111111111110000001100000000000011001100000000000000001111000000000000000011111111111100000011110000001100000011001100000000000011000000000000110000001111111111110000; // 6
num[7] = 200'b11111111111111111111111111111111100000000000001100000000000001100000000000011000000000000011000000000000001100000000000001100000000000011000000000000011000000000000011000000; // 7
num[8] = 200'b00001111111111110000001100000000000011001100000000000000001111000000000000000011111111111110000001111111111110000011001100000000000011000000000000110000001111111111110000; // 8
num[9] = 200'b00001111111111110000001100000000000011001100000000000000001111000000000000000011111111111110000001111111111110000000000000000000011001100000000000110000001111111111110000; // 9

end


always @ (posedge clock_25)
	begin
		s<= num[selected_number];
	end

assign number_pixel[0] = s[199-count];
assign number_pixel[1] = s[198-count];



endmodule