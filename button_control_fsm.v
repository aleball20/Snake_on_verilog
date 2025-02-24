/*This button takes input buttons, it gets sensible only to the rise of the signal if en_rise is set to 1 */

module button_control_fsm(reset, clock_25, async_button, sync_button, en_rise);



input reset;
input en_rise;
input clock_25;
input async_button;
output sync_button;

reg [2:0] register;
reg sync_button;

always @ (posedge clock_25 or negedge reset) begin
    if (~reset)
        register <= 3'b000;
    else 
        register <= {register[1:0], async_button};
end
always@(*) begin
    if(en_rise==1'b1)
        sync_button = register[1] & ~register[2];
    else
        sync_button= register[1];
end

endmodule