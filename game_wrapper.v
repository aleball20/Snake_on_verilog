module game_wrapper (CLOCK_50, KEY0, KEY1, KEY3, VGA_HS, VGA_VS, VGA_BLANK, VGA_SYNC, VGA_CLK, VGA_R, VGA_G, VGA_B);

parameter PIXEL_DISPLAY_BIT = 10;
parameter SNAKE_LENGTH_BIT = 4;


input CLOCK_50, KEY0, KEY1, KEY3;
output VGA_HS, VGA_VS, VGA_BLANK, VGA_SYNC, VGA_CLK;
output [PIXEL_DISPLAY_BIT-1'b1:0]  VGA_R, VGA_G, VGA_B;

wire [6:0] snake_head_x, snake_head_y;
wire [6:0] snake_body_x;
wire [6:0] snake_body_y;
wire [49:0] selected_symbol;               
wire [1:0] color_data;                                 
wire [3:0] selected_figure; 
wire [7:0] score; 
wire [PIXEL_DISPLAY_BIT-1'b1:0] X, Y;
wire [SNAKE_LENGTH_BIT-1:0] snake_length; 
wire game_tik, frame_tik;                                 
wire reset;
wire game_enable; 
wire [SNAKE_LENGTH_BIT-1:0] body_count;
wire display_area;
wire datarom;
wire data;
wire clock_25;
wire [3:0] y_count;
wire [7:0]x_count;
wire [6:0] fruit_x, fruit_y;
wire up, down, left, right;


assign VGA_BLANK=1'b1;
assign VGA_SYNC= 1'b0;
assign VGA_CLK= clock_25;
assign reset = KEY0;

divisore_frequenza my_frequency_25MHz(
.clk_in(CLOCK_50),
.reset(reset),
.clock_out(clock_25)
);

game_delay my_game_delay(
    .clock_25(clock_25),
    .reset(reset),
    .frame_tik(frame_tik),
    .game_tik(game_tik)
);


graphic_game my_graphic_game(
    
    .clock_25(clock_25),
    .reset(reset),
    .X(X),
    .Y(Y),
    .snake_head_x(snake_head_x),
    .snake_head_y(snake_head_y),
    .snake_body_x(snake_body_x),
    .snake_body_y(snake_body_y),
    .fruit_x(fruit_x),
    .fruit_y(fruit_y),
	.game_enable(game_enable),
    .body_count(body_count),
    .up(up),
    .down(down),
    .left(left),
    .right(right),
    .selected_symbol(selected_symbol),
    .snake_length(snake_length),
    .color_data(color_data),
    .selected_figure(selected_figure)
);

symbol my_symbol (
.clock_25(clock_25),
.selected_figure(selected_figure), 
.selected_symbol(selected_symbol)
);
					

snake_game_fsm my_snake_game_fsm (
    .clock_25(clock_25),
    .game_tik(game_tik),
	.frame_tik(frame_tik),
    .reset(reset),
    .right_P(~KEY1),
    .left_P(~KEY3),
    .score(score),
    .snake_head_x(snake_head_x),
    .snake_head_y(snake_head_y),
    .snake_body_x(snake_body_x),
    .snake_body_y(snake_body_y),
    .fruit_x(fruit_x),
    .fruit_y(fruit_y),
    .body_count(body_count),
    .snake_length(snake_length),
    .up(up),
    .down(down),
    .left(left),
    .right(right)
);

vga_controller my_vga_controller(
.display_area(display_area),
.reset(KEY0),
.red(VGA_R),
.green(VGA_G),
.blue(VGA_B),
.datarom(datarom),
.clock_25(clock_25),
.game_enable(game_enable),
.color_data(color_data)
);


vga_tracker my_vga_tracker(
    .display_area(display_area),
	.frame_tik(frame_tik),
    .clock_25(clock_25),
    .h_sync(VGA_HS),
    .v_sync(VGA_VS),
    .reset(reset),
    .X(X),
    .Y(Y)
);

background my_background(
    .X(X),
    .Y(Y), 
    .clock_25(clock_25),
    .data(data),
    .x_count(x_count),
    .y_count(y_count),
    .datarom(datarom)
);


rom_background my_rombackground(
    .x_count(x_count),
    .y_count(y_count),
    .data(data),
    .clock_25(clock_25)
    );





endmodule