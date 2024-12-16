`include "global_parameters.v"


module game_wrapper (CLOCK_50, KEY0, KEY2, KEY3, VGA_HS, VGA_VS, VGA_BLANK, VGA_SYNC, VGA_CLK, VGA_R, VGA_G, VGA_B);

input CLOCK50, KEY0, KEY2, KEY3;
input clock_25;
output VGA_HS, VGA_VS, VGA_BLANK, VGA_SYNC, VGA_CLK;
output [`PIXEL_DISPLAY_BIT:0]  VGA_R, VGA_G, VGA_B;

wire [6:0] snake_head_x, snake_head_y;
wire [6:0] snake_body_x [0:`SNAKE_LENGHT_MAX];
wire [6:0] snake_body_y [0:`SNAKE_LENGHT_MAX];
wire [49:0] selected_symbol;               
wire [1:0] game_data;                                 
wire [1:0] selected_figure; 
wire [7:0] score; 
wire [`PIXEL_DISPLAY_BIT:0] X, Y;
wire [`SNAKE_LENGTH_BIT-1:0] snake_length;
wire en_snake_body; 
wire game_tik, frame_tik;                                 
wire reset;
wire game_enable; 
wire display_area;
wire datarom;
wire data;
wire [3:0] y_count;
wire [7:0]x_count;


assign VGA_BLANK=1'b1;
assign VGA_SYNC= 1'b0;
assign VGA_CLK= clock_25;

divisore_frequenza my_frequency_25MHz #(1)(
.clk_in(CLOCK_50),
.reset(KEY0),
.clock_out(clock_25)
);


divisore_frequenza my_frequency_30MHz #(1)(
.clk_in(frame_tik),
.reset(KEY0),
.clock_out(game_tik)
);


graphic_game my_graphic_game (
    
    .clock_25(clock_25),
    .reset(reset),
    .X(X),
    .Y(Y);
    .snake_head_x(snake_head_x),
    .snake_head_y(snake_head_y),
    .snake_body_x(snake_body_x),
    .snake_body_y(snake_body_y),
    .fruit_x(fruit_x),
    .fruit_y(fruit_y),
    .selected_symbol(selected_symbol),
    .en_snake_body(en_snake_body),
    .snake_length(snake_length),
    .game_enable(game_enable),
    .game_data(game_data),
    .selected_figure(selected_figure)
);

					

snake_game my_snake_game (
    .clock_25(clock_25),
    .game_tik(game_tik),
    .display_area(display_area),
    .reset(reset),
    .right_P(KEY2),
    .left_P(KEY3),
    .score(score),
    .en_snake_body(en_snake_body),
    .snake_head_x(snake_head_x),
    .snake_head_y(snake_head_y),
    .snake_body_x(snake_body_x),
    .snake_body_y(snake_body_y),
    .fruit_x(fruit_x),
    .fruit_y(fruit_y),
    .snake_length(snake_length)
);

vga_controller my_vga_controller(
.display_area(display_area),
.red(VGA_R),
.green(VGA_G),
.blue(VGA_B),
.datarom(datarom),
.clock_25(clock_25),
.game_enable(game_enable),
.game_data(game_data)
);


vga_tracker my_vga_tracker(
    .display_area(display_area),
    .clock_25(clock_25),
    .h_sync(VGA_HS),
    .v_sync(VGA_VS),
    .reset(KEY),
    .X(X),
    .Y(Y)
);

background my_background(
    .X(X),
    .Y(Y), 
    .clock_25(clock_25),
    .data (data),
    .x_count(x_count),
    .y_count(y_count),
    .datarom(datarom),
);


rom_background my_rombackground(
    .x_count(X_count),
    .y_count(y_count),
    .data(data),
    .clock_25(clock_25)
    );





endmodule