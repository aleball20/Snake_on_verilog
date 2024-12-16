`timescale 1ns/100ps
module vga_sram_tb;

reg datasram_tb,  clk_tb, reset_tb;
wire [1:0]game_data_tb;
wire [9:0] red_tb, green_tb, blue_tb;
wire game_enable_tb, h_sync_tb, v_sync_tb;

vga_wrapper my_vga_wrapper(
    .CLOCK_50(clk_tb),
    .KEY(reset_tb),
    .VGA_R(red_tb), 
    .VGA_G(green_tb),
    .VGA_B(blue_tb), 
    .VGA_HS(h_sync_tb),
    .VGA_VS(v_sync_tb),
    .game_enable(game_enable_tb),
    .game_data(game_data_tb)
);

//clock generation
always
begin
    #10 clk_tb= 1'b1;
    #10 clk_tb= 1'b0;
   
end

//test stimul
initial begin
    reset_tb= 1'b0;
    #10;
    reset_tb=1'b1;

    #10000;
    

end

endmodule