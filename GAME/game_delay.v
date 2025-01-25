/* Questo modulo genera il game_tik ovvero un impulso che indica al serpente quando muoversi.
l'impulso avrÃ  una frequenza dimezzata rispetto alla frequenza dello schermo sulla VGA.
passando da 60Hz a 30Hz*/

module game_delay(clock_25, reset, frame_tik, game_tik);

//PARAMETER
	parameter a = 2'b00;
	parameter b = 2'b01;
	parameter c = 2'b10;
	parameter d = 2'b11;
	
input clock_25;
input reset;
input frame_tik;
output reg game_tik;


reg divided_frame_tik;
reg [1:0]current_state, shifter;


always @ (posedge clock_25 or negedge reset ) begin

if (~reset) begin
    divided_frame_tik <= 1'b0;
    current_state <= a;
end
else if(frame_tik == 1'b1 && current_state == a ) begin
	divided_frame_tik=1'b1;
	current_state= b;
end
else if(frame_tik == 1'b0 && current_state == b ) begin
	divided_frame_tik=1'b0;
	current_state= c;
end
else if(frame_tik == 1'b1 && current_state == c  ) begin
	divided_frame_tik=1'b0;
	current_state= d;
end
else if(frame_tik == 1'b0 && current_state == d  ) begin
	divided_frame_tik=1'b0;
	current_state= a;
end
end

always @ (posedge clock_25 or negedge reset ) begin

if (~reset) begin
   shifter <= 2'b00;
   game_tik <= 1'b0;
end
else begin
    shifter <= { shifter[0], divided_frame_tik};
    if (shifter[0]==1'b1 && shifter[1]==1'b0) 
        game_tik<=1'b1;
    else
        game_tik<=1'b0;       
end

end

endmodule