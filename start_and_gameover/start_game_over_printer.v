module start_game_over_printer(X,Y, reset, start, game_over, data_start_game, data_game_over, clock_25, x_start_count,
                     y_start_count, x_game_over_count, y_game_over_count, en_start_game, en_game_over);

parameter PIXEL_DISPLAY_BIT = 9;

input[PIXEL_DISPLAY_BIT:0] X, Y;
input data_game_over, data_start_game, clock_25;
input reset;
input start, game_over;
output [8:0] x_start_count;
output [6:0] y_start_count;
output [7:0] x_game_over_count;
output [4:0] y_game_over_count;
output en_start_game, en_game_over; //values from start_game or game_over

reg[6:0] y_start_count;
reg[8:0] x_start_count;
reg[7:0] x_game_over_count;
reg[4:0] y_game_over_count;

reg en_start_game, en_game_over;

always @ (posedge clock_25 or negedge reset) begin
    
    if(~reset) begin
        en_game_over <= 1'b0;
        en_start_game <= 1'b0;
        x_game_over_count <= 8'b00000000;
        y_game_over_count <=5'b00000;
        x_start_count <= 9'b000000000;
        y_start_count <=7'b0000000;
    end
    
    else if(game_over== 1'b1)begin  //if there is a game_over it prints game over
        if(Y< 229 || Y> 251) begin 
            en_game_over <= 1'b0;
            x_game_over_count <= 8'b00000000;
            y_game_over_count <=5'b00000;

        end
        else begin
            y_game_over_count <= Y-229 ; //assign the 23 possible values until 332
            
            if(X >=228 && X <= 411)begin  
                x_game_over_count <= X - 228;
                en_game_over <= data_game_over;
            end
            else begin 
                x_game_over_count <= 8'b00000000;
                en_game_over <= 1'b0;
            end
        end
    end

    else if (start==1'b0 && game_over== 1'b0) begin //in idle state there is the start game screen
        if(Y< 207 || Y> 272) begin 
            en_start_game <= 1'b0;
            x_start_count <= 9'b000000000;
            y_start_count <=7'b0000000;

        end
        else begin
            y_start_count <= Y-207 ; //assign the 23 possible values until 332
            
            if(X >=190 && X <= 449)begin  
                x_start_count <= X - 190;
                en_start_game <= data_start_game;
            end
            else begin 
                x_start_count <= 9'b000000000;
                en_start_game <= 1'b0;
            end
        end
    end

    else begin
        en_game_over <= 1'b0;
        en_start_game <= 1'b0;
        x_game_over_count <= 8'b00000000;
        y_game_over_count <=5'b00000;
        x_start_count <= 9'b000000000;
        y_start_count <=7'b0000000;
    end

end

endmodule