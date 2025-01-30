
module vga_tracker (display_area, frame_tik, clock_25, h_sync, v_sync, reset, X, Y);

parameter PIXEL_DISPLAY_BIT   = 9;

//parmetri VGA 640x480 freq 60Hz (all the parameter will be MAIUSCOL)

//orizontal (this are clock cycles)
parameter H_DISPLAY           = 640; //orizontal visualized pixels (active video)
parameter H_FRONT_PORCH       = 16; //orizontal front porch
parameter H_SYNC_PULSE        =96; //orizontal sync pulse
parameter H_BACK_PORCH        = 48; //orizontal back porch

parameter H_TOTAL = H_DISPLAY + H_FRONT_PORCH + H_SYNC_PULSE + H_BACK_PORCH; //total orizontal pixels 300

//vertical (this are lines cycles)
parameter V_DISPLAY           = 480; //vertical visualized pixels (active video)
parameter V_FRONT_PORCH       = 10; //vertical front porch
parameter V_SYNC_PULSE        =2; //vertical sync pulse
parameter V_BACK_PORCH        = 33; //vertical back porch

parameter V_TOTAL = V_DISPLAY + V_FRONT_PORCH + V_SYNC_PULSE + V_BACK_PORCH; //total vertical pixels 535 lines

input clock_25, reset;                  //vga's clock(equal to the total number of pixels in the monitor * 60Hz =25,2MHz ), reset
output h_sync, v_sync;                  //orizzontal & vertical syncronization
output display_area,                    //bit that is set to one in the display area
output frame_tik;                       //it is set to one when the traker gets to the vertical front porch
output [PIXEL_DISPLAY_BIT:0] X,Y;       //X and Y trakers
reg [PIXEL_DISPLAY_BIT:0] X;
reg [PIXEL_DISPLAY_BIT:0] Y;


// Generation of horizontal and vertical synchronization signals

always @(posedge clock_25 or negedge reset) begin
    if (~reset) begin
        X <= 10'b0000000000;
        Y <= 10'b0000000000;
    end else begin
        if (X < H_TOTAL - 1)
            X <= X + 1'b1;
        else begin
            X <= 10'b0000000000;
            if (Y < V_TOTAL - 1'b1)
                Y<= Y + 1'b1;
            else
                Y <= 10'b0000000000;
        end
    end
end

// Synchronization signals
assign display_area = (X >= H_BACK_PORCH) && (X < H_DISPLAY + H_BACK_PORCH) && (Y > V_BACK_PORCH) && (Y < V_DISPLAY + V_BACK_PORCH);
assign h_sync = ~(X >= (H_BACK_PORCH + H_DISPLAY + H_FRONT_PORCH) && X< ( H_BACK_PORCH + H_DISPLAY + H_FRONT_PORCH + H_SYNC_PULSE));
assign v_sync = ~(Y>= (V_BACK_PORCH + V_DISPLAY + V_FRONT_PORCH) && Y < (V_BACK_PORCH + V_DISPLAY + V_FRONT_PORCH + V_SYNC_PULSE));
assign frame_tik = ~v_sync;

endmodule
