/* This module is a copy of "graphic_game", we used it for testbanch*/

module graphic_game_for_test (x_block, y_block, x_local, y_local, reset, clock_25, X, Y, snake_head_x, body_count, snake_head_y, snake_body_x, snake_body_y, fruit_x, fruit_y, selected_symbol, snake_length, game_area, game_enable, color_data, selected_figure,
body_found, up, down, left, right, left_tail, right_tail, up_tail, down_tail);

    parameter PIXEL_DISPLAY_BIT   = 9;
    parameter SNAKE_LENGTH_BIT    = 4;
    parameter SNAKE_LENGTH_MAX    =16;

    parameter HEAD_RIGTH = 4'b0000;
    parameter HEAD_UP = 4'b0001;
    parameter HEAD_LEFT = 4'b0010;
    parameter HEAD_DOWN = 4'b0011;
    parameter BODY = 4'b0100;
    parameter TAIL_RIGTH = 4'b0101;
    parameter TAIL_UP = 4'b0110;
    parameter TAIL_LEFT = 4'b0111;
    parameter TAIL_DOWN = 4'b1000;
    parameter FRUIT =4'b1001;

    // position (0,0) of the cells
    parameter X_off = 58;      
    parameter Y_off = 43; 
    //posotion(123,80) of the cells
    parameter X_fin = X_off + 124 * 5 -1; //677
    parameter Y_fin = Y_off + 81 * 5 -1; //447



    parameter BLOCK_SIZE = 5;   // Dimensione di ciascun blocco in pixel


    input reset;                                                // Segnale di reset
    input clock_25;                                              // Clock a 25 MHz
    input [SNAKE_LENGTH_BIT-1:0] body_count;                                         //abilitazione all'invio dei blocchi del corpo
    input [PIXEL_DISPLAY_BIT:0] X, Y;                           // Coordinate globali (contatori dello schermo)
    input [6:0] snake_head_x, snake_head_y;                                  // Coordinate della testa del serpente
    input [6:0] snake_body_x, snake_body_y;                                  // Coordinate del corpo del serpente
    input [6:0] fruit_x, fruit_y;                               // Coordinate del frutto
    input [SNAKE_LENGTH_BIT-1:0] snake_length;               // Lunghezza del serpente (quanti segmenti ha)
    input [49:0] selected_symbol;                                // Colore del pixel in ingresso (2 bit)
    input up, down, left, right;                                 //Snake head direction, for undestanding in which direction head and tail have to be printed
    input left_tail, right_tail, up_tail, down_tail;            // Snake tail direction


    output  game_enable;                                     // Output: attiva il pixel
    output reg [1:0] color_data;                                 // Output: colore del pixel corrente
    output reg [1:0] selected_figure;                            // Output: tipo di figura (testa, corpo, coda, frutto)
    reg addr_enable;


    output game_area; //playing game's area

     reg [1:0]game_enable_vect;
	output reg body_found;
    
    
    //definisco cotnatori all'interno del blocco
    output reg  [6:0] x_block, y_block;    //contatori lungo x e y dei blocchi di gioco
    output reg [2:0] x_local, y_local;    //contatore del pixel (da 0 a 4) all'interno del blocco corrente

//integer for cycle
integer i=0;
   
assign game_area = (X>=X_off && X<= X_fin && Y >= Y_off && Y <= Y_fin) ? 1'b1 : 1'b0;  
                              //683                 //452



//reconstruction of the bodysnake matrix.

reg [6:0] snake_body_x_reg [0:SNAKE_LENGTH_MAX-2];        
reg [6:0] snake_body_y_reg [0:SNAKE_LENGTH_MAX-2]; 

always @ (posedge clock_25) begin

snake_body_x_reg[body_count] <= snake_body_x;
snake_body_y_reg[body_count] <= snake_body_y;
end   


// Calculate the relative coordinates of the block

always @(posedge clock_25 or negedge reset) begin                
if(~reset) begin
    y_block <= 7'b0000000;
    y_local <=3'b000;
    x_block <= 7'b0000000;
    x_local <=3'b000;
end

else if((Y>=Y_off) && (Y<=Y_fin))
    
                if((X>=X_off) && (X<=X_fin)) begin
                    if(X>=BLOCK_SIZE * x_block + X_off+ 4) begin 
                        x_block <= x_block +1'b1;
                        x_local <=3'b000;
                    end
                    else
                        x_local <=x_local +1'b1;
                end
                
                else if(X==799 && (Y>=BLOCK_SIZE * y_block + Y_off+4) ) begin
                    
                        y_block <= y_block +1'b1;
                        y_local <=3'b000;
                        x_block <= 7'b0000000;
                        x_local <=x_local;
                end
                
                else if (X ==799) begin
                        y_local <= y_local +1'b1;
                        x_block <= 7'b0000000;
                        x_local <= x_local;
                    end
                    
                else begin
                        x_local <= x_local;
                        y_local <= y_local;
                        x_block <= x_block;
                        y_block <= y_block;
                end

else begin
    y_block <= 7'b0000000;
    y_local <=3'b000;
    end
end

