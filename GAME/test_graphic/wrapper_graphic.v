/*wrapper for the testbanch*/

module wrapper_graphic(x_block, y_block, x_local, y_local, clock_25, reset, X, Y, snake_head_x, snake_head_y, snake_body_x, snake_body_y,
fruit_x, body_found, up, right, left, down, left_tail, right_tail, up_tail, down_tail, fruit_y, snake_length, body_count, selected_figure, game_enable, game_area, color_data, selected_symbol);

parameter PIXEL_DISPLAY_BIT = 9;
parameter SNAKE_LENGTH_BIT = 7;	

input  clock_25, reset;
input [PIXEL_DISPLAY_BIT:0] X, Y; 
input [6:0] snake_head_x, snake_head_y, snake_body_x, snake_body_y, fruit_x, fruit_y;
input [3:0] snake_length;
input [SNAKE_LENGTH_BIT-1:0]body_count;

output game_enable, game_area;
output [1:0] color_data, selected_figure;

output [6:0] x_block, y_block;    
output [2:0] x_local, y_local;  
input up, down, left, right;                                
input left_tail, right_tail, up_tail, down_tail;      
output body_found;      

output [49:0] selected_symbol;

graphic_game_for_test my_graphic_game_for_test(
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


symbol my_symbol(
.clock_25(clock_25),
.selected_figure(selected_figure),
.selected_symbol(selected_symbol)
);

endmodule