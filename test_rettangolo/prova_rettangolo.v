module prova_rettangolo (X,Y, clock_25, datarom);
input[9:0] X, Y;
input clock_25;
output datarom;
wire rectangle_1;
wire rectangle_2;
wire rectangle_3;
wire rectangle_4;
wire game_rectangle;

reg datarom;

//define the game screen
assign rectangle_1 = (X >= 53  && X < 683 && Y>= 38 && Y < 43);     //on top
assign rectangle_2 = (X >= 53 && X < 58 && Y>= 38 && Y < 448); //on the left
assign rectangle_4 = (X >= 53 && X < 683 && Y>= 448 && Y < 453); //on bottom
assign rectangle_3 = (X >= 678 && X < 683 && Y>= 38 && Y < 448); //on the right

assign game_rectangle = (rectangle_1 || rectangle_2 || rectangle_3 || rectangle_4) ? 1'b1 :1'b0;

always @ (posedge clock_25)
 datarom <= game_rectangle;

endmodule
