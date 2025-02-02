/*This FSM menages all the games registers, it takes the  user input */


module snake_game_fsm( clock_25, game_tik, start, game_over, reset, sync_reset, right_P, left_P, score, left, right, up, down,
                        left_tail, right_tail, up_tail, down_tail, snake_head_x, snake_head_y, snake_body_x, body_count, snake_body_y, fruit_x, fruit_y, snake_length); 

parameter SNAKE_LENGTH_BIT = 7;
parameter SNAKE_LENGTH_MAX = 2**SNAKE_LENGTH_BIT; 
parameter HORIZONTAL_CELLS_NUM = 124;
parameter VERTICAL_CELLS_NUM = 81;

//fsm states:

parameter  IDLE = 3'b000;
parameter  WAIT = 3'b001;
parameter  COLLISION = 3'b010;
parameter  MOVING = 3'b011;
parameter  MOVE_DONE = 3'b100;
parameter  EATEN_FRUIT = 3'b101;
parameter  FRUIT_UPDATE= 3'B110;
parameter  RESET_IDLE = 3'B111;

//initial values:

parameter BEGIN_SNAKE_HEAD_X = 7'd8;  // Initial position of the snake's head
parameter BEGIN_SNAKE_HEAD_Y = 7'd40; 
parameter BEGIN_SNAKE_LENGTH = 4'd6;  // Initial length of the snake (e.g., 6 segments)
parameter BEGIN_FRUIT_X = 7'd18;      // Default initial position of the fruit
parameter BEGIN_FRUIT_Y = 7'd50;  


input clock_25;                                                 // System clock
input game_tik;                                                 // When set to one the snakes moves
input reset;                                                    // Game reset to return the game to its initial state
input left_P, right_P;                                          // Movement controls
output start, game_over;                                        // This bit communicates if the game is running or if there is a game over
output sync_reset;                                              // Synchronous reset
output left, right, up, down;                                   // Actual movement directions of the snake head
output left_tail, right_tail, up_tail, down_tail;               //Actual movement directions of the snake tail
output [6:0] snake_head_x, snake_head_y;                        // Position of the snake's head (range 0-123 for x, 0-80 for y)
output [6:0] snake_body_x;                                      // Positions of the snake's body
output [6:0] snake_body_y;                                      // Positions of the snake's body
output [6:0] fruit_x, fruit_y;                                  // Position of the fruit (random)
output [SNAKE_LENGTH_BIT-1:0] snake_length;                     // Length of the snake (number of segments)
output reg [SNAKE_LENGTH_BIT-1:0] body_count;                   // Counter to send the snake's body to graphic_game

output reg [6:0] score;                                         // Game score




reg [2:0] current_state; 
reg [2:0] next_state;


// reg and wire definition

reg [6:0] snake_head_x, snake_head_y, snake_body_x, snake_body_y;
reg [6:0] snake_body_x_reg [0:SNAKE_LENGTH_MAX-2];        //SNAKE_LENGHT_MAX = head + current numbers of body
reg [6:0] snake_body_y_reg [0:SNAKE_LENGTH_MAX-2];        
reg [SNAKE_LENGTH_BIT-1:0] snake_length;               
reg [6:0] fruit_x, fruit_y;
reg up, down, left, right;

wire right_sync, left_sync;
reg right_register, left_register;
reg [1:0]right_shifter, left_shifter;

wire [6:0] new_position_x, new_position_y;
wire fruit_eaten;
reg [SNAKE_LENGTH_MAX-2:0] collision_vector;
reg [SNAKE_LENGTH_MAX-2:0] fruit_vector;

reg  up_tail, down_tail, left_tail, right_tail;
reg [SNAKE_LENGTH_BIT-1:0] tail_count;

reg collision_fruit, collision_detected;


//FSM output definition

reg en_move, en_fruit, generate_fruit, start, game_over, sync_reset, send;


// Indice per ciclo for
integer i; 
integer j=0;



// Moore state machine register

