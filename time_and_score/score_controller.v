module score_controller (clock_25, reset, sync_reset, score, score_enable , X,Y, selected_score_number, score_count, number_pixel );


parameter PIXEL_DISPLAY_BIT   = 9;

input clock_25;
input reset;
input sync_reset;
input [6:0] score;
input number_pixel;
input  [PIXEL_DISPLAY_BIT:0] X,Y;

output reg score_enable;
output reg [3:0] selected_score_number;
output reg [7:0] score_count;


reg [PIXEL_DISPLAY_BIT:0] Y_prev;
reg [6:0] score_prev;
reg [3:0]residual;
reg [3:0]dec, unit;

always @ (posedge clock_25 or negedge reset) begin

   if (~reset) begin
      score_enable <= 1'b0;
      score_count <= 8'b00000000;
      selected_score_number <= 4'b0000;
      Y_prev <=  10'd465; 
   end

   else if (sync_reset) begin
      score_enable <= 1'b0;
      score_count <= 8'b00000000;
      selected_score_number <= 4'b0000;
      Y_prev <=  10'd465;  
   end


   else if(Y<=465 || Y>=476) begin  //if you are not inside the number space, variables are initialize
        score_enable <= 1'b0;
        residual <= 4'b0000;
        Y_prev <=  10'd466;
   end

   else begin
         if(X >= 445 && X <= 456) begin //scrivo la decina
            selected_score_number <= dec;
            score_enable <= number_pixel;
            if(X<=454)
            score_count <= X - 445 + 10*residual;
            end

         else if (X >= 460 && X <= 471) begin // scrivo l'unitÃ 
            selected_score_number <= unit;
            score_enable <= number_pixel;   
            if(X<=469)  
            score_count <= X - 460 + 10*residual;  
         end
         
         else if (Y > Y_prev) begin
            residual <= residual + 1'b1;
            Y_prev <= Y_prev + 1'b1;
         end
         
         else begin //default
            residual <= residual;
            score_count <= 8'b00000000; 
            selected_score_number <= 4'b0000;
            score_enable <= 1'b0;  // the vga controller will print black in the midspace between the 2 numbers
         end
    end
   
end


always @ (posedge clock_25 or negedge reset) begin  //unit and decimal part assignmet

   if(~reset) begin
      dec <= 4'b0000;
      unit <= 4'b000;
      score_prev <= 7'b0000000;
	end

   
   else if(sync_reset) begin
      dec <= 4'b0000;
      unit <= 4'b000;
      score_prev <= 7'b0000000;
	end

   else if(score > score_prev) begin
      score_prev <= score;
      if (unit == 4'd9) begin
         unit <= 4'd0;
         if(dec == 4'd9)
            dec <=4'd0;
         else 
            dec <= dec +1'b1;    
      end
      else begin
         unit <= unit + 1'b1;
         dec <= dec;  
      end
   end

end

endmodule