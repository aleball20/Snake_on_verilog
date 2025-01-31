/*This module generates the Asyncronus global reset which will be syncronized with the release*/

module global_reset(async_reset, reset, clock_25);
input async_reset;
input clock_25;
output reset;
reg [1:0] D_FF;
always @(posedge clock_25 or negedge async_reset) begin
    if(~async_reset)
        D_FF <= 2'b00;
    else 
        D_FF <= { D_FF[0], 1'b1};
end

assign reset = D_FF[1];
endmodule