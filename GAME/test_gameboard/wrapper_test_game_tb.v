
`timescale 1ns/100ps
`include "global_parameters.v"

module wrapper_test_game_tb;

reg  clock_25_tb, game_tik_tb, reset_tb;
reg right_P_tb, left_P_tb;
wire [6:0] snake_head_x_tb, snake_head_y_tb, snake_body_x_tb, snake_body_y_tb, fruit_x_tb, fruit_y_tb;
wire [3:0] snake_length_tb;
wire[5:0] score_tb;

snake_game_fsm my_snake_game_fsm(
.clock_25(clock_25_tb),
.reset(reset_tb),
.game_tik(game_tik_tb),
.right_P(right_P_tb),
.left_P(left_P_tb),
.snake_head_x(snake_head_x_tb), 
.snake_head_y(snake_head_y_tb),
.snake_body_x(snake_body_x_tb),
.snake_body_y(snake_body_y_tb),
.fruit_x(fruit_x_tb),
.fruit_y(fruit_y_tb),
.snake_length(snake_length_tb),
.score(score_tb)
);


//clock generation
always
begin
    #20 clock_25_tb= 1'b1;
    #20 clock_25_tb= 1'b0;
end

always
begin
	#15000000 game_tik_tb = 1'b0;
    #15000000 game_tik_tb =1'b1;
end

initial begin
    reset_tb=0;
    #50;  //test the IDLE state
	 reset_tb=1;
	 left_P_tb=0;
    right_P_tb=1;  //start move
    #20;
    right_P_tb =0;
     
    #30000000;
    #30000000;		//fruit eaten state EATEN_FRUIT
    
    left_P_tb=1;	//MOVE TOWARD UP
    #20;
    left_P_tb=0;

    #30000000;
	 #30000000;

    left_P_tb=1; //move and waitng to ha
    #20;
    left_P_tb=0;
	 
	 #90000000; 
end

endmodule
