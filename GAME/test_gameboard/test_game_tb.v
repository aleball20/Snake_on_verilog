
`timescale 1ns/100ps


module test_game_tb;

parameter PIXEL_DISPLAY_BIT = 9;

reg  clock_25_tb, reset_tb;
reg right_P_tb, left_P_tb;

wire [6:0] snake_head_x_tb, snake_head_y_tb, snake_body_x_tb, snake_body_y_tb, fruit_x_tb, fruit_y_tb;
wire [3:0] snake_length_tb;
wire[6:0] score_tb;
wire VGA_HS_tb, VGA_VS_tb;
wire frame_tik_tb;
wire game_tik_tb;
wire collision_detected_tb;
wire right_tb, left_tb, up_tb, down_tb, right_sync_tb, left_sync_tb, right_register_tb, left_register_tb;
wire display_area_tb;
wire [PIXEL_DISPLAY_BIT:0] X_tb,Y_tb; 
wire [2:0] next_state_tb, current_state_tb;
wire collision_fruit_tb, fruit_eaten_tb, start_tb, game_over_tb;
 

wrapper_snake_game my_wrapper_snake_game(
.clock_25(clock_25_tb),
.reset(reset_tb),
.game_tik(game_tik_tb),
.frame_tik(frame_tik_tb),
.right_P(right_P_tb),
.left_P(left_P_tb),
.snake_head_x(snake_head_x_tb), 
.snake_head_y(snake_head_y_tb),
.snake_body_x(snake_body_x_tb),
.snake_body_y(snake_body_y_tb),
.fruit_x(fruit_x_tb),
.fruit_y(fruit_y_tb),
.snake_length(snake_length_tb),
.score(score_tb),
.collision_detected(collision_detected_tb),
.display_area(display_area_tb),
.VGA_HS (VGA_HS_tb), 
.VGA_VS(VGA_VS_tb),
.next_state(next_state_tb),
.current_state(current_state_tb),
.right(right_tb),
.left(left_tb),
.up(up_tb),
.down(down_tb),
.right_sync(right_sync_tb),
.left_sync(left_sync_tb),
.right_register(right_register_tb),
.left_register(left_register_tb),
.collision_fruit(collision_fruit_tb),
.fruit_eaten(fruit_eaten_tb),
.start(start_tb),
.game_over(game_over_tb),
.X(X_tb),
.Y(Y_tb)
);


//clock generation
always
begin
    #20 clock_25_tb= 1'b1;
    #20 clock_25_tb= 1'b0;
end

initial begin
    reset_tb=0;
	 left_P_tb=0;
	 right_P_tb=0;
    #50;  //test the IDLE state
	 reset_tb=1;
     left_P_tb=0;
     right_P_tb=0; 
     #1000000;
     right_P_tb =1;
	  #50
	  right_P_tb =0;
	  #10000;
	   right_P_tb =1;
       #50
       right_P_tb =0;
	  #100000000;
	   right_P_tb =1;
       #50
       right_P_tb =0;
		#1000000000;
        #1000000;

end

endmodule
