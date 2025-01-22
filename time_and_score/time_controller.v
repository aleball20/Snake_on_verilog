module time_controller(clock_25, reset, time_tik, number_pixel, selected_time_number, time_enable, time_count, X, Y);


parameter PIXEL_DISPLAY_BIT   = 9;

input clock_25;
input reset;
input time_tik;
input number_pixel;
input [PIXEL_DISPLAY_BIT:0] X,Y;

output reg [3:0] selected_time_number;
output reg time_enable;
output reg [7:0] time_count;


reg [3:0] cent, dec, unit;
reg [3:0]residual;
reg [PIXEL_DISPLAY_BIT:0] Y_prev;
reg time_tik_prev;


always @ (posedge clock_25 or negedge reset) begin    

    if (~reset) begin                                  
       time_enable <= 1'b0;
       selected_time_number <= 4'b0000;
       time_count <= 10'b000000000;

    end
 
    else if(Y< 460 || Y> 475) begin  //if you are not inside the number space, variables are initialize
         time_enable <= 1'b0;
         time_count <= 10'b0000000000;
         residual <= 4'b0000;

    end

    else begin 
        if(X >=178 && X <= 187) begin //writes the cent
            selected_time_number <= cent;
            time_count <= X - 178 + 10*residual;
            time_enable <= number_pixel;
            Y_prev <=  10'b0000000000;
        end

    
        else if (X >= 190 && X <= 199) begin //writes the dec
            selected_time_number <= dec;
            time_count <= X - 190 + 10*residual;
            time_enable <= number_pixel;
        end

    
        else if (X >= 201 && X <= 210) begin //writes the unit
            selected_time_number <= unit;
            time_count <= X - 201 + 10*residual;
            time_enable <= number_pixel;
        end

        else if (Y > Y_prev) begin
            residual <= residual + 1'b1;
            Y_prev <= Y_prev +1'b1;
        end

        else  begin //default
            residual <= residual;
            time_count <= time_count;
            time_enable <= 1'b0;
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
     
        else if(time_tik > time_tik_prev)begin 
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
                    dec <= dec +1'b1;  
                    cent <= cent;
                end
            end       
            else begin
                    unit <= unit + 1'b1;
                    dec <= dec;  
                    cent<= cent;
                 end
            
            time_tik_prev <= time_tik;
        end
    end
     
 endmodule