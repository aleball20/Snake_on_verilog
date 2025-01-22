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
wire [6:0] score; 
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
wire number_pixel;
wire time_tik;
wire score_time_enable, score_enable, time_enable ;
wire [3:0] selected_score_number, selected_time_number, selected_number;
wire [7:0] score_count, time_count, number_count;

assign selected_number = selected_score_number | selected_time_number;
assign number_count = score_count | time_count;
assign score_time_enable = score_enable | time_enable;
assign VGA_BLANK=1'b1;
assign VGA_SYNC= 1'b0;
assign VGA_CLK= clock_25;
assign reset = KEY0;

clock_25_divisor my_frequency_25MHz(
.clk_in(CLOCK_50),
.reset(reset),
.clock_25(clock_25)
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
.score_time_enable(score_time_enable),
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


numbers my_numbers(
    .number_pixel(number_pixel),
    .clock_25(clock_25),
    .number_count(number_count),
    .selected_number (selected_number)
);

score_controller my_score_controller(
    .clock_25(clock_25),
    .reset(reset), 
    .score(score), 
    .score_enable(score_enable), 
    .X(X),
    .Y(Y), 
    .selected_score_number(selected_score_number), 
    .score_count(score_count), 
    .number_pixel(number_pixel)
);

time_controller my_time_controller(
.clock_25(clock_25),
.reset(reset),
.time_tik(time_tik), 
.number_pixel(number_pixel), 
.selected_time_number(selected_time_number), 
.time_enable(time_enable), 
.time_count(time_count), 
.X(X),
.Y(Y)
);

time_tik_divisor my_time_tik_divisor(
    .clock_25 (clock_25),
    .reset (reset), 
    .time_tik(time_tik)
);

endmodule