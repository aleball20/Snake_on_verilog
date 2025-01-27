
module vga_controller (display_area, reset, red, green, blue, datarom, clock_25, score_time_enable,
                            en_start_game, en_game_over, game_enable,  color_data);

parameter PIXEL_DISPLAY_BIT = 10;
parameter BLACK = 2'b00;
parameter GREEN = 2'b01;
parameter RED   = 2'b10;
parameter WHITE = 2'b11;

output [PIXEL_DISPLAY_BIT-1'b1:0] red, green, blue;
input reset, datarom, clock_25, score_time_enable, game_enable, display_area;
input en_start_game, en_game_over;
input [1:0] color_data;
reg [PIXEL_DISPLAY_BIT-1'b1:0] red, green, blue;

//if the gma:enable signal which come from the gameblock is true the vga will print the data from gameblock, in default it prints from the sram
//if the display area isn't enabled, everything black; if not, as the main priority it will do the gamedata or instead it would read the fixed datarom

always @ (posedge clock_25 or negedge reset )
begin
if (~reset)begin
    red<= 10'h000;
    green<=10'h000;
    blue<= 10'h000;
end

else if (~display_area) begin
    red<=10'h000;
    green<=10'h000;
    blue<=10'h000;
end

else if (en_start_game) begin  //color blu
    red<=10'h4a0;
    green<=10'hd40;
    blue<=10'hf60;
end

else if (en_game_over) begin  //color red
    red<=10'hff0;
    green<=10'h660;
    blue<=10'h660;
end


else if (datarom) begin //white
    red<= 10'hfff;
    green<= 10'hfff;
    blue<=10'hfff;
end 
else if (game_enable)
        
        case (color_data)
            BLACK: begin
                red<= 10'h0;
                green<=10'h0;
                blue<= 10'h0;
            end
            GREEN: begin
                red<= 10'h800;
                green<=10'hf0f;
                blue<=10'h0;
            end
            RED: begin
                red<=10'hff0;
                green<=10'h660;
                blue<=10'h660;
            end
            WHITE: begin
                red<= 10'hfff;
                green<=10'hfff;
                blue<= 10'hfff;
            end
        endcase
    
else if (score_time_enable) begin //green
            red<= 10'h800;
            green<=10'hf0f;
            blue<=10'h0;
    end


else begin //black
            red<=10'h000;
            green<= 10'h000;
            blue<= 10'h000;
        end


end

endmodule