/*It manage the numbers score print, reading the ROM numbers and printing valeus at the correct time*/

module score_controller (clock_25, reset, sync_reset, score, X,Y, selected_score_number, score_count, en_score );


parameter PIXEL_DISPLAY_BIT   = 9;

input clock_25;
input reset;
input sync_reset;
input [6:0] score;
input  [PIXEL_DISPLAY_BIT:0] X,Y;


output reg [3:0] selected_score_number;
output reg [7:0] score_count;
output reg en_score;


reg [PIXEL_DISPLAY_BIT:0] Y_prev;
reg [6:0] score_prev;
reg [3:0]residual;      //residual is a counter which is incremented every new Y row inside the the number space
reg [3:0]dec, unit;

always @ (posedge clock_25 or negedge reset) begin

   if (~reset) begin
  
      score_count <= 8'b00000000;
      selected_score_number <= 4'b0000;
      Y_prev <=  10'd465; 
      en_score <= 1'b0;
   end

   else if (sync_reset) begin
      score_count <= 8'b00000000;
      selected_score_number <= 4'b0000;
      Y_prev <=  10'd465; 
      en_score <= 1'b0; 
   end


   else if(Y<=465 || Y>=476) begin  //if you are not inside the number space, variables are initialize
        residual <= 4'b0000;
        Y_prev <=  10'd466;
        en_score <= 1'b0;
   end
//score_enable is delayed of 2 colcks cycle, therefore the score_count is incremented 2 varibles before
   else begin
         if(X >= 447 && X <= 459) begin //printing decs
            selected_score_number <= dec;
            if(X> 447 && X<458) begin
            en_score <= 1'b1;
            score_count <= X - 448 + 10*residual;
				end
            else
               en_score <= 1'b0;
			end

         else if (X >= 462 && X <= 474) begin // printing units 
            selected_score_number <= unit;
            if(X>462 && X<473) begin
            en_score <= 1'b1;
            score_count <= X - 463 + 10*residual; 
            end 
            else 
               en_score <= 1'b0;
         end
         
         else if (Y > Y_prev) begin
            residual <= residual + 1'b1;
            Y_prev <= Y_prev + 1'b1;
         end
         
         else begin //default
            en_score <= 1'b0;
            residual <= residual;
            score_count <= 8'b00000000; 
            selected_score_number <= 4'b0000;
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