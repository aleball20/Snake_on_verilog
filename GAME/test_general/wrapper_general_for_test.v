/*Wrapper that combines the two test modules*/

module wrapper_general_for_test(collision_detected, clock_25, right_sync, left_sync, right_register, left_register, right, left, down, up, game_tik ,current_state, next_state, frame_tik, right_P, left_P, snake_head_x, snake_head_y, snake_body_x, 
snake_body_y, fruit_x, fruit_y, snake_length, score, display_area, VGA_HS, VGA_VS, reset, X, Y, game_enable, game_area, semaforo, color_data,
selected_figure, x_block, y_block, x_local, y_local);

parameter PIXEL_DISPLAY_BIT = 9;
parameter SNAKE_LENGTH_BIT = 6;

input clock_25, reset;
input right_P, left_P;
output [PIXEL_DISPLAY_BIT:0] X,Y; 
output [6:0] snake_head_x, snake_head_y, snake_body_x, snake_body_y, fruit_x, fruit_y;
output [3:0] snake_length;
output VGA_HS, VGA_VS;
output frame_tik; 
output game_tik;
output display_area;
output collision_detected;
output [7:0] score;   
output [2:0] current_state, next_state;
output right, left, up, down, right_sync, left_sync, right_register, left_register;


output game_enable, game_area, semaforo;
output [1:0] color_data, selected_figure;
output [6:0] x_block, y_block;    
output [2:0] x_local, y_local;    

wire [49:0] selected_symbol;
wire [SNAKE_LENGTH_BIT-1:0]body_count;

wrapper_graphic my_wrapper_graphic(
.x_block(x_block),
.y_block(y_block),
.x_local(x_local),
.y_local(y_local),
.clock_25(clock_25),
.reset(reset),
.X (X),
.Y (Y),
.snake_head_x (snake_head_x),
.snake_head_y (snake_head_y),
.snake_body_x (snake_body_x),
.snake_body_y (snake_body_y),
.fruit_x (fruit_x),
.fruit_y (fruit_y), 
.body_count(body_count),
.snake_length (snake_length),
.game_area (game_area),
.game_enable (game_enable),
.color_data (color_data),
.semaforo (semaforo),
.selected_figure (selected_figure)									    
);

wrapper_snake_game my_wrapper_snake_game(
.clock_25(clock_25),
.reset(reset),
.body_count(body_count),
.right_P(right_P),
.left_P(left_P),
.X(X),
.Y(Y),
.snake_head_x(snake_head_x),
.snake_head_y(snake_head_y),
.snake_body_x(snake_body_x),
.snake_body_y(snake_body_y),
.fruit_x(fruit_x),
.fruit_y(fruit_y),
.snake_length(snake_length),
.VGA_HS(VGA_HS),
.VGA_VS(VGA_VS),
.frame_tik(frame_tik), 
.game_tik(game_tik),
.display_area(display_area),
.collision_detected(collision_detected),
.score(score),  
.current_state(current_state),
.next_state(next_state),
.right(right),
.left(left),
.up(up), 
.down(down),
.right_sync(right_sync),
.left_sync(left_sync), 
.right_register(right_register), 
.left_register(left_register)
);
endmodule