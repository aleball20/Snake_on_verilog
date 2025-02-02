/*wrapper for the testbanch*/

module wrapper_snake_game(score_count, selected_score_number, en_score, en_time,  time_tik, selected_time_number, time_count, number_pixel, collision_fruit, sync_reset, fruit_eaten, start, game_over, body_count, collision_detected, clock_25, right_sync, left_sync, right_register, left_register, right, left, down, up, game_tik ,current_state, next_state, right_P, left_P, snake_head_x, snake_head_y, snake_body_x, 
                            right_tail, left_tail, up_tail, down_tail, snake_body_y, fruit_x, fruit_y, snake_length, score, display_area, VGA_HS, VGA_VS, reset, X, Y);

parameter PIXEL_DISPLAY_BIT = 9;
parameter SNAKE_LENGTH_BIT = 7;									 

input clock_25, reset;
input right_P, left_P;

output[PIXEL_DISPLAY_BIT:0] X,Y; 
output [6:0] snake_head_x, snake_head_y, snake_body_x, snake_body_y, fruit_x, fruit_y;
output [SNAKE_LENGTH_BIT-1:0] snake_length;
output VGA_HS, VGA_VS;
output sync_reset;

output collision_fruit, fruit_eaten, start, game_over;
output game_tik;
output display_area;
output collision_detected;
output [6:0] score;   
output [2:0] current_state, next_state;
output right, left, up, down, right_sync, left_sync, right_register, left_register;
output right_tail, left_tail, up_tail, down_tail;
output [SNAKE_LENGTH_BIT-1:0]body_count;

output number_pixel;
output en_time, en_score;
output [3:0] selected_time_number, selected_score_number;
output [7:0] time_count, score_count;
output time_tik;

wire frame_tik; 

snake_game_fsm_for_test my_snake_game_fsm_for_test(
    .clock_25(clock_25),
    .reset(reset),
    .game_tik(game_tik),
    .right_P(right_P),
    .left_P(left_P),
    .snake_head_x(snake_head_x), 
    .snake_head_y(snake_head_y),
    .snake_body_x(snake_body_x),
    .snake_body_y(snake_body_y),
    .fruit_x(fruit_x),
    .fruit_y(fruit_y),
    .snake_length(snake_length),
    .score(score),
    .current_state(current_state),
    .collision_detected(collision_detected),
	.body_count(body_count),
    .right(right),
    .left(left),
    .up(up),
    .down(down),
	 .up_tail(up_tail), 
	.down_tail(down_tail), 
	.left_tail(left_tail), 
	.right_tail(right_tail),
	 .right_sync(right_sync),
	 .left_sync(left_sync),
	 .right_register(right_register),
	 .left_register(left_register),
     .sync_reset(sync_reset),
     .start(start),
     .game_over(game_over),
     .fruit_eaten(fruit_eaten),
     .collision_fruit(collision_fruit),
    .next_state(next_state)
);

vga_tracker my_vga_tracker(
    .display_area(display_area),
    .clock_25(clock_25),
	.frame_tik(frame_tik),
    .h_sync(VGA_HS),
    .v_sync(VGA_VS),
    .reset(reset),
    .X(X),
    .Y(Y)
);



game_delay_fsm my_game_delay_fsm(
    .clock_25(clock_25),
    .reset(reset),
    .frame_tik(frame_tik),
    .game_tik(game_tik),
	.start(start),
    .SW17(0),
    .SW16(1),
    .SW15(0)
);



 
time_controller my_time_controller(
    .clock_25(clock_25),
    .reset(reset),
    .sync_reset(sync_reset), 
    .time_tik(time_tik), 
    .en_time(en_time), 
    .X(X),
    .Y(Y), 
    .selected_time_number(selected_time_number), 
    .time_count(time_count)
);

numbers my_numbers(
    .clock_25(clock_25),
    .selected_number(selected_time_number | selected_score_number),   //Tramite selective decido quale numero prelevare dalla ROM
    .number_count(time_count | score_count),              
    .number_pixel(number_pixel)
);

time_tik_divisor my_time_tik_divisor(
    .clock_25(clock_25),
    .sync_reset(sync_reset),
    .start(start),
    .reset(reset),
    .time_tik(time_tik)
    ); 


score_controller my_score_controller(
    .clock_25(clock_25),
    .reset (reset), 
    .sync_reset(sync_reset), 
    .score (score), 
    .en_score (en_score), 
    .X (X),
    .Y (Y), 
    .selected_score_number (selected_score_number), 
    .score_count (score_count)
);
endmodule