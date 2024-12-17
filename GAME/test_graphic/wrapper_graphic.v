
module wrapper_graphic(x_block, y_block, x_local, y_local, clock_25, reset, X, Y, snake_head_x, snake_head_y, snake_body_x, snake_body_y,
fruit_x, fruit_y, snake_length, en_snake_body, selected_figure, game_enable, game_area, game_data);

paremeter PIXEL_DISPLAY_BIT = 9;

input  clock_25, reset;
input [PIXEL_DISPLAY_BIT:0] X, Y; 
input [6:0] snake_head_x, snake_head_y, snake_body_x, snake_body_y, fruit_x, fruit_y;
input [3:0] snake_length;
input en_snake_body;

output game_enable, game_area;
output [1:0] game_data, selected_figure;

output [6:0] x_block, y_block;    
output [2:0] x_local, y_local;    

wire [49:0] selected_symbol;

graphic_game_for_test my_graphic_game_for_test(
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
.selected_symbol (selected_symbol),
.en_snake_body (en_snake_body),
.snake_length (snake_length),
.game_area (game_area),
.game_enable (game_enable),
.game_data (game_data),
.selected_figure (selected_figure)
);


symbol my_symbol(
.clock_25(clock_25),
.selected_figure(selected_figure),
.selected_symbol(selected_symbol)
);

endmodule