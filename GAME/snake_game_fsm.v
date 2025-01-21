/* Modulo di gioco. Qui si gestisce il comportamento dello snake e lo stato di gioco.
Si definisce una griglia di gioco nel quale verrano collocati i blocchi del serpente e il frutto.
Ogni singola cella della griglia dimensinone 124x81 celle */


module snake_game_fsm( clock_25, frame_tik, game_tik, reset, right_P, left_P, score, left, right, up, down,
					snake_head_x, snake_head_y, snake_body_x, body_count, snake_body_y, fruit_x, fruit_y, snake_length); 

parameter SNAKE_LENGTH_BIT = 4;
parameter SNAKE_LENGTH_MAX = 2**SNAKE_LENGTH_BIT; 
parameter HORIZONTAL_CELLS_NUM = 124; //da aggiungere in futuro
parameter VERTICAL_CELLS_NUM = 81;

//fsm states:

parameter  IDLE = 3'b000;
parameter  WAIT = 3'b001;
parameter  EATEN_FRUIT = 3'b010;
parameter  COLLISION = 3'b011;
parameter  MOVING = 3'b100;
parameter  MOVE_DONE = 3'b101;
parameter FRUIT_UPDATE = 3'b110;


//initial values:

parameter BEGIN_SNAKE_HEAD_X = 7'd8;  // Posizione iniziale della testa del serpente (centrato sulla griglia)
parameter BEGIN_SNAKE_HEAD_Y = 7'd40;    // Posizione centrata nella griglia di 124x81
parameter BEGIN_SNAKE_LENGTH = 14'd6;     // Lunghezza iniziale del serpente (ad esempio, 6 segmenti)
parameter BEGIN_FRUIT_X = 7'd8;       // Posizione iniziale del frutto (randomizzata o predefinita)
parameter BEGIN_FRUIT_Y = 7'd42;


    input clock_25;                                                 // Clock di sistema
    input game_tik, frame_tik;                                      // tik a 30Hz in uscia da un divisore con ingresso il frame_tik
    input reset;                                                    // Reset del gioco per riportare il gioco a stato iniziale
    input left_P, right_P;                                          // Comandi di movimento
    output left, right, up, down;                                    // direzioni effettive dello snake
    output [6:0] snake_head_x, snake_head_y;                         // Posizione della testa del serpente (range 0-123 per x, 0-80 per y)
    output [6:0] snake_body_x;                                      // Posizioni del corpo del serpente (massimo 16 segmenti)
    output [6:0] snake_body_y;                                       // Posizioni del corpo del serpente (massimo 16 segmenti)
    output [6:0] fruit_x, fruit_y;      							   // Posizione del frutto (randomica)
    output [SNAKE_LENGTH_BIT-1:0] snake_length;               // Lunghezza del serpente (quanti segmenti ha)
    output reg [SNAKE_LENGTH_BIT-1:0] body_count;                   //counter per inviare il corpo dello snake
																					//bit di abilitzione al movimento dello snake
    output reg [7:0] score;                                           // Punteggio corrente del gioco



reg [2:0] current_state; 
reg [2:0] next_state;


// registri di posizione e wire

reg [6:0] snake_head_x, snake_head_y, snake_body_x, snake_body_y;
reg [6:0] snake_body_x_reg [0:SNAKE_LENGTH_MAX-1];        
reg [6:0] snake_body_y_reg [0:SNAKE_LENGTH_MAX-1];        
reg [SNAKE_LENGTH_BIT-1:0] snake_length;               
reg [6:0] fruit_x, fruit_y;
reg up, down, left, right;
reg right_sync, left_sync;
reg right_register, left_register;
reg [1:0]right_shifter, left_shifter;

wire [6:0] new_position_x, new_position_y;
wire fruit_eaten;

reg collision_fruit, collision_detected;

//definisco reg della rete combinatoria di uscita

reg en_move, en_fruit, sync_reset;


// Indice per ciclo for
integer i; 


 //registro di uscita della rete di Moore

always @(posedge clock_25 or negedge reset)

    if (~reset)
        current_state <= IDLE;   // Inizializza lo stato a IDLE (stato iniziale)
        
    
    else 
        current_state <= next_state;  // Se non attivo il reset, aggiorna lo stato corrente con quello successivo



