module background_wrapper (CLOCK_50, KEY, VGA_R, VGA_G, VGA_B, VGA_HS, VGA_VS, VGA_SYNC, VGA_BLANK, VGA_CLK);
input CLOCK_50, KEY;
//input game_enable; //to add in the module in future
//input [1:0] game_data; //to add in the module in future
output [9:0] VGA_R, VGA_G, VGA_B;
output VGA_HS, VGA_VS, VGA_BLANK, VGA_SYNC, VGA_CLK;
wire clock_25, display_area;
wire [9:0] X,Y;
wire [7:0]x_count;
wire [3:0]y_count;
wire data, datarom;

divisore_frequenza my_frequency_25MHz #(1)(
.clk_in(CLOCK_50),
.reset(KEY),
.clock_out(clock_25)
);

vga_wrapper my_vga_wrapper(
    .clock_25(clock_25), 
	.X(X),
	.Y(Y),
    .KEY(KEY),
    .VGA_R (VGA_R),
   .VGA_G (VGA_G),
    .VGA_B(VGA_B),
    .VGA_HS (VGA_HS),
    .VGA_VS (VGA_VS),
    .VGA_SYNC (VGA_SYNC), 
    .VGA_BLANK(VGA_BLANK), 
    .VGA_CLK (VGA_CLK), 
    .game_data(2'b00), //to change in the future module
    .game_enable (1'b0), //to change in the future module
    .datarom (datarom));

background my_background(
    .clock_25(clock_25),
    .X (X),
    .Y (Y),
    .data (data),
    .y_count (y_count),
	.x_count(x_count), 
    .datarom (datarom));

rom_background my_rom_background(
    .clock_25(clock_25),
    .x_count(x_count),
    .y_count (y_count), 
    .data(data)
);

    
endmodule