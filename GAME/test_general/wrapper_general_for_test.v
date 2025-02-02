/*Wrapper that combines the two test modules*/

module wrapper_general_for_test(collision_detected, clock_25, right_sync, left_sync, right_register, left_register, right, left, down, up, game_tik ,current_state, next_state, right_P, left_P, snake_head_x, snake_head_y, snake_body_x, 
snake_body_y, fruit_x, fruit_y, snake_length, score, display_area, VGA_HS, VGA_VS, reset, X, Y, game_enable, game_area, semaforo, color_data,
selected_figure, selected_symbol, right_tail, left_tail, up_tail, down_tail, x_block, y_block, x_local, y_local);

parameter PIXEL_DISPLAY_BIT = 9;
parameter SNAKE_LENGTH_BIT = 7;

input clock_25, reset;
input right_P, left_P;
output [PIXEL_DISPLAY_BIT:0] X,Y; 
output [6:0] snake_head_x, snake_head_y, snake_body_x, snake_body_y, fruit_x, fruit_y;
output [3:0] snake_length;
output VGA_HS, VGA_VS;
output game_tik;
output display_area;
output collision_detected;   
output [2:0] current_state, next_state;
output right, left, up, down, right_sync, left_sync, right_register, left_register;
output right_tail, left_tail, up_tail, down_tail;
output[6:0] score;  

output game_enable, game_area, semaforo;
output [1:0] color_data, selected_figure;
output [6:0] x_block, y_block;    
output [2:0] x_local, y_local;    

output [49:0] selected_symbol;
wire [SNAKE_LENGTH_BIT-1:0]body_count;

wrapper_graphic my_wrapper_graphic(
.x_block(x_block),
.y_block(y_block),
.x_local(x_local),
.y_local(y_local),
.clock_25(clock_25),
.reset(reset),
.body_count(body_count),
.X (X),
.Y (Y),
.snake_head_x (snake_head_x),
.snake_head_y (snake_head_y),
.snake_body_x (snake_body_x),
.snake_body_y (snake_body_y),
.fruit_x (fruit_x),
.fruit_y (fruit_y), 
.selected_symbol (selected_symbol),
.snake_length (snake_length),
.game_area (game_area),
.game_enable (game_enable),
.color_data (color_data),
.selected_figure (selected_figure),
.body_found(body_found),
.up(up),
.down(down), 
.left(left),
.right(right),
.left_tail(left_tail),
.right_tail(right_tail),
.up_tail(up_tail),
.down_tail(down_tail)								    
);

wrapper_snake_game my_wrapper_snake_game(
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
.X(X),
.Y(Y),
.next_state(next_state)
);
endmodule