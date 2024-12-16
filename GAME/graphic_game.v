`include "global_parameters.v"

module graphic_game ( reset, clock_25, X, Y, snake_head_x, snake_head_y, snake_body_x, snake_body_y, fruit_x, fruit_y, selected_symbol, game_enable, en_snake_body, snake_length, game_data, selected_figure);

input reset;                                                // Segnale di reset
input clock_25;                                              // Clock a 25 MHz
input en_snake_body;                                         //abilitazione all'invio dei blocchi del corpo
input [`PIXEL_DISPLAY_BIT:0] X, Y;                           // Coordinate globali (contatori dello schermo)
input [6:0] snake_head_x, snake_head_y;                                  // Coordinate della testa del serpente
input [6:0] snake_body_x, snake_body_y;                                  // Coordinate del corpo del serpente
input [6:0] fruit_x, fruit_y;                               // Coordinate del frutto
input [`SNAKE_LENGTH_BIT-1:0] snake_length;               // Lunghezza del serpente (quanti segmenti ha)
input [49:0] selected_symbol;                                // Colore del pixel in ingresso (2 bit)

output game_enable;
output reg [1:0] game_data;                                 // Output: colore del pixel corrente
output reg [1:0] selected_figure;                            // Output: tipo di figura (testa, corpo, coda, frutto)

 // Costanti per i tipi di figura

parameter HEAD = 2'b00;
parameter BODY = 2'b01;
parameter TAIL = 2'b10;
parameter FRUIT = 2'b11;

parameter X_off = 58;      // posizione (0,0) all'interno del rettangolo di gioco
parameter Y_off = 43; 
parameter X_fin = X_off + 124 * 5;
parameter Y_fin = Y_off + 81 * 5;

// Dimensione di ciascun blocco in pixel
parameter BLOCK_SIZE = 5;




wire game_area; //playing game's area
assign game_area = (X>=58 && X<=678 && Y >= 43 && Y <= 448) ? 1'b1 : 1'b0;  

//definisco cotnatori all'interno del blocco
 reg  [6:0] x_block, y_block;    //contatori lungo x e y dei blocchi di gioco
 reg [2:0] x_local, y_local;    //contatore del pixel (da 0 a 4) all'interno del blocco corrente


//ricostruzione della matrice del bodysnake

reg [6:0] snake_body_x_reg [0:`SNAKE_LENGTH_MAX-1];        
reg [6:0] snake_body_y_reg [0:`SNAKE_LENGTH_MAX-1];  
reg [`SNAKE_LENGTH_BIT-1:0] count=0;

always @ (posedge clock_25) begin
    if (en_snake_body==1'b0)
        count<=0;
    else begin
        snake_body_x_reg[count] <= snake_body_x;
        snake_body_y_reg[count] <= snake_body_y;
        count <= count + 1'b1;
    end
end    


// Calcola le coordinate relative al blocco


always @(posedge clock_25) begin                
    if(~reset) begin
        y_block <= 7'b0000000;
        y_local <=3'b000;
        x_block <= 7'b0000000;
        x_local <=3'b000;
    end

    else if((Y>=Y_off) && (Y<=Y_fin))
      
                    if((X>=X_off) && (X<=X_fin)) begin
                        if(X>=BLOCK_SIZE * x_block + X_off) begin 
                            x_block <= x_block +1'b1;
                            x_local <=3'b000;
                        end
                        else
                            x_local <=x_local +1'b1;
                    end
                    
                    else if(X==799 && (Y>=BLOCK_SIZE * y_block + Y_off) ) begin
                      
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

//Contatori ausiliari anticipati di 2 ciclio di clock

reg [6:0] x_block_delay, y_block_delay;
reg [2:0] x_local_delay, y_local_delay;

always @(posedge clock_25) begin                
    if(~reset) begin
        y_block_delay <= 7'b0000000;
        y_local_delay <=3'b000;
        x_block_delay <= 7'b0000000;
        x_local_delay <=3'b000;
    end

    else if((Y>=Y_off) && (Y<=Y_fin))
      
                    if((X>=X_off-2) && (X<=X_fin-2)) begin
                        if(X>=BLOCK_SIZE * x_block_delay + X_off-2) begin 
                            x_block_delay <= x_block_delay +1'b1;
                            x_local_delay <=3'b000;
                        end
                        else
                            x_local_delay <=x_local_delay +1'b1;
                    end

                    else if(X==797 && (Y>=BLOCK_SIZE * y_block_delay + Y_off) ) begin					  
                            y_block_delay <= y_block_delay +1'b1;
                            y_local_delay <=3'b000;
                            x_block_delay <= 7'b0000000;
                            x_local_delay <=x_local_delay;
                    end
                
                    else if (X ==797) begin
                            y_local_delay <= y_local_delay +1'b1;
                            x_block_delay <= 7'b0000000;
                            x_local_delay <= x_local_delay;
                    end
                  
                    else begin
                            x_local_delay <= x_local_delay;
                            y_local_delay <= y_local_delay;
                            x_block_delay <= x_block_delay;
                            y_block_delay <= y_block_delay;
                    end

    else begin
        y_block_delay <= 7'b0000000;
        y_local_delay <=3'b000;
    end
end


wire [5:0] pixel_index;										 // Indice del pixel (0-24) nel vettore
assign pixel_index = y_local * 10 + x_local * 2 ;
reg game_enable;                                            // Output: attiva il pixel
reg addr_enable;
reg [6:0] cont2;
integer i=0;


always @(posedge clock_25 or negedge reset) begin

    if (~reset) begin

        // Reset dei segnali

       addr_enable<=1'b0;
       selected_figure <= 2'b00;
    end
    
    else if (game_area) begin

        // Default: disabilita il gioco


        // Controlla se X,Y appartengono a uno dei blocchi
            
            for (i =1 ;i< `SNAKE_LENGTH_MAX-2 ; i=i+1 ) begin      //controllo tutte le parti del corspo tranne testa e coda  
                if ((i < snake_length) &&(x_block_delay == snake_body_x_reg[cont2]) && (y_block_delay == snake_body_y_reg[cont2])) begin
                                addr_enable <= 1'b1;
                        cont2 <=cont2 +1'b1;
                        selected_figure <= BODY;
                end
                      else
                            cont2 <= 7'b0000000;
            end

        if ((x_block_delay == snake_head_x) && (y_block_delay == snake_head_y)) begin 
            
             addr_enable <= 1'b1;      
            selected_figure <= HEAD;
        end 

        else if ((x_block_delay == snake_body_x_reg[snake_length-1]) && (y_block_delay == snake_body_y_reg[snake_length-1])) begin  //controllo coda

            addr_enable <= 1'b1; 
            selected_figure <= TAIL;

        end

        else if ((x_block_delay == fruit_x) && (y_block_delay == fruit_y)) begin

            addr_enable <= 1'b1;
            selected_figure <= FRUIT;
        end
                        
            else begin
                addr_enable <= 1'b0;
					 selected_figure <= selected_figure;
				end
    end
      
end
 
 always @ (posedge clock_25 or negedge reset) begin
    if (~reset)
            game_enable <=1'b0;
    else
            game_enable <= addr_enable;
 end
 
 always @ (posedge clock_25 or negedge reset) begin
 
    if (~reset)
            game_data <=2'b00;

   else if (game_enable == 1'b1)
                game_data <= {selected_symbol[49-pixel_index],selected_symbol[48-pixel_index]};
                //game_data <= 2'b11;
    else
                game_data <=2'b00;
end

 

endmodule