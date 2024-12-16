module background (X,Y, clock_25, data,x_count, y_count, datarom, game_area);
global_parameters param();
input[param.PIXEL_DISPLAY_BIT:0] X, Y;
input data, clock_25;
output [7:0] x_count;
output [3:0] y_count;
output datarom; //values from ROM
output game_area //playing game's area
//defining squares of the game
wire rectangle_1;
wire rectangle_2;
wire rectangle_3;
wire rectangle_4;
wire game_rectangle;

reg[3:0] y_count;
reg [7:0]x_count;
reg datarom;

/*define the game screen 620x405. It starts at the pixel X=58, Y=43 */ 

assign rectangle_1 = (X >= 53  && X <= 683 && Y>= 38 && Y < 43);     //on top
assign rectangle_2 = (X >= 53 && X <= 58 && Y>= 38 && Y < 448);      //on the left
assign rectangle_4 = (X >= 53 && X <= 683 && Y> 448 && Y <= 453);    //on bottom
assign rectangle_3 = (X > 678 && X <= 683 && Y>= 38 && Y < 448);     //on the right

assign game_rectangle = (rectangle_1 || rectangle_2 || rectangle_3 || rectangle_4) ? 1'b1 :1'b0;

assign game_area = (X>=58 && X<=678  && Y >=  43 && Y <=  448) ? 1'b1 : 1'b0;  //per algoritm grafic_game

always @ (posedge clock_25) begin
    if(Y< 460 || Y> 475) begin 
     //lo schermo ritarda in teoria di 2 cicli di clock... verifica!!
    //se dovesse avvenire si deve traslare i contatori di 3
       datarom <= game_rectangle;
       y_count<= 4'b00000;
       x_count<= 8'b00000000;
    end
    else begin
        y_count <= Y- 460; //assegno a y_count i 15 valori possibili fino a 475
		  
        if(X >=108 && X <= 170)begin //scrivo TIME:
            x_count <= X - 108;
            datarom <= data;
        end
		   else if(X >= 362 && X <= 442) begin //scrivo SCORE:
            x_count <= X - 300; //it start to read from score word (362-62) with 62 lenght of "time"
            datarom <= data;
        end
        
        else begin //non scrivo nulla
            x_count <= 8'b00000000;
            datarom <= 1'b0;
        end
        end
    end

endmodule
