/*This button takes input buttons and delates the bouncing, and it gets sensible only to the rise of the signal if en_rise is set to 1 */

module button_control_fsm(reset, clock_25, async_button, sync_button, en_rise);

//fsm states
parameter IDLE = 2'b00;
parameter PRESS_BUTTON= 2'b01;
parameter SEND = 2'b10;
parameter WAIT = 2'b11;

input reset;
input en_rise;
input clock_25;
input async_button;
output sync_button;

reg [1:0] current_state, next_state;
reg [20:0] counter;
reg sync_button;


//register for Moore's machine

always @(posedge clock_25 or negedge reset)

    if (~reset)
        current_state <= IDLE;   // reset inizaliation
        
    else 
        current_state <= next_state;  // next_state assignment

always @(*) begin       //combinatory network for deciding the next states

    case (current_state)
        
        IDLE:  begin                    //waiting for a pressed button
            if (async_button==1'b1)
                next_state = PRESS_BUTTON;
            else
                next_state = IDLE;
        end

        PRESS_BUTTON: begin            //button has be pressed but there coud be an bouncing, then output in this state continues to be 0
            if(counter[20]==1'b1)        //ater 83ms where button continue to be enabled, the output can be sent
                next_state = SEND;
            else if (async_button== 1'b1)
                next_state = PRESS_BUTTON;
            else
                next_state = IDLE;
        end 

        SEND: begin                    //output is sent, if en_rise == 1'b1 output is enabled just for one cycle
            if (en_rise==1'b0 && async_button == 1'b1)
                next_state = SEND;
            else
                next_state = WAIT;
        end

        WAIT: begin                    //waitng that that async_button stops to be pushed
            if (async_button==1'b1)
                next_state = WAIT;
            else
                next_state = IDLE;
        end

        default:      next_state = IDLE;
    endcase
end

always @ (current_state) begin
    if(current_state== SEND)
        sync_button = 1'b1;
    else 
        sync_button = 1'b0;
end

always @ (posedge clock_25 or negedge reset) begin

    if(~reset)
        counter <= 0;
    else if(current_state == PRESS_BUTTON)
        counter <= counter +1'b1;
    else 
        counter <= 0;
end

endmodule