//Auxiliary counters advanced by 2 clock cycles. In this way, when the tracker reaches the actual value,
// the corresponding symbol will already be available to be printed.

reg [6:0] x_block_advance, y_block_advance;
reg [2:0] x_local_advance, y_local_advance;

always @(posedge clock_25 or negedge reset) begin                
    if(~reset) begin
        y_block_advance <= 7'b0000000;
        y_local_advance <=3'b000;
        x_block_advance <= 7'b0000000;
        x_local_advance <=3'b000;
    end

    else if((Y>=Y_off) && (Y<=Y_fin))
      
                    if((X>=X_off-2) && (X<=X_fin-2)) begin
                        if(X>=BLOCK_SIZE * x_block_advance + X_off-2+4) begin 
                            x_block_advance <= x_block_advance +1'b1;
                            x_local_advance <=3'b000;
                        end
                        else
                            x_local_advance <=x_local_advance +1'b1;
                    end

                    else if(X==797 && (Y>=BLOCK_SIZE * y_block_advance + Y_off+4) ) begin					  
                            y_block_advance <= y_block_advance +1'b1;
                            y_local_advance <=3'b000;
                            x_block_advance <= 7'b0000000;
                            x_local_advance <=x_local_advance;
                    end
                
                    else if (X ==797) begin
                            y_local_advance <= y_local_advance +1'b1;
                            x_block_advance <= 7'b0000000;
                            x_local_advance <= x_local_advance;
                    end
                  
                    else begin
                            x_local_advance <= x_local_advance;
                            y_local_advance <= y_local_advance;
                            x_block_advance <= x_block_advance;
                            y_block_advance <= y_block_advance;
                    end

    else begin
        y_block_advance <= 7'b0000000;
        y_local_advance <=3'b000;
    end
end

//assigning the figure (head, tail, fruit or body) to the corresponding block

always @(*) begin
    body_found=1'b0;

    for (i =0 ;i< SNAKE_LENGTH_MAX-3 ; i=i+1 ) begin      //check all the body parts exept for head and tail
        if ((game_area==1) && (i<snake_length-1) && (x_block_advance == snake_body_x_reg[i]) && (y_block_advance == snake_body_y_reg[i])) begin
                body_found=1'b1;
        end                 
    end
end

always @(posedge clock_25 or negedge reset) begin

    if (~reset) begin
       addr_enable<=1'b0;
       selected_figure <= 2'b00;
    end
    
    else if (game_area) begin
        // Default: it keeps the previous figure
            
        selected_figure <= selected_figure;

        if ((x_block_advance == snake_head_x) && (y_block_advance == snake_head_y)) begin  //head check and assigment of the corrisponding direction of the head
            if(up)begin
               addr_enable <= 1'b1;      
                selected_figure <= HEAD_UP;
            end
            else if(down) begin
                addr_enable <= 1'b1;      
                selected_figure <= HEAD_DOWN;
            end
            else if(right)begin
                addr_enable <= 1'b1;      
                selected_figure <= HEAD_RIGTH;
            end
            else if(left)begin
                addr_enable <= 1'b1;      
                selected_figure <= HEAD_LEFT;
            end
             
        end 

        else if (body_found ==1 ) begin //body check
            addr_enable <= 1'b1;
            selected_figure <= BODY;
        end

        else if ((x_block_advance == snake_body_x_reg[snake_length-1]) && (y_block_advance == snake_body_y_reg[snake_length-1])) begin  //tail check and assigment of the corrisponding direction of the tail
            if(up_tail)begin
            addr_enable <= 1'b1; 
            selected_figure <= TAIL_UP;
            end

            else if(down_tail)begin
            addr_enable <= 1'b1; 
            selected_figure <= TAIL_DOWN;
            end

            else if(right_tail)begin
            addr_enable <= 1'b1; 
            selected_figure <= TAIL_RIGTH;
            end

            else if(left_tail)begin
            addr_enable <= 1'b1; 
            selected_figure <= TAIL_LEFT;
            end
            
        end

        else if ((x_block_advance == fruit_x) && (y_block_advance == fruit_y)) begin //fruit check

            addr_enable <= 1'b1;
            selected_figure <= FRUIT;
        end

        else begin
            addr_enable <= 1'b0;
            selected_figure <= 1'b0;
        end
    end
      
end
 
 always @ (posedge clock_25 or negedge reset) begin  // game_enable has to be delayed by two clock cycles in order to be sycnronized with the pi 
    if (~reset)
            game_enable_vect <= 2'b00;
    else 
            game_enable_vect <= {game_enable_vect[0],addr_enable};
 end

assign game_enable = game_enable_vect[1];

assign pixel_index = y_local * 10 + x_local * 2 ;  //pixel index has the value of the pixel position of the current block 
 
always @ (posedge clock_25 or negedge reset) begin
 
    if (~reset)
            color_data <=2'b00;

   else if (game_enable_vect[0] == 1'b1)        //the 2 pixel of color data goes as output to te VGA controller
                color_data <= {selected_symbol[49-pixel_index],selected_symbol[48-pixel_index]};
    else
                color_data <=2'b00;
end

   
endmodule