// Logica per aggiornare gli stai del gioco della FSM

always @(current_state, left_sync, right_sync, game_tik, collision_detected, fruit_eaten, collision_fruit)
 
    case (current_state)

        IDLE: begin
        
            if (right_sync || left_sync)  // Se il giocatore fornisce un input (movimento), passa allo stato WAIT
                next_state = WAIT;
            else 
                next_state = IDLE;
        end
        
        WAIT: begin

         if (game_tik)
            next_state = MOVING;
        else
            next_state = WAIT;
            
        end

        MOVING: begin
            next_state = MOVE_DONE;
        end

        MOVE_DONE: begin
            if (collision_detected)
                next_state = COLLISION;        // Se si verifica una collisione, cambia lo stato a COLLISION

            else if (fruit_eaten)
                next_state = EATEN_FRUIT;      // Se il serpente mangia un frutto, cambia lo stato a EATEN_FRUI
            
            else
                next_state = WAIT;
        
        end

        EATEN_FRUIT: begin
            if(collision_fruit)
                next_state = FRUIT_UPDATE;        // se ho collsione di generazione continua ad aggiornare posizione frutto
            else
                next_state = WAIT;
        end

        FRUIT_UPDATE: begin
        if(collision_fruit)
            next_state = FRUIT_UPDATE;
        else
            next_state = WAIT;
        end

        
        
        COLLISION: begin
            // In caso di collisione, il gioco termina e rimane nello stato COLLISION
            if (right_sync || left_sync) 
                next_state = IDLE;
            else 
                next_state = COLLISION;
        end

        default: next_state = IDLE; // Stato di default

    endcase



// Logica di uscita della FSM

always @(current_state) 
    case (current_state)
        WAIT: begin
            en_move = 1'b0;
            sync_reset= 1'b0;
            en_fruit = 1'b0;
             
            
        end
        
        EATEN_FRUIT: begin
            en_move = 1'b0;
            sync_reset= 1'b0;
            en_fruit = 1'b1; 
             
        end

        FRUIT_UPDATE: begin
            en_move = 1'b0;
            sync_reset= 1'b0;
            en_fruit = 1'b1;
         
        end
        
        COLLISION: begin
            // Imposta il segnale di fine gioco (game over)
            // Il gioco e finito
            en_move = 1'b0;
            sync_reset= 1'b1;
            en_fruit = 1'b0; 
        end

        MOVING: begin
            en_move = 1'b0;
            sync_reset= 1'b0;
            en_fruit = 1'b0;
        end

        MOVE_DONE: begin
            en_move = 1'b1;
            sync_reset= 1'b0;
            en_fruit = 1'b0;
        end

        IDLE: begin
            en_move = 1'b0;
            sync_reset =1'b1;
            en_fruit = 1'b0;
        end
			
		default begin
			en_move = 1'b0;
            sync_reset =1'b1;
            en_fruit = 1'b0;
		end


    endcase


