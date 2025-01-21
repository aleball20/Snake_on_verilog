module score_controller (clock_25, reset, score, score_enable , X,Y, selected_number, _number_count, number_pixel )


parameter PIXEL_DISPLAY_BIT   = 9;

input clock_25;
input reset;
input score;
input number_pixel;
input  [PIXEL_DISPLAY_BIT:0] X,Y;

output reg score_enable;
output reg [3:0] selected_number;
output reg [7:0] number_count;

reg [3:0]residual

always @ (posedge clock_25) begin
    if(Y< 460 || Y> 475) begin  //if you are not inside the number space, variables are initialize
        score_enable <= 1'b0;
        number_count <= 8'b00000000;
        residual <= 4'b0000;
    end
    else begin
         if(X >= 446 && X <= 455) begin //scrivo la decina
            number_count <= X - 446 + 10*residual;
            score_enable <= number_pixel;
         end

         else if (X >= 458 && X <= 467) begin // scrivo l'unità
            number_count <= X - 458 + 10*residual;
            score_enable <= number_pixel;
         end

         else begin //default
            number_count <= number_count; 
            score_enable <= 1'b0;  // the vga controller will print black in the midspace between the 2 numbers
         end

    residual <= residual + 1'b1;
    end
    //SCRIVERE ALTRO BLCOCCO PER CONTROLLARE IL SELECTE NUMBER
end






endmodule