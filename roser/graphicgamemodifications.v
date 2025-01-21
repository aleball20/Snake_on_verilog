    parameter HEAD_UP = 4'b0000;
    parameter HEAD_DOWN = 4'b0001;
    parameter HEAD_RIGTH = 4'b0010;
    parameter HEAD_LEFT = 4'b0011;
    parameter BODY = 4'b0100
    parameter TAIL_UP = 4'b0101;
    parameter TAIL_DOWN = 4'b0110;
    parameter TAIL_RIGHT = 4'b0111;
    parameter TAIL_LEFT = 4'b1000;
    parameter FRUIT =4'b1001;




            if ((x_block_advance == snake_head_x) && (y_block_advance == snake_head_y)) begin 
                if(up){
                     addr_enable <= 1'b1;      
                    selected_figure <= HEAD_UP;
                }
                else if(down){
                    addr_enable <= 1'b1;      
                    selected_figure <= HEAD_DOWN;
                }
                else if(rigth){
                    addr_enable <= 1'b1;      
                    selected_figure <= HEAD_RIGTH;
                }
                else if(left){
                    addr_enable <= 1'b1;      
                    selected_figure <= HEAD_LEFT;
                }
                else
                addr_enable <= 1'b0; 
            end 

            else if (body_found ==1 ) begin
                addr_enable <= 1'b1;
                selected_figure <= BODY;
            end

            else if ((x_block_advance == snake_body_x_reg[snake_length-1]) && (y_block_advance == snake_body_y_reg[snake_length-1])) begin  //controllo coda
                if(up){
                addr_enable <= 1'b1; 
                selected_figure <= TAIL_UP;
                }

                else if(down){
                addr_enable <= 1'b1; 
                selected_figure <= TAIL_DOWN;
                }

                else if(rigth){
                addr_enable <= 1'b1; 
                selected_figure <= TAIL_RIGTH;
                }

                else if(left){
                addr_enable <= 1'b1; 
                selected_figure <= TAIL_LEFT;
                }
                else
                addr_enable <= 1'b0; 
            end

            else if ((x_block_advance == fruit_x) && (y_block_advance == fruit_y)) begin

                addr_enable <= 1'b1;
                selected_figure <= FRUIT;
            end

            else begin
                addr_enable <= 1'b0;
                selected_figure <= 1'b0;
            end