

module PRBS (clock_25, seed, reset, rnd);
input reset;
input clock_25;
input [6:0] seed;         // Random value from where starting the randome sequence, equal to the snake_head  
output [6:0] rnd;                 // I have put the dimension equals to 7 bit but we can change it


reg [6:0] rnd;  //shift register for the PRBS generator (8bit rnd)

always @ (posedge clock_25 or negedge reset) //generates the random secuence 
begin

    if(~reset) // when Reset is active the random sequence restart
            rnd <= seed;    
    else
        begin
            rnd<={rnd[5:0],rnd[6]^rnd[5]};   //it generates the next random value by calculating the bit with a XOR (rnd,[5]:0]: The 5 bits less significative are shifted to the right
															// rnd[6] ^ rnd[5]:The new bit it's calculated with an XOR betwwen the bit 6 and 5 
        end    

end

endmodule