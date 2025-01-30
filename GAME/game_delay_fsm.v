/* This module generates a 1 clock impulse, that comunicates in the Snake_game_fsm when the snake can move.
This impulse can be generated with a period multiple of the frame_tik freqeuncy, in this way, we know that the 
VGA traker is in vertical front porch, not modifing the game area.
User can choose among 4 different speed levels by setting high or low the SW in the fpga */


module game_delay_fsm(clock_25, reset, start, frame_tik, game_tik, SW17, SW16, SW15);

input clock_25;
input reset;
input frame_tik;
input start;    
input SW17, SW16, SW15;
output reg game_tik;

reg [3:0] current_state; 
reg [3:0] next_state;

//fsm states:

parameter  IDLE = 4'b0000;
parameter  CHOOSE_LEVEL = 4'b0001;
parameter  LEVEL_1 = 4'b1001;
parameter  LEVEL_2 = 4'b0010;
parameter  LEVEL_3 = 4'b0011;
parameter  LEVEL_4 = 4'b0100;
parameter  WAIT_END_1= 4'b1010;    
parameter  WAIT_END_2= 4'b0101;
parameter  WAIT_END_3= 4'b0110;
parameter  WAIT_END_4= 4'b0111;
parameter  GAME_TIK_GEN = 4'b1000;  //it is also the level 4


//register for Moore's machine

always @(posedge clock_25 or negedge reset)

    if (~reset)
        current_state <= IDLE;   // reset inizaliation
        
    else 
        current_state <= next_state;  // next_state assignment

always @(*) begin       //combinatory network for deciding the next states

    case (current_state)
        
        IDLE:  begin
            if (start==1'b1)
                next_state = CHOOSE_LEVEL;
            else
                next_state = IDLE;
        end

        CHOOSE_LEVEL: begin     // different levels for different switches settings, if start is set to 0 it comes back to IDLE
            if (start == 1'b0)
                next_state = IDLE;

            else if(SW17== 1'b0 && SW16 == 1'b0 && SW15 == 1'b0)
                next_state = LEVEL_1;
            
            else if(SW17 == 1'b1 && SW16 == 1'b0 && SW15 == 1'b0)
                next_state = LEVEL_2;
            
            else if(SW16 == 1'b1 && SW15 == 1'b0)
                next_state = LEVEL_3;
            
            else if(SW15 == 1'b1)
                next_state = LEVEL_4;
            else
                next_state = LEVEL_1;
        end

//levels change state when frame_tik==1
        LEVEL_1: begin
            if(frame_tik==1'b1)
                next_state = WAIT_END_1;
            else
                next_state = LEVEL_1;
        end 

        LEVEL_2: begin
            if(frame_tik==1'b1)
                next_state = WAIT_END_2;
            else
                next_state = LEVEL_2;
        end    

        LEVEL_3: begin
            if(frame_tik==1'b1)
                next_state = WAIT_END_3;
            else
                next_state = LEVEL_3;
        end    

        LEVEL_4: begin
            if(frame_tik== 1'b1)
                next_state = GAME_TIK_GEN;
            else
                next_state = LEVEL_4;
        end
//when frame_tik==0 we pass to the next state
        WAIT_END_1:  begin
            if(frame_tik == 1'b0)
                next_state = LEVEL_2;
            else
                next_state = WAIT_END_1;
        end

        WAIT_END_2:  begin
            if(frame_tik == 1'b0)
                next_state = LEVEL_3;
            else
                next_state = WAIT_END_2;
        end

        WAIT_END_3: begin
            if(frame_tik == 1'b0)
                next_state = LEVEL_4;
            else
                next_state = WAIT_END_3;
        end  

        GAME_TIK_GEN: next_state = WAIT_END_4;  //game_tik stays turned just for one clock cylce 

        WAIT_END_4: begin
            if(frame_tik == 1'b0)
                next_state = CHOOSE_LEVEL;
            else
                next_state = WAIT_END_4;
        end

        default:      next_state = IDLE;
    endcase
end

always @ (current_state) begin
    if(current_state== GAME_TIK_GEN)
        game_tik = 1'b1;
    else 
        game_tik = 1'b0;
end

endmodule