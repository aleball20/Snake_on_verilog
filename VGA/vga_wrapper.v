module vga_wrapper (clock_25,X,Y, KEY0, VGA_R, VGA_G, VGA_B, VGA_HS, VGA_VS, VGA_SYNC, VGA_BLANK, VGA_CLK, game_data, game_enable, datarom);

parameter PIXEL_DISPLAY_BIT  = 9;

input game_enable, datarom;
input [1:0] game_data;
input clock_25, KEY0;

output[PIXEL_DISPLAY_BIT:0] X,Y;
output [PIXEL_DISPLAY_BIT:0] VGA_R, VGA_G, VGA_B;
output VGA_HS, VGA_VS, VGA_BLANK, VGA_SYNC, VGA_CLK;
wire display_area;
assign VGA_BLANK=1'b1;
assign VGA_SYNC= 1'b0;
assign VGA_CLK= clock_25;

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
    .reset(KEY0),
    .X(X),
    .Y(Y)
);


endmodule