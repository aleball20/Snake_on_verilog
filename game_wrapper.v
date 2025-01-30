module game_wrapper (CLOCK_50, KEY0, KEY2, KEY3, SW17, SW16, SW15, VGA_HS, VGA_VS, VGA_BLANK, VGA_SYNC, VGA_CLK, VGA_R, VGA_G, VGA_B);

parameter PIXEL_DISPLAY_BIT = 10;
parameter SNAKE_LENGTH_BIT = 6;


input CLOCK_50, KEY0, KEY2, KEY3, SW17, SW16, SW15;
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
wire data_start_game, data_game_over;
wire data;
wire clock_25;
wire [3:0] y_count;
wire [7:0]x_count;
wire [6:0] fruit_x, fruit_y;
wire up, down, left, right;
wire number_pixel;
wire time_tik;
wire sync_reset;
wire start, game_over;
wire en_score, en_time;
wire [3:0] selected_score_number, selected_time_number, selected_number;
wire [7:0] score_count, time_count, number_count;
wire [8:0] x_start_count;
wire [6:0] y_start_count;
wire [7:0] x_game_over_count;
wire [4:0] y_game_over_count;
wire en_start_game, en_game_over; //values from start_game or game_over

assign selected_number = selected_score_number | selected_time_number;
assign number_count = score_count | time_count;

assign VGA_BLANK=1'b1;
assign VGA_SYNC= 1'b0;
assign VGA_CLK= clock_25;
assign reset = KEY0;

clock_25_divisor my_frequency_25MHz(
.clk_in(CLOCK_50),
.reset(reset),
.clock_25(clock_25)
);

game_delay_fsm my_game_delay_fsm(
    .clock_25(clock_25),
    .reset(reset),
    .frame_tik(frame_tik),
    .game_tik(game_tik),
	.start(start),
    .SW17(SW17),
    .SW16(SW16),
    .SW15(SW15)
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
    .right_P(~KEY2),
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
    .right(right),
    .start(start),
    .game_over(game_over),
    .sync_reset(sync_reset)
);

vga_controller my_vga_controller(
.display_area(display_area),
.reset(KEY0),
.red(VGA_R),
.green(VGA_G),
.blue(VGA_B),
.datarom(datarom),
.en_game_over(en_game_over),
.en_start_game(en_start_game),
.clock_25(clock_25),
.game_enable(game_enable),
.score_time_enable(number_pixel & (en_time | en_score)),
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
    .reset(reset),
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
    .X(X),
    .Y(Y), 
    .en_score(en_score),
    .selected_score_number(selected_score_number), 
    .score_count(score_count), 
    .sync_reset(sync_reset)
);

time_controller my_time_controller(
    .clock_25(clock_25),
    .reset(reset),
    .time_tik(time_tik), 
    .selected_time_number(selected_time_number), 
    .time_count(time_count), 
    .en_time(en_time),
    .X(X),
    .Y(Y),
    .sync_reset(sync_reset)
);

time_tik_divisor my_time_tik_divisor(
    .clock_25 (clock_25),
    .reset (reset), 
	 .sync_reset(sync_reset),
    .time_tik(time_tik),
    .start(start)
);

rom_game_over my_rom_game_over(
    .x_count(x_game_over_count),
    .y_count(y_game_over_count),
    .data_game_over(data_game_over),
    .clock_25(clock_25)
    );

rom_start_game my_start_game(
    .x_count(x_start_count),
    .y_count(y_start_count),
    .data_start_game(data_start_game),
    .clock_25(clock_25)
    );

start_game_over_printer my_start_game_over_printer(
	.X(X),
	.Y(Y),
	.reset(reset),
	.start(start),
	.game_over(game_over),
	.data_start_game(data_start_game),
	.data_game_over(data_game_over),
	.clock_25(clock_25),
	.x_start_count(x_start_count),
	.y_start_count(y_start_count),
	.x_game_over_count(x_game_over_count),
	.y_game_over_count(y_game_over_count),
	.en_start_game(en_start_game),
	.en_game_over(en_game_over)
	);

endmodule