always @(posedge clock_25 or negedge reset)

    if (~reset)
        current_state <= RESET_IDLE;   // Initialize the state to IDLE (initial state)
        
    
    else 
        current_state <= next_state;  // If reset is not active, update the current state with the next state



// Logic to update the game states of the FSM

always @(current_state, left_sync, right_sync, game_tik, collision_detected, fruit_eaten, collision_fruit)
    
    case (current_state)
        
        RESET_IDLE:  begin
            next_state = IDLE;
        end

        IDLE: begin
        
            if (right_sync || left_sync)  // If the player provides input (movement), transition to WAIT state
                next_state = WAIT;
            else 
                next_state = IDLE;
        end
        
        WAIT: begin

            if (game_tik)           //if game_tik is set to 1 the snake goes to MOVING and it moves of 1 block
            next_state = MOVING;
        else
            next_state = WAIT;
            
        end

        MOVING: begin
            next_state = MOVE_DONE;
        end

        MOVE_DONE: begin
            if (collision_detected)
                next_state = COLLISION;        // If a collision occurs, change state to COLLISION

            else if (fruit_eaten)
                next_state = EATEN_FRUIT;      // If the snake eats a fruit, change state to EATEN_FRUIT
            
            else
                next_state = WAIT;
        
        end

        EATEN_FRUIT: begin         
                next_state = FRUIT_UPDATE;        
        end

        FRUIT_UPDATE: begin                     // If there is a generation collision, continue updating fruit position
        if(collision_fruit)
            next_state = FRUIT_UPDATE;
        else
            next_state = WAIT;
        end

        
        
        COLLISION: begin
            // In case of collision, the game ends and remains in the COLLISION (game over) until when the player press a bottom
            if (right_sync || left_sync) 
                next_state = RESET_IDLE;
            else 
                next_state = COLLISION;
        end

        default: next_state = RESET_IDLE; // Default state

    endcase




// Logica di uscita della FSM

always @(current_state) 
    case (current_state)
        WAIT: begin
            send = 1'b0;                //if set to 1 it send the initial snake body postion to the graphic game
            en_move = 1'b0;             //if set to 1 the snake moves
            sync_reset= 1'b0;           //syncronus reset to restart the game when the game restart
            en_fruit = 1'b0;            //if set to 1 it generates a new fruit position and increment the score
            generate_fruit= 1'b0;       //if set to 1 it generates a new fruit position
            start = 1'b1;               //if set to 1 the game has started
            game_over =1'b0;            //if set to 1 there is a game over
                
            
        end
        
        EATEN_FRUIT: begin
            send = 1'b0;
            en_move = 1'b0;
            sync_reset= 1'b0;
            en_fruit = 1'b1;
            generate_fruit = 1'b0; 
            start = 1'b1;
            game_over =1'b0;
                
        end

        FRUIT_UPDATE: begin
            send = 1'b0;
            en_move = 1'b0;
            sync_reset= 1'b0;
            en_fruit = 1'b0;
            generate_fruit =1'b1; 
            start = 1'b1;
            game_over =1'b0;
            
        end
        
        COLLISION: begin
            send = 1'b0;           
            en_move = 1'b0;
            sync_reset= 1'b0;
            en_fruit = 1'b0; 
            generate_fruit = 1'b0; 
            start = 1'b0;
            game_over =1'b1;
        end

        MOVING: begin
            send = 1'b0;
            en_move = 1'b1;
            sync_reset= 1'b0;
            en_fruit = 1'b0;
            generate_fruit = 1'b0; 
            start = 1'b1;
            game_over =1'b0;
        end

        MOVE_DONE: begin
            send = 1'b0;
            en_move = 1'b0;
            sync_reset= 1'b0;
            en_fruit = 1'b0;
            generate_fruit = 1'b0; 
            start = 1'b1;
            game_over =1'b0;
        end

        IDLE: begin
            send = 1'b1;
            en_move = 1'b0;
            sync_reset =1'b0;
            en_fruit = 1'b0;
            generate_fruit = 1'b0; 
            start = 1'b0;
            game_over =1'b0;
        end

        RESET_IDLE: begin
            send = 1'b0;
            en_move = 1'b0;
            sync_reset =1'b1;
            en_fruit = 1'b0;
            generate_fruit = 1'b0; 
            start = 1'b0;
            game_over =1'b0;
        end
            
        default begin
            send = 1'b0;
            en_move = 1'b0;
            sync_reset =1'b1;
            en_fruit = 1'b0;
            generate_fruit = 1'b0; 
            start = 1'b0;
            game_over =1'b0;
        end


    endcase


