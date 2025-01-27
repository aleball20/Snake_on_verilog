module time_controller(clock_25, reset, sync_reset, time_tik, selected_time_number, time_count, en_time, X, Y);


parameter PIXEL_DISPLAY_BIT   = 9;

input clock_25;
input reset;
input sync_reset;
input time_tik;
input [PIXEL_DISPLAY_BIT:0] X,Y;

output reg [3:0] selected_time_number;
output reg [7:0] time_count;
output reg en_time;


reg [3:0] cent, dec, unit;
reg [3:0]residual;
reg [PIXEL_DISPLAY_BIT:0] Y_prev;
reg time_tik_prev;


always @ (posedge clock_25 or negedge reset) begin    

    if (~reset) begin                                  
       selected_time_number <= 4'b0000;
       time_count <= 8'b00000000;
       Y_prev <=  10'd465;
       en_time <= 1'b0;
    end

    else if (sync_reset) begin
        time_count <= 8'b00000000;
        selected_time_number <= 4'b0000;
        Y_prev <=  10'd466; 
        en_time <= 1'b0;
     end



    else if(Y<= 465 || Y>=476) begin  //if you are not inside the number space, variables are initialize
         residual <= 4'b0000;
         Y_prev <=  10'd466;
         en_time <= 1'b0;
    end

//time_enable is delayed of 2 colcks cycle, therefore the time_count can be incremented until 2 varibles before
    else begin 
        if(X >= 179 && X <= 190) begin //writes the cent
            selected_time_number <= cent;
            en_time <= 1'b1;
            if(X <=188)
                time_count <= X - 179 + 10*residual;
                
        end

    
        else if (X >= 193 && X <= 204) begin //writes the dec
            selected_time_number <= dec;
            en_time <= 1'b1;
            if(X <= 202)
                time_count <= X - 193 + 10*residual;   

        end

    
        else if (X >= 207 && X <= 218) begin //writes the unit
            selected_time_number <= unit;
            en_time <= 1'b1;
            if(X <=216)
                time_count <= X - 207 + 10*residual;
                
        end

        else if (Y > Y_prev) begin
            residual <= residual + 1'b1;
            Y_prev <= Y_prev +1'b1;
        end

        else  begin //default
            en_time <= 1'b0;
            residual <= residual;
            selected_time_number <= 4'b0000;
            time_count <= 8'b00000000;
        end
    end
end



    always @ (posedge clock_25 or negedge reset) begin  //unit and decimal part assignmet

        if(~reset) begin
            unit <= 4'b000;
            dec <= 4'b0000;
            cent<= 4'b0000;
            time_tik_prev <= 1'b0;
        end

        else if(sync_reset) begin
            unit <= 4'b000;
            dec <= 4'b0000;
            cent<= 4'b0000;
            time_tik_prev <= 1'b0;
        end
     
        else begin
            time_tik_prev <= time_tik;
            
            if(time_tik > time_tik_prev)begin 
            if (unit == 4'd9) begin
                unit <= 4'd0;
                if (dec == 4'd9)begin
                    dec <= 4'd0;
                    if(cent==4'd9)
                        cent <= 4'd0;
                    else
                        cent <= cent + 1'b1;
                    end      
                else begin
                    dec <= dec + 1'b1;  
                    cent <= cent;
                end
            end       
            else begin
                    unit <= unit + 1'b1;
                    dec <= dec;  
                    cent<= cent;
                 end
         end
            
        end
    end
     
 endmodule