/* Modulo di gioco. Qui si gestisce il comportamento dello snake e lo stato di gioco.
Si definisce una griglia di gioco nel quale verrano collocati i blocchi del serpente e il frutto.
Ogni singola cella della griglia ÃƒÂ¨ grande 5x5 pixels. Essendo la game_area grande 620x405 pixels vi sarÃƒÂ 
la griglia di gioco avrÃƒÂ  dimensinone 124x81 celle */

`include "global_parameters.v"

module snake_game_fsm(clock_25, game_tik, display_area, reset, right_P, left_P, score, en_snake_body,
					snake_head_x, snake_head_y, snake_body_x, snake_body_y, fruit_x, fruit_y, snake_length); 
    input clock_25;                                                 // Clock di sistema
    input game_tik, dispaly_area;                                   // tik a 30Hz in uscia da un divisore con ingresso il frame_tik
    input reset;                                                    // Reset del gioco per riportare il gioco a stato iniziale
    input left_P, right_P;                                          // Comandi di movimento
    output en_snake_body;                                           //Abilitazione all'invio dei blocchi del corpo
    output [6:0] snake_head_x, snake_head_y;                         // Posizione della testa del serpente (range 0-123 per x, 0-80 per y)
    output [6:0] snake_body_x;                                      // Posizioni del corpo del serpente (massimo 16 segmenti)
    output [6:0] snake_body_y;                                       // Posizioni del corpo del serpente (massimo 16 segmenti)
    output [6:0] fruit_x, fruit_y;      							   // Posizione del frutto (randomica)
    output [`SNAKE_LENGTH_BIT-1:0] snake_length;               // Lunghezza del serpente (quanti segmenti ha)
    output reg [7:0] score;                                           // Punteggio corrente del gioco

reg [2:0] current_state; 
reg [2:0] next_state;


// registri di posizione e wire

