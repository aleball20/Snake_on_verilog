/*testbench for wrapper_graphic*/

`timescale 1ns/100ps

module graphic_game_tb;

parameter PIXEL_DISPLAY_BIT =9;

reg  clock_25_tb, reset_tb;
reg [PIXEL_DISPLAY_BIT:0] X_tb, Y_tb; 
reg [6:0] snake_head_x_tb, snake_head_y_tb, snake_body_x_tb, snake_body_y_tb, fruit_x_tb, fruit_y_tb;
reg [3:0] snake_length_tb;
reg en_snake_body_tb;

wire game_enable_tb, game_area_tb, semaforo_tb;
wire [1:0] color_data_tb, selected_figure_tb;
wire [6:0] x_block_tb, y_block_tb;
wire [2:0] x_local_tb, y_local_tb;



wrapper_graphic my_wrapper_graphic(
.x_block(x_block_tb),
.y_block(y_block_tb),
.x_local(x_local_tb),
.y_local(y_local_tb),
.clock_25(clock_25_tb),
.reset(reset_tb),
.X (X_tb),
.Y (Y_tb),
.snake_head_x (snake_head_x_tb),
.snake_head_y (snake_head_y_tb),
.snake_body_x (snake_body_x_tb),
.snake_body_y (snake_body_y_tb),
.fruit_x (fruit_x_tb),
.fruit_y (fruit_y_tb), 
.en_snake_body (en_snake_body_tb),
.snake_length (snake_length_tb),
.game_enable (game_enable_tb),
.color_data (color_data_tb),
.game_area(game_area_tb),
.semaforo(semaforo_tb),
.selected_figure (selected_figure_tb)
);

//clock generation
always
begin
    #20 clock_25_tb= 1'b1;
	 if(Y_tb<524)
		 if(X_tb<799)
			X_tb=X_tb +1'b1;
		else begin
			X_tb=0;
			Y_tb=Y_tb+1'b1;
		end
	else
		Y_tb=0;
		
    #20;
    clock_25_tb= 1'b0;

end


initial begin

    reset_tb=0;
    #50;  //test the IDLE state
	reset_tb=1;
	en_snake_body_tb=1;
	 snake_body_x_tb=7'b0001000;
    snake_body_y_tb=7'b0001000;
	#2;
	snake_body_x_tb=7'b0000001;
    snake_body_y_tb=7'b0000001;
	#50;
	en_snake_body_tb=0;
    snake_length_tb=4'b0010;
    snake_head_x_tb=7'b0000010;
    snake_head_y_tb=7'b0000010;
    fruit_x_tb= 7'b0000100;
    fruit_y_tb= 7'b0000100;
    #50000;
end

endmodule