//inizializzazione dell'uscita nello stato di IDLE   
	
	always @ (posedge clock_25 or negedge reset) begin
		if (~reset)
			body_count <= 0;
			
		else if (sync_reset) begin
			if( body_count == SNAKE_LENGTH_MAX-1)
				body_count <= body_count;
            else
            body_count <= body_count + 1'b1;
				
		snake_body_x <= snake_body_x_reg[body_count];
		snake_body_y <= snake_body_y_reg[body_count];
		end
		
		else begin
			 if (en_move==1'b1) begin 
            body_count<=0;
			end
      
			else if(frame_tik==1'b0 || body_count == SNAKE_LENGTH_MAX-1)
				body_count <= body_count;
        else
            body_count <= body_count + 1'b1;
				
			snake_body_x <= snake_body_x_reg[body_count];
			snake_body_y <= snake_body_y_reg[body_count];
		end
	end

always @ (posedge clock_25) begin //il reset non  inserito dato che quando lo si effettua si va in IDLE E QUINDI sync_reset  attivo

    if(sync_reset ) begin //INIZIALIZZAZIONE

        snake_head_x <= BEGIN_SNAKE_HEAD_X;    // Posizione iniziale della testa del serpente (centrato sulla griglia)
        snake_head_y <= BEGIN_SNAKE_HEAD_Y;    // Posizione centrata nella griglia di 124x81
        snake_length <= BEGIN_SNAKE_LENGTH;        // Lunghezza iniziale del serpente (ad esempio, 6 segmenti)
        fruit_x <= BEGIN_FRUIT_X;         // Posizione iniziale del frutto (randomizzata o predefinita)
        fruit_y <= BEGIN_FRUIT_Y;
		  
        score <= 8'd0;            // Punteggio iniziale del gioco   
        for (i=0; i< SNAKE_LENGTH_MAX ;i=i+1) begin
		  
            if (i < BEGIN_SNAKE_LENGTH-1) begin
                snake_body_x_reg[i] <= BEGIN_SNAKE_HEAD_X-i;
                snake_body_y_reg[i] <= BEGIN_SNAKE_HEAD_Y;
					 end
            else begin
                snake_body_x_reg[i] <= 7'b1111111;
                snake_body_y_reg[i] <= 7'b1111111;
            end
        end

    end

    else if(en_move==1'b1 && collision_detected== 1'b0) begin
        // Aggiorna la posizione della testa del serpente in base agli input
            if (up) begin
                if (snake_head_y > 0) begin
                    snake_head_y <= snake_head_y - 1'b1;    // Muove il serpente verso l'alto
                    snake_head_x <= snake_head_x;
                end
        end 
            
            else if (down) begin
                if (snake_head_y < VERTICAL_CELLS_NUM-1'b1) begin
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
                if (snake_head_x < HORIZONTAL_CELLS_NUM-1'b1) begin
                    snake_head_x <= snake_head_x + 1'b1;     // Muove il serpente verso destra
                    snake_head_y <= snake_head_y;
                end
            end
            
      
            //Aggiornamento del corpo del serpente 
				
				// Il primo segmento del corpo segue la testa del serpente
            snake_body_x_reg[0] <= snake_head_x;
            snake_body_y_reg[0] <= snake_head_y; 

            // Lo spostamento del corpo avviene spostando ogni segmento verso la posizione del segmento precedente
            for (i =1; i <SNAKE_LENGTH_MAX ; i = i + 1) begin
            // Sposta ogni segmento del corpo alla posizione del segmento precedente
				
            if(i< snake_length-1)begin
					snake_body_x_reg[i] <= snake_body_x_reg[i-1];
					snake_body_y_reg[i] <= snake_body_y_reg[i-1];
					end
				else begin
					snake_body_x_reg[i] <= snake_body_x_reg[i];
					snake_body_y_reg[i] <= snake_body_y_reg[i];
            end
				
				end
 
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

PRBS random_sequence_x(
    .clock_25(clock_25),
	 .reset(reset),
    .seed(7'b0011100),
    .rnd(new_position_x)
);

PRBS random_sequence_y(
    .clock_25(clock_25),
	.reset(reset),
    .seed(7'b0110000),
    .rnd(new_position_y)
);

//controllo di una collisione del nuovo frutto con il corpo del serpente o fuori dal game_board
always @ (*)
for (i=0; i <SNAKE_LENGTH_MAX -1  ; i=i+1) begin
    if((fruit_x == snake_head_x && fruit_y== snake_head_y) || (fruit_x == snake_body_x_reg[i] && fruit_y== snake_body_y_reg[i]))
        collision_fruit= 1'b1;

    else if(fruit_x >= HORIZONTAL_CELLS_NUM || fruit_y >= VERTICAL_CELLS_NUM)
        collision_fruit = 1'b1;
    
    else
        collision_fruit = 1'b0;    
end

//collision detector           
integer j=0;
always @ (snake_head_x or snake_head_y or left or right or down or up) begin
	for (j = 0; j < snake_length; j = j + 1'b1) begin
        // Controlla se la testa del serpente e sulla stessa posizione di uno dei segmenti del corpo
    if (snake_head_x == snake_body_x_reg[j] && snake_head_y == snake_body_y_reg[j])
        collision_detected = 1'b1; // Se la testa del serpente sul corpo, collisione
    end
    // Verifica se la testa del serpente fuori dai bordi
    if ((snake_head_x == 0 && left==1) || (snake_head_x == (HORIZONTAL_CELLS_NUM-1'b1) &&  right==1 )||
         (snake_head_y == 0  && up==1) || (snake_head_y ==( VERTICAL_CELLS_NUM-1'b1) && down==1) )

       collision_detected = 1'b1;    // Se la testa  fuori dalla griglia (fuori dai limiti), ritorna 1 (collisione)
       
  
   else       // Verifica se la testa del serpente ha colpito se stessa (ossia una posizione gia occupata dal corpo)
       
        collision_detected = 0; // Inizialmente, nessuna collisione      
end


 always @ (posedge clock_25 or negedge reset ) begin

    if (~reset) begin
       right_shifter <= 2'b00;
    end
    else begin
        right_shifter <= { right_shifter[0], right_P};
        if (right_shifter[0]==1'b1 && right_shifter[1]==1'b0) 
            right_sync=1'b1;
        else
            right_sync=1'b0;       
    end
    
end

always @ (posedge clock_25 or negedge reset ) begin

    if (~reset) begin
       left_shifter <= 2'b00;
    end
    else begin
        left_shifter <= { left_shifter[0], left_P};
        if (left_shifter[0]==1'b1 && left_shifter[1]==1'b0) 
            left_sync=1'b1;
        else
            left_sync=1'b0;       
    end
    
end

//Definisco right_register e left_register che assumeranno il valore degli input right_sync e left_sync
// fino al completamento della mossa successiva, ovvero fino all'ingresso nello stato move_done.
always @ (posedge clock_25 or negedge reset) begin 

    if (~reset) begin
        right_register <= 1'b0;
        left_register <= 1'b0;
    end
	 
	  else if (sync_reset) begin
        right_register <= 1'b0;
        left_register <= 1'b0;
    end
	 
    else if(sync_reset==1'b0 && (right_sync==1'b1 || left_sync==1'b1)) begin   //se l'utente preme il pulsante i registri vengono aggiornati
        if(right_sync==1'b1 && left_sync==1'b1 ) begin   //controllo se utente preme entrambi pulsanti, il serpente non cambia
            right_register <= 1'b0;
            left_register <= 1'b0;
        end 
        else begin
            right_register <= right_sync;
            left_register <= left_sync;
        end
    end
    else if(en_move==1'b1) begin        //al termine della mossa i registri tornano ad 0
        right_register <= 1'b0;
        left_register <= 1'b0;
    end
    else begin
        right_register <= right_register;
        left_register <= left_register;
    end 
end


//converte l'input nelle direzioni effettive dello snake 
always @ (posedge clock_25 or negedge reset) begin 

    if (~reset) begin
        down <= 1'b0;
        up <= 1'b0;
        right <= 1'b1; //il gioco inizia che il serpente si muove verso destra
        left <= 1'b0;
    end
	 
	 else if (sync_reset) begin
        down <= 1'b0;
        up <= 1'b0;
        right <= 1'b1; //il gioco inizia che il serpente si muove verso destra
        left <= 1'b0;
    end
	
	// se ho premuto uno dei pulsanti modifico le direzioni
    else if (right_register==1'b1 || left_register==1'b1) begin 
	 
        if (snake_head_y == snake_body_y_reg[0] && snake_head_x > snake_body_x_reg[0]) begin
        down <= right_register;  
        up <= left_register;
        right <= 1'b0;
        left <= 1'b0;

        end

        else if (snake_head_y == snake_body_y_reg[0] && snake_head_x < snake_body_x_reg[0]) begin 
        down <= left_register;  
        up <= right_register;
        right <= 1'b0;
        left <= 1'b0;
        

        end

        else if (snake_head_x == snake_body_x_reg[0] && snake_head_y < snake_body_y_reg[0]) begin 
          right <= right_register;  
          left <= left_register;
          up <= 1'b0;
          down <= 1'b0;
    
        end

        else if (snake_head_x == snake_body_x_reg[0] && snake_head_y > snake_body_y_reg[0]) begin 

            right <= left_register;  
            left <= right_register;
            up <= 1'b0; 
            down <= 1'b0;
        end
    end
    else begin              //se non premo alcun pulsante, mantiene il movimento
        right <= right;
        left <= left;
        up <= up;
        down <= down;
    end
	  
	  
 end     
endmodule



