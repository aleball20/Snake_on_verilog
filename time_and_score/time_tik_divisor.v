

/* using a dimension of 26 FF we can have a time tik in the MSB simmilar to 1 second
in fact 2**25= 33554432, 33554432*40*10^-9=1.34 sec*/

module  time_tik_divisor (clock_25, sync_reset, start, reset, time_tik);  

output time_tik;
input sync_reset;
input clock_25, reset, start;
parameter dimension = 25; 
reg [dimension-1:0] out=0;

//arechitettura

always @ (posedge clock_25, negedge reset) begin
    if(~reset)
        out <=0;
	else if ( sync_reset || ~start )
		out <= 0;
    else if(out==(2**dimension)-1)
		out <=0;
	else
		out <= out +1'b1;
	
end

assign time_tik =out[dimension-1];

endmodule