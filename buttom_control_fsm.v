/*This buttom takes input buttoms and delates the bouncing, and it gets sensible only to the rise of the signal if en_rise is set to 1 */

module buttom_control_fsm(reset, clock_25, async_buttom, sync_buttom, en_rise);

//fsm states
parameter IDLE = 2'b00;
parameter PRESS_BUTTOM = 2'b01;
parameter SEND = 2'b10;
parameter WAIT = 2'b11;

input reset;
input en_rise;
input clock_25;
input async_buttom;
output sync_buttom;

reg [1:0] current_state, next_state;
reg [20:0] counter;
reg sync_buttom;


//register for Moore's machine

always @(posedge clock_25 or negedge reset)

    if (~reset)
        current_state <= IDLE;   // reset inizaliation
        
    else 
        current_state <= next_state;  // next_state assignment

always @(*) begin       //combinatory network for deciding the next states

    case (current_state)
        
        IDLE:  begin
            if (async_buttom==1'b1)
                next_state = PRESS_BUTTOM;
            else
                next_state = IDLE;
        end

        PRESS_BUTTOM: begin
            if(counter[20]==1'b1)
                next_state = SEND;
            else if (async_buttom== 1'b1)
                next_state = PRESS_BUTTOM;
            else
                next_state = IDLE;
        end 

        SEND: begin
            if (en_rise==1'b0 && async_buttom == 1'b1)
                next_state = SEND;
            else
                next_state = WAIT;
        end

        WAIT: begin
            if (async_buttom==1'b1)
                next_state = WAIT;
            else
                next_state = IDLE;
        end

        default:      next_state = IDLE;
    endcase
end

always @ (current_state) begin
    if(current_state== SEND)
        sync_buttom = 1'b1;
    else 
        sync_buttom = 1'b0;
end

always @ (posedge clock_25 or negedge reset) begin

    if(~reset)
        counter <= 0;
    else if(current_state == PRESS_BUTTOM)
        counter <= counter +1'b1;
    else 
        counter <= 0;
end

endmodule