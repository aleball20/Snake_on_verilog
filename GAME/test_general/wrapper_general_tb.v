
`timescale 1ns/100ps


module wrapper_general_tb;

parameter PIXEL_DISPLAY_BIT = 9;

reg  clock_25_tb, reset_tb;
reg right_P_tb, left_P_tb;

wire [6:0] snake_head_x_tb, snake_head_y_tb, snake_body_x_tb, snake_body_y_tb, fruit_x_tb, fruit_y_tb;
wire [3:0] snake_length_tb;
wire[7:0] score_tb;
wire VGA_HS_tb, VGA_VS_tb;
wire frame_tik_tb;
wire game_tik_tb;
wire collision_detected_tb;
wire right_tb, left_tb, up_tb, down_tb, right_sync_tb, left_sync_tb, right_register_tb, left_register_tb;
wire display_area_tb;
wire [PIXEL_DISPLAY_BIT:0] X_tb,Y_tb; 
wire [2:0] next_state_tb, current_state_tb;

wire game_enable_tb, game_area_tb, semaforo_tb;
wire [1:0] game_data_tb, selected_figure_tb;
wire [6:0] x_block_tb, y_block_tb;    
wire[2:0] x_local_tb, y_local_tb;    

wrapper_general_for_test my_wrapper_general_for_test(
    .clock_25(clock_25_tb),
    .reset(reset_tb),
    .right_P(right_P_tb),
    .left_P(left_P_tb),
    .X(X_tb),
    .Y(Y_tb),
	 .x_block(x_block_tb),
	.y_block(y_block_tb),
	.x_local(x_local_tb),
	.y_local(y_local_tb),
    .snake_head_x(snake_head_x_tb),
    .snake_head_y(snake_head_y_tb), 
    .snake_body_x(snake_body_x_tb),
    .snake_body_y(snake_body_y_tb),
    .fruit_x(fruit_x_tb), 
    .fruit_y(fruit_y_tb),
    .snake_length(snake_length_tb),
    .VGA_HS(VGA_HS_tb), 
    .VGA_VS(VGA_VS_tb),
    .frame_tik(frame_tik_tb),
    .game_tik(game_tik_tb),
    .display_area(display_area_tb),
    .collision_detected(collision_detected_tb),
    .score(score_tb),   
    .current_state(current_state_tb),
	 .next_state(next_state_tb),
    .right(right_tb),
	 .left(left_tb),
	 .up(up_tb),
    .down(down_tb),
    .right_sync(right_sync_tb), 
    .left_sync(left_sync_tb),
    .right_register(right_register_tb), 
    .left_register(left_register_tb),
	 .selected_figure(selected_figure_tb),
    .game_enable(game_enable_tb), 
    .game_area(game_area_tb),
    .semaforo(semaforo_tb),
    .game_data(game_data_tb)    
);

//clock generation
always
begin
    #20 clock_25_tb= 1'b1;
    #20 clock_25_tb= 1'b0;
end

initial begin
    reset_tb=0;
	 left_P_tb=0;
	 right_P_tb=0;
    #50;  //test the IDLE state
	 reset_tb=1;
     left_P_tb=0;
     right_P_tb=0; 
     #1000000;
     right_P_tb =1;
	#50
    right_P_tb =0;
 #10000000;
	right_P_tb =1;
    #50
    right_P_tb =0;
	#100000000;
	right_P_tb =1;
    #50
    right_P_tb =0;
	#1000000000;
    left_P_tb =1'b1;
    #50
    left_P_tb =1'b0;
    #1000000;

end

endmodule