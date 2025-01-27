
module background (reset, X,Y, clock_25, data,x_count, y_count, datarom);

parameter PIXEL_DISPLAY_BIT = 9;

input[PIXEL_DISPLAY_BIT:0] X, Y;
input data, clock_25;
input reset;
output [7:0] x_count;
output [3:0] y_count;
output datarom; //values from ROM
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

assign rectangle_1 = (X > 52  && X < 672 && Y> 37 && Y < 43);     //on top
assign rectangle_2 = (X > 52 && X < 58 && Y> 37 && Y < 449);      //on the left
assign rectangle_4 = (X > 52 && X < 672 && Y> 442 && Y < 449);    //on bottom
assign rectangle_3 = (X > 672 && X < 658 && Y> 37 && Y < 449);     //on the right

assign game_rectangle = (rectangle_1 || rectangle_2 || rectangle_3 || rectangle_4) ? 1'b1 :1'b0;

always @ (posedge clock_25 or negedge reset) begin

    if(~reset) begin
        datarom <= 1'b0;
        y_count <= 4'b000;
        x_count <= 8'b00000000;
    end

    else if(Y< 460 || Y> 475) begin 
       datarom <= game_rectangle;
       y_count<= 4'b00000;
       x_count<= 8'b00000000;
    end
    else begin
        y_count <= Y- 460; //assegno a y_count i 16 valori possibili fino a 475
		  
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