//body_count is reset only in RESET_IDLE state or after every snake's move. After a collision or when the counter is equal to the snake lenght max body_count stops to count  
    always @ (posedge clock_25 or negedge reset) begin
        if (~reset)
            body_count <= 0;
        
        else if (sync_reset)
            body_count <= 0;

        else if (send) begin
            if( body_count == SNAKE_LENGTH_MAX-2)
                body_count <= body_count;
            else
            body_count <= body_count + 1'b1;    
        end
		  
        else if (en_move==1'b1)  
                body_count<=0;
        
        else if(collision_detected== 1'b1 || body_count == SNAKE_LENGTH_MAX-2)
                body_count <= body_count;
        else
            body_count <= body_count + 1'b1;
                
    end
    
//body's vector is sent to graphich_game bit per bit 
    always @ (posedge clock_25 or negedge reset) begin
        if (~reset) begin                               // starting postion is sent
            snake_body_x <= BEGIN_SNAKE_HEAD_X -1'b1;
            snake_body_y <= BEGIN_SNAKE_HEAD_Y;
        end
    
        else if (sync_reset==1'b1) begin                // starting postion is sent
            snake_body_x <= BEGIN_SNAKE_HEAD_X -1'b1;
            snake_body_y <= BEGIN_SNAKE_HEAD_Y;
            
        end
        else  begin
            snake_body_x <= snake_body_x_reg[body_count];
            snake_body_y <= snake_body_y_reg[body_count];
        end
    end

// Body's vector initialization and updates if en_move == 1
    always @ (posedge clock_25 or negedge reset) begin 

        if(~reset) begin
            snake_head_x <= BEGIN_SNAKE_HEAD_X;    // Initial position of the snake's head 
            snake_head_y <= BEGIN_SNAKE_HEAD_Y;    
            snake_length <= BEGIN_SNAKE_LENGTH;    // Initial length of the snake 
            fruit_x <= BEGIN_FRUIT_X;              // Initial position of the fruit
            fruit_y <= BEGIN_FRUIT_Y;
            score <= 7'd0;                         // Initial game score   
        end
        
        else if(sync_reset ) begin // SYNC INITIALIZATION
    
            snake_head_x <= BEGIN_SNAKE_HEAD_X;    
            snake_head_y <= BEGIN_SNAKE_HEAD_Y;    
            snake_length <= BEGIN_SNAKE_LENGTH;    
            fruit_x <= BEGIN_FRUIT_X;              
            fruit_y <= BEGIN_FRUIT_Y;
            score <= 7'd0;                          
    
            for (i=0; i<= SNAKE_LENGTH_MAX-2 ;i=i+1) begin  //initial snake_body_reg 
                
                if (i < BEGIN_SNAKE_LENGTH-1'b1) begin
                    snake_body_x_reg[i] <= BEGIN_SNAKE_HEAD_X-i-1'b1;
                    snake_body_y_reg[i] <= BEGIN_SNAKE_HEAD_Y;
                end
                else begin
                    snake_body_x_reg[i] <= 7'b1111111;
                    snake_body_y_reg[i] <= 7'b1111111;
                end
            end
    
        end
    
        else if(en_move==1'b1) begin                           
            // Update the snake's head position based on input
                if (up) begin
                    if (snake_head_y > 0) begin
                        snake_head_y <= snake_head_y - 1'b1;    // Move the snake up
                        snake_head_x <= snake_head_x;
                    end
                end 
                
                else if (down) begin
                    if (snake_head_y < VERTICAL_CELLS_NUM-1'b1) begin
                        snake_head_y <= snake_head_y + 1'b1;    // Move the snake down
                        snake_head_x <= snake_head_x;
                    end
                end 
                
                else if (left) begin
                    if (snake_head_x > 0)  begin
                        snake_head_x <= snake_head_x - 1'b1;    // Move the snake left
                        snake_head_y <= snake_head_y;
                    end
                end 
                
                else if (right) begin
                    if (snake_head_x < HORIZONTAL_CELLS_NUM-1'b1) begin
                        snake_head_x <= snake_head_x + 1'b1;    // Move the snake right
                        snake_head_y <= snake_head_y;
                    end
                end
                
                // Update the snake's body
                    
                    // The first body segment follows the snake's head
                snake_body_x_reg[0] <= snake_head_x;
                snake_body_y_reg[0] <= snake_head_y; 
    
                // The body moves by shifting each segment to the position of the previous segment
                for (i =1; i <=SNAKE_LENGTH_MAX-2 ; i = i + 1) begin
                    
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
    
        else if(en_fruit) begin         //if the snake has eaten a fruit a new fruit position is assigned
            fruit_x <= new_position_x;
            fruit_y <= new_position_y;
                // Increment the score when the snake eats a fruit
            if(score == 7'd99)
                score <= 7'd0;      
            else
                score <= score + 1'b1; 
    
            // Increase the snake's length
            if(snake_length == SNAKE_LENGTH_MAX-1'b1) 
                snake_length <= snake_length;
            else
                snake_length <= snake_length + 1'b1;
        end
        
    
        else if(generate_fruit) begin       //it only assign a new fruit position
                if(collision_fruit)begin
                    fruit_x <= new_position_x;
                    fruit_y <= new_position_y;
                end
        end
    
    end
    
    
    // Assignment of the fruit_eaten bit
    
    assign fruit_eaten = (fruit_x==snake_head_x && fruit_y == snake_head_y) ? 1'b1 : 1'b0;
    
    // Generate a new position for the fruit (random)
    
    PRBS random_sequence_x(
        .clock_25(clock_25),
        .reset(reset),
        .initial_seed(7'b0011100),
        .rnd(new_position_x)
    );
    
    PRBS random_sequence_y(
        .clock_25(clock_25),
        .reset(reset),
        .initial_seed(7'b0110000),
        .rnd(new_position_y)
    );
    
// Check if the new fruit collides with the snake's body or is outside the game area
    always @ (*) begin
        for (i = 0; i < SNAKE_LENGTH_MAX - 1; i = i + 1) begin
            if (fruit_x == snake_body_x_reg[i] && fruit_y == snake_body_y_reg[i])
                fruit_vector[i] = 1'b1;
            else 
                fruit_vector[i] = 1'b0;
        end
    end
    
    always @ (*) begin
        if((fruit_x == snake_head_x && fruit_y == snake_head_y) || fruit_vector > 0 || 
           (fruit_x >= HORIZONTAL_CELLS_NUM - 1'b1) || (fruit_y >= VERTICAL_CELLS_NUM - 1'b1) || 
           (fruit_x <= 1) || (fruit_y <= 1))
            collision_fruit = 1'b1;
        else
            collision_fruit = 1'b0;    
    end
    
    
    // Collision detector           
    always @ (*) begin
        for (j = 0; j < SNAKE_LENGTH_MAX - 1'b1; j = j + 1'b1) begin
            // Check if the snake's head is at the same position as one of the body segments
            if (snake_head_x == snake_body_x_reg[j] && snake_head_y == snake_body_y_reg[j])
                collision_vector[j] = 1'b1; // If the snake's head is on its body, collision detected
            else 
                collision_vector[j] = 1'b0;
        end
    end
    
    always @ (*) begin
        // Check if the snake's head is outside the game boundaries
        if ((snake_head_x == 1 && left == 1) || (snake_head_x == HORIZONTAL_CELLS_NUM && right == 1) ||
            (snake_head_y == 1 && up == 1) || (snake_head_y == VERTICAL_CELLS_NUM && down == 1))
    
            collision_detected = 1'b1; // If the head is outside the grid (out of bounds), return 1 (collision)
        
        else if (collision_vector > 0) // Check if the snake's head has hit its body 
            collision_detected = 1'b1;
        
        else        
            collision_detected = 0; // Initially, no collision detected      
    end
    

// Synchronizes asynchronous button presses on the input positive edge, avoiding bounces, generating a high-active synchronous pulse for one clock cycle

// right_P
   button_control_fsm my_button_control_fsm_1(
    .reset(reset), 
    .clock_25(clock_25),
    .async_button(right_P), 
    .sync_button(right_sync),
    .en_rise(1'b1)
   );
    
    // left_P
   button_control_fsm my_button_control_fsm_2(
    .reset(reset), 
    .clock_25(clock_25),
    .async_button(left_P), 
    .sync_button(left_sync),
    .en_rise(1'b1)
   );
    // assign right_register and left_register that will take the value of right_sync and left_sync inputs 
    // until the next move is completed, that is, until entering the move_done state.
    always @ (posedge clock_25 or negedge reset) begin 
    
        if (~reset) begin
            right_register <= 1'b0;
            left_register <= 1'b0;
        end
            
        else if (sync_reset) begin
             right_register <= 1'b0;
            left_register <= 1'b0;
        end
            
        else if(send==1'b0 && (right_sync==1'b1 || left_sync==1'b1)) begin   // If the user presses a button, registers are updated
            if(right_sync==1'b1 && left_sync==1'b1 ) begin   // If the user presses both buttons, the snake does not change direction
                right_register <= 1'b0;
                left_register <= 1'b0;
            end 
            else begin
                right_register <= right_sync;
                left_register <= left_sync;
            end
        end
        else if(en_move==1'b1) begin        // At the end of the move, registers return to 0
            right_register <= 1'b0;
            left_register <= 1'b0;
        end
        else begin
            right_register <= right_register;
            left_register <= left_register;
        end 
    end
    
    // Converts the input into the actual snake movement directions
    always @ (posedge clock_25 or negedge reset) begin 
    
        if (~reset) begin
            down <= 1'b0;
            up <= 1'b0;
            right <= 1'b1; // The game starts with the snake moving to the right
            left <= 1'b0;
        end
            
        else if (sync_reset) begin
            down <= 1'b0;
            up <= 1'b0;
            right <= 1'b1; 
            left <= 1'b0;
        end
        
        // If a button is pressed, modify the movement direction
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
        else begin              // If no button is pressed, maintain the current movement
            right <= right;
            left <= left;
            up <= up;
            down <= down;
        end
    end
    
    // Assign up_tail, down_tail, left_tail, right_tail for the correct print in graphic_game of the tail when the snake turns 
    
    always @(posedge clock_25 or negedge reset) begin       //assign tail_count which comunicate to the tail when change direction when it arrivs to snake_length-2
        if (~reset)
            tail_count <= 0;
    
        else if(sync_reset)
            tail_count <= 0;
        
        else if (down == down_tail && up == up_tail && right == right_tail && left == left_tail)
            tail_count <= 0;
    
        else if (en_move == 1'b1)
            tail_count <= tail_count +1;
    
        else 
            tail_count <= tail_count;
    end
    
    always @(posedge clock_25 or negedge reset) begin
        if (~reset) begin
            up_tail<=1'b0;
            down_tail<=1'b0;
            left_tail<= 1'b0;
            right_tail<=1'b1;
       end
       else if (sync_reset) begin
            up_tail<=1'b0;
            down_tail<=1'b0;
            left_tail<= 1'b0;
            right_tail<=1'b1;
       end
       else if(tail_count == snake_length-2) begin
            up_tail<=up;
            down_tail<=down;
            left_tail<= left;
            right_tail<=right;
       end
       else begin
            up_tail<=up_tail;
            down_tail<=down_tail;
            left_tail<= left_tail;
            right_tail<=right_tail;
       end
    end
    endmodule
    



