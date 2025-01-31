/*This module send colors to VGA when an enable signal from an other module is activated*/


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

//if you are not in the display area it prints all balck
//if en_Start_game or en_game_over are true the vga will print the written of start game and game_over from  module start_game_over_printer
//if datarom is set to 1 it prints the game area walls and the witten TIME and SCORE from background
//if the game_enable signal  is true the vga will print the data from graphic_game
//if score_time_enable is set to 1 it prints te numbers



always @ (posedge clock_25 or negedge reset )
begin
if (~reset)begin
    red<= 10'b0000000000;
    green<=10'b0000000000;
    blue<= 10'b0000000000;
end

else if (~display_area) begin //black
      red<= 10'b0000000000;
    green<=10'b0000000000;
    blue<= 10'b0000000000;
end

else if (en_start_game) begin  //color blu
    red<=10'b0010100000;
    green<=10'b0010100000;
    blue<=10'b1101100000;
end

else if (en_game_over) begin  //color red
    red<=10'b1111110000;
    green<=10'b1001100000;
    blue<=10'b1001100000;
end


else if (datarom) begin //white
    red<= 10'b1111111111;
    green<= 10'b1111111111;
    blue<=10'b1111111111;
end 
else if (game_enable)
        
        case (color_data)
            BLACK: begin
               red<= 10'b0000000000;
					green<=10'b0000000000;
					blue<= 10'b0000000000;
            end
            GREEN: begin
                red<= 10'b0000000000;
                green<=10'b1100001111;
                blue<=10'b0000000000;
            end
            RED: begin
                red<=10'b1111110000;
                green<=10'b1001100000;
                blue<=10'b1001100000;
            end
            WHITE: begin
                  red<= 10'b1111111111;
						green<= 10'b1111111111;
						blue<=10'b1111111111;
				end
        endcase
    
else if (score_time_enable) begin //green
            red<= 10'b0000000000;
            green<=10'b1100001111;
            blue<=10'b0000000000;
    end


else begin //black
            red<= 10'b0000000000;
				green<=10'b0000000000;
				blue<= 10'b0000000000;
        end


end

endmodule