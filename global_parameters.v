// global_parameters

`define SNAKE_LENGTH_BIT  4
`define SNAKE_LENGTH_MAX  16      //(2**SNAKE_LENGTH_BIT); maximun snake's lenght
`define PIXEL_DISPLAY_BIT  9

`define HORIZONTAL_CELLS_NUM 124 //da aggiungere in futuro
`define VERTICAL_CELLS_NUM 81
`define CELLS_BIT 7
`define ADDR_MAX  10044         //HORIZONTAL_CELLS_NUM * VERTICAL_CELLS_NUM;  maximun editable RAM address

//definizione posizioni iniziali 
`define BEGIN_SNAKE_HEAD_X 7'd8  // Posizione iniziale della testa del serpente (centrato sulla griglia)
`define BEGIN_SNAKE_HEAD_Y 7'd40    // Posizione centrata nella griglia di 124x81
`define BEGIN_SNAKE_LENGTH 14'd6       // Lunghezza iniziale del serpente (ad esempio, 4 segmenti)
`define BEGIN_FRUIT_X 7'd8        // Posizione iniziale del frutto (randomizzata o predefinita)
`define BEGIN_FRUIT_Y 7'd42


// Definizione degli stati della macchina a stati finiti della FM1
`define IDLE  3'b000
`define WAIT  3'b001
`define EATEN_FRUIT  3'b010
`define COLLISION  3'b011
`define MOVING  3'b100
`define MOVE_DONE 3'b101
`define FRUIT_UPDATE  3'b110
`define FRUIT_DONE 3'b111

//Definizione colori

  `define BLACK 2'b00
  `define GREEN 2'b01
  `define RED  2'b10
  `define WHITE  2'b11