reg [6:0] snake_head_x, snake_head_y, snake_body_x, snake_body_y;
reg [6:0] snake_body_x_reg [0:`SNAKE_LENGTH_MAX];        
reg [6:0] snake_body_y_reg [0:`SNAKE_LENGTH_MAX];        
reg [`SNAKE_LENGTH_BIT-1:0] snake_length;               
reg [6:0] fruit_x, fruit_y;
reg up, down, left, right;

wire [6:0] new_position_x, new_position_y;
wire fruit_eaten;

reg collision_fruit, collision_detected;

//definisco wire della rete combinatoria di uscita

reg en_move, en_fruit, sync_reset, en_snake_body;





// Indice per ciclo for
integer i; 




 //registro di uscita della rete di Moore

always @(posedge clock_25 or negedge reset)

    if (~reset)
        current_state <= `IDLE;   // Inizializza lo stato a IDLE (stato iniziale)
        
    
    else 
        current_state <= next_state;  // Se non ÃƒÂ¨ attivo il reset, aggiorna lo stato corrente con quello successivo



// Logica per aggiornare gli stai del gioco della FSM

always @(current_state, left_P, right_P, game_tik, collision_detected, fruit_eaten, collision_fruit)
 
    case (current_state)

        `IDLE: begin
        
            if (~right_P || ~left_P)  // Se il giocatore fornisce un input (movimento), passa allo stato WAIT
                next_state = `WAIT;
            else 
                next_state = `IDLE;
        end
        
        `WAIT: begin

         if (game_tik)
            next_state = `MOVING;
        else
            next_state = `WAIT;
            
        end

        `MOVING: begin
            next_state = `MOVE_DONE;
        end

        `MOVE_DONE: begin
            if (collision_detected)
                next_state = `COLLISION;        // Se si verifica una collisione, cambia lo stato a COLLISION

            else if (fruit_eaten)
                next_state = `EATEN_FRUIT;      // Se il serpente mangia un frutto, cambia lo stato a EATEN_FRUIT

            else if (~display_area)
                next_state = `MOVE_DONE;
            
            else
                next_state = `WAIT;
        
        end

        `EATEN_FRUIT: begin
            if(collision_fruit)
                  next_state = `FRUIT_UPDATE;        // se ho collsione di generazione continua ad aggiornare posizione frutto
            else
                next_state = `FRUIT_DONE;
        end

        `FRUIT_UPDATE: begin
        if(collision_fruit)
            next_state = `FRUIT_UPDATE;
        else if (~display_area)
            next_state = `FRUIT_DONE;
        else
            next_state = `WAIT;
        end

        `FRUIT_DONE: begin
        if(game_tik)
              next_state = `FRUIT_DONE;        // se ho collsione di generazione continua ad aggiornare posizione frutto
        else
            next_state = `WAIT;
    end
        
        `COLLISION: begin
            // In caso di collisione, il gioco termina e rimane nello stato COLLISION
            if (~right_P || ~left_P) 
                next_state = `IDLE;
            else 
                next_state = `COLLISION;
        end

        default: next_state = `IDLE; // Stato di default

    endcase



// Logica di uscita della FSM

always @(current_state) 
    case (current_state)
        `WAIT: begin
            en_move = 1'b0;
            sync_reset= 1'b0;
            en_fruit = 1'b0;
            en_snake_body=1'b0; 
             
            
        end
        
        `EATEN_FRUIT: begin
            en_move = 1'b0;
            sync_reset= 1'b0;
            en_fruit = 1'b1; 
            en_snake_body = 1'b1;
             
        end

        `FRUIT_UPDATE: begin
            en_move = 1'b0;
            sync_reset= 1'b0;
            en_fruit = 1'b1;
            en_snake_body = 1'b1;
         
        end

        `FRUIT_DONE: begin
            en_move = 1'b0;
            sync_reset= 1'b0;
            en_fruit = 1'b0;
            en_snake_body = 1'b1;
        
        end
        
        `COLLISION: begin
            // Imposta il segnale di fine gioco (game over)
            // Il gioco è finito
            en_move = 1'b0;
            sync_reset= 1'b0;
            en_fruit = 1'b0; 
            en_snake_body = 1'b1;
        end

        `MOVING: begin
            en_move = 1'b1;
            sync_reset= 1'b0;
            en_fruit = 1'b0;
            en_snake_body = 1'b0;
        end

        `MOVE_DONE: begin
            en_move = 1'b0;
            sync_reset= 1'b0;
            en_fruit = 1'b0;
            en_snake_body = 1'b1;
        end

        `IDLE: begin
            en_move = 1'b0;
            sync_reset =1'b1;
            en_fruit = 1'b0;
            en_snake_body = 1'b0;
        end


    endcase

always @ (posedge clock_25) begin

    if(sync_reset ) begin

        snake_head_x <= `BEGIN_SNAKE_HEAD_X;    // Posizione iniziale della testa del serpente (centrato sulla griglia)
        snake_head_y <= `BEGIN_SNAKE_HEAD_Y;    // Posizione centrata nella griglia di 124x81
        snake_length <= `BEGIN_SNAKE_LENGTH;        // Lunghezza iniziale del serpente (ad esempio, 4 segmenti)
        for (i=0; i< `SNAKE_LENGTH_MAX-1 ;i=i+1) begin
		  
            if (i < `BEGIN_SNAKE_LENGTH-1) begin
                snake_body_x_reg[i] <= `BEGIN_SNAKE_HEAD_X -1-i;
                snake_body_y_reg[i] <= `BEGIN_SNAKE_HEAD_Y -1-i;
					 end
            else begin
                snake_body_x_reg[i] <= 7'b1111111;
                snake_body_y_reg[i] <= 7'b1111111;
            end
        end

        fruit_x <= `BEGIN_FRUIT_X;         // Posizione iniziale del frutto (randomizzata o predefinita)
        fruit_y <= `BEGIN_FRUIT_Y;
        score <= 8'd0;            // Punteggio iniziale del gioco   
    end

    else if(en_move) begin
        // Aggiorna la posizione della testa del serpente in base agli input
        if (up) begin
            if (snake_head_y > 0) begin
                 snake_head_y <= snake_head_y - 1'b1;    // Muove il serpente verso l'alto
                 snake_head_x <= snake_head_x;
            end
        end 
            
          else if (down) begin
                if (snake_head_y < `VERTICAL_CELLS_NUM-1'b1) begin
                    snake_head_y <= snake_head_y + 1'b1;    // Muove il serpente verso il basso
                    snake_head_x <= snake_head_x;
                end
            end 
            
            else if (left) begin
                if (snake_head_x > 0)  begin
                    snake_head_x <= snake_head_x - 1'b1;     // Muove il serpente verso sinistra
                    snake_head_y <= snake_head_y;
                end
            end 
            
            else if (right) begin
                if (snake_head_x < `HORIZONTAL_CELLS_NUM-1'b1) begin
                    snake_head_x <= snake_head_x + 1'b1;     // Muove il serpente verso destra
                    snake_head_y <= snake_head_y;
                end
            end
            
            //FORSE ÃƒÂ¨ SBAGLIATOOOOOOOO
            //Aggiornamento del corpo del serpente 

            // Lo spostamento del corpo avviene spostando ogni segmento verso la posizione del segmento precedente
            for (i = `SNAKE_LENGTH_MAX-1; i > 0; i = i - 1) begin
            // Sposta ogni segmento del corpo alla posizione del segmento precedente
				
            if(i< snake_length-2)begin
					snake_body_x_reg[i] <= snake_body_x_reg[i - 1];
					snake_body_y_reg[i] <= snake_body_y_reg[i - 1];
					end
				else
					snake_body_x_reg[i] <= snake_body_x_reg[i];
					snake_body_y_reg[i] <= snake_body_y_reg[i];
            end

            // Il primo segmento del corpo segue la testa del serpente
            snake_body_x_reg[0] <= snake_head_x;
            snake_body_y_reg[0] <= snake_head_y;  
    end  

    else if(en_fruit) begin

            // Incrementa il punteggio quando il serpente mangia un frutto
            score <= score + 1'b1; 
            // Aumenta la lunghezza del serpente
            snake_length <= snake_length + 1'b1;

            fruit_x <= new_position_x;
            fruit_y <= new_position_y;

    end

end


//assegnazione bit fruit_eaten

assign fruit_eaten = (fruit_x==snake_head_x && fruit_y == snake_head_y) ? 1'b1 : 1'b0;

// Genera una nuova posizione per il frutto (random)

random_sequence random_sequence_x(
    .clock_25(clock_25),
    .seed(6'b001110),
    .rnd(new_position_x)
);

random_sequence random_sequence_y(
    .clock_25(clock_25),
    .seed(6'b011000),
    .rnd(new_position_y)
);

//controllo di una collisione del nuovo frutto con il corpo del serpente o fuori dal game_board
always @ (*)
for (i=0; i <`SNAKE_LENGTH_MAX -1  ; i=i+1) begin
    if((fruit_x == snake_head_x && fruit_y== snake_head_y) || (fruit_x == snake_body_x_reg[i] && fruit_y== snake_body_y_reg[i]))
        collision_fruit= 1'b1;

    else if(fruit_x >= `HORIZONTAL_CELLS_NUM || fruit_y >= `VERTICAL_CELLS_NUM)
        collision_fruit = 1'b1;
    
    else
        collision_fruit = 1'b0;    
end

//collision detector           
integer j=0;

 always @ (snake_head_x or snake_head_y or snake_length) begin

     // Verifica se la testa del serpente Ã¨ fuori dai bordi
     if (snake_head_x < 0 || snake_head_x > `HORIZONTAL_CELLS_NUM-1'b1 || snake_head_y < 0 || snake_head_y > `VERTICAL_CELLS_NUM-1'b1) begin
        // Se la testa è¨ fuori dalla griglia (fuori dai limiti), ritorna 1 (collisione)
        collision_detected = 1;
		  j=0;
			end
    // Verifica se la testa del serpente ha colpito se stessa (ossia una posizione giÃ  occupata dal corpo)
    else begin
        collision_detected = 0; // Inizialmente, nessuna collisione
        for (j = 0; j < snake_length; j = j + 1'b1) begin
             // Controlla se la testa del serpente Ã¨ sulla stessa posizione di uno dei segmenti del corpo
            if (snake_head_x == snake_body_x_reg[j] && snake_head_y == snake_body_y_reg[j])
                collision_detected = 1'b1; // Se la testa del serpente Ã¨ sul corpo, collisione
        end
    end
 end
 
//assign body_output

reg [`SNAKE_LENGTH_BIT-1:0] count=0;

always @ (posedge clock_25) begin
    if (en_snake_body==1'b0)
        count<=0;
    else begin
        snake_body_x <= snake_body_x_reg[count];
        snake_body_y <= snake_body_y_reg[count];
        count <= count + 1'b1;
    end
end    

//convertire i movimenti 

always @ (posedge clock_25) begin 

    if (snake_head_y == snake_body_y[0] && snake_head_x > snake_body_x[0]) begin

       down <= right_P;  
       up <= left_P;
       right <= 1'b0;
       left <= 1'b0;

    end

    else if (snake_head_y == snake_body_y[0] && snake_head_x < snake_body_x[0]) begin 
       down <= left_P;  
       up <= right_P;
       right <= 1'b0;
       left <= 1'b0;
       

    end

    else if (snake_head_x == snake_body_x[0] && snake_head_y > snake_body_y[0]) begin 

        right <= right_P;  
        left <= left_P;
        up <= 1'b0;
        down <= 1'b0;
 
     end

     else begin 

        right <= left_P;  
        left <= right_P;
        up <= 1'b0; 
        down <= 1'b0;
     end
 end     
endmodule



