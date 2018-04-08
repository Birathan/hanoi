module hanoi3(
                CLOCK_50,                                               //     On Board 50 MHz
                SW,
                // Your inputs and outputs here
					 HEX0,
					 KEY,
                LEDR,
					 LEDG,
                // The ports below are for the VGA output.  Do not change.
                VGA_CLK,                                                //     VGA Clock
                VGA_HS,                                                 //     VGA H_SYNC
                VGA_VS,                                                 //     VGA V_SYNC
                VGA_BLANK_N,                                            //     VGA BLANK
                VGA_SYNC_N,                                             //     VGA SYNC
                VGA_R,                                                  //     VGA Red[9:0]
                VGA_G,                                                  //     VGA Green[9:0]
                VGA_B                                                   //     VGA Blue[9:0]
        );
   	  input [17:0] SW;
        input CLOCK_50; 		  //     50 MHz
        input [3:0] KEY;
		  output [6:0] HEX0;
        output [17:0] LEDR;
		  output [5:0] LEDG;
        // Declare your inputs and outputs here
        // Do not change the following outputs
        output VGA_CLK;                                //     VGA Clock
        output VGA_HS;                                 //     VGA H_SYNC
        output VGA_VS;                                 //     VGA V_SYNC
        output VGA_BLANK_N;                            //     VGA BLANK
        output VGA_SYNC_N;                             //     VGA SYNC
        output [9:0] VGA_R;                            //     VGA Red[9:0]
        output [9:0] VGA_G;                            //     VGA Green[9:0]
        output [9:0] VGA_B;                            //     VGA Blue[9:0]


        // Create an Instance of a VGA controller - there can be only one!
        // Define the number of colours as well as the initial background
        // image file (.MIF) for the controller.
        vga_adapter VGA(
                        .resetn(1'b1),
                        .clock(CLOCK_50),
                        .colour(colour),
                        .x(x),
                        .y(y),
                        .plot(1'b1),
                        /* Signals for the DAC to drive the monitor. */
                        .VGA_R(VGA_R),
                        .VGA_G(VGA_G),
                        .VGA_B(VGA_B),
                        .VGA_HS(VGA_HS),
                        .VGA_VS(VGA_VS),
                        .VGA_BLANK(VGA_BLANK_N),
                        .VGA_SYNC(VGA_SYNC_N),
                        .VGA_CLK(VGA_CLK));
                defparam VGA.RESOLUTION = "160x120";
                defparam VGA.MONOCHROME = "FALSE";
                defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
                defparam VGA.BACKGROUND_IMAGE = "black.mif";
					 
		  wire OneBiggerThanTwo;
		  wire OneBiggerThanThree;		  
		  wire TwoBiggerThanOne;
		  wire TwoBiggerThanThree;
		  wire ThreeBiggerThanOne;
		  wire ThreeBiggerThanTwo;
		  
		  comparator onetwo(piecesizes1[5:4], piecesizes2[5:4], OneBiggerThanTwo);
		  comparator onethree(piecesizes1[5:4], piecesizes3[5:4], OneBiggerThanThree);
		  comparator twoone(piecesizes2[5:4], piecesizes1[5:4],TwoBiggerThanOne);
		  comparator twothree(piecesizes2[5:4], piecesizes3[5:4],TwoBiggerThanThree);
		  comparator threeone(piecesizes3[5:4], piecesizes1[5:4],ThreeBiggerThanOne);
		  comparator threetwo(piecesizes3[5:4], piecesizes2[5:4],ThreeBiggerThanTwo);
		  
		  hex_display ScoreDisplay(movecount, HEX0);
		  
		  reg [4:0]movecount = 8'b00000;
		  reg [5:0] state;
		  reg [5:0] state2;
        reg [7:0] x, y;
	     reg [2:0] colour;
	     reg [17:0] draw_counter;
        reg [7:0] bl_1_x, bl_1_y, bl_2_x, bl_2_y, bl_3_x, bl_3_y, bl_wr_x, bl_wr_y, bl_erase_x, bl_erase_y;
        reg [2:0] bl_1_colour, bl_2_colour, bl_3_colour, bl_wr_colour, bl_erase_colour;
        
		  
		  // NUMBER OF PIECES IN POSITION 1, 2, 3
		  reg [1:0]piecenum1 = 2'b11;
        reg [1:0]piecenum2 = 2'b00;
        reg [1:0]piecenum3 = 2'b00;
		  
		  // LIST OF SIZES FROM TOP TO BOTTOM, FOR EXAMPLE: |01|10|11| means the position has pieces 1, 2, 3 from top to bottom(1 being smallest size, to 3 being largest size)  
		  reg [5:0]piecesizes1 = 6'b011011;
		  reg [5:0]piecesizes2 = 6'b000000;
		  reg [5:0]piecesizes3 = 6'b000000;

		  // TO STORE POSITION THAT IS SOURCE AND DESTINATION
        reg [1:0]source;
        reg [1:0]destination;
        reg wrong_input = 1'b0;
		
        reg [7:0]x1 = 8'd000;
        reg [7:0]x2 = 8'd50;
        reg [7:0]x3 = 8'd100;
			
        reg [7:0]y1 = 8'd100;
        reg [7:0]y2 = 8'd90;
        reg [7:0]y3 = 8'd80;
			
        assign LEDR[17:16] = source;
        assign LEDR[15:14] = destination;
		  assign LEDG[5:0] = piecesizes2;
        assign LEDR[5:0] = state;
	
        localparam
				INIT_BLOCK_ERASE   = 6'b000000,
				INIT_BLOCK_WRONG   = 6'b000001,
      		INIT_BLOCK_1       = 6'b000010,
            INIT_BLOCK_2       = 6'b000011,
      		INIT_BLOCK_3       = 6'b000100,
				START					 = 6'b000101,
				WAIT_PRESS_SOURCE  = 6'b000110,
            WAIT_CLOCK         = 6'b000111,
            WAIT_PRESS_DEST    = 6'b001000,
            CHECK_INPUT        = 6'b001001,
				UPDATE_WRONG_BLOCK = 6'b001010,
				DRAW_WRONG_BLOCK   = 6'b001011,
				UPDATE_BLOCK_ERASE = 6'b001100,
				DRAW_BLOCK_ERASE   = 6'b001101,
            UPDATE_BLOCK_1     = 6'b001110,
            DRAW_BLOCK_1       = 6'b001111,
            UPDATE_BLOCK_2     = 6'b010000,
            DRAW_BLOCK_2       = 6'b010001,
            UPDATE_BLOCK_3     = 6'b010010,
            DRAW_BLOCK_3       = 6'b010011;

        always@(posedge CLOCK_50)
		  begin
				   //block_initing = 1'b0;
               colour = 3'b000;
               x = 8'b00000000;
               y = 8'b00000000;
               //if (SW[0]) state = RESET_BLACK;

					case (state)
                        //START BLOCKS
                        INIT_BLOCK_ERASE:begin
									bl_erase_x = 8'b100;
                           bl_erase_y = 8'b000;
                           bl_erase_colour= 3'b000;
									if(draw_counter < 6'b100000) begin
                              x = x3 + draw_counter[4:0];
                              y = y1 + draw_counter[6:5];
										colour = 3'b000;
                           end
									if(draw_counter < 6'b100000) begin
                              x = x3 + draw_counter[4:0];
                              y = y2 + draw_counter[6:5];
										colour = 3'b000;
                           end
									if(draw_counter < 6'b100000) begin
                              x = x3 + draw_counter[4:0];
                              y = y3 + draw_counter[6:5];
										colour = 3'b000;
                           end
									
									else begin
										draw_counter= 8'b00000000;
										state = INIT_BLOCK_WRONG;
									end
									draw_counter = draw_counter + 1'b1;
                        end

                        INIT_BLOCK_WRONG:begin
                           bl_wr_x = x2;
                           bl_wr_y = 8'b000;
                           bl_wr_colour= 3'b100;
                           state = INIT_BLOCK_1;
                        end

                        INIT_BLOCK_1: begin
                           bl_1_x = x1;
                           bl_1_y = y3;
                           bl_1_colour = 3'b001;
									if (draw_counter < 4'b1000) begin
										x = bl_1_x + draw_counter[2:0];
										y = bl_1_y + draw_counter[4:3];
										draw_counter = draw_counter + 1'b1;
										colour = bl_1_colour;
									end
									else begin
										draw_counter= 8'b00000000;
										state = INIT_BLOCK_2;
									end
                        end

                        INIT_BLOCK_2: begin
                           bl_2_x = x1;
                           bl_2_y = y2;
                           bl_2_colour = 3'b001;
                           if (draw_counter < 5'b10000) begin
										x = bl_2_x + draw_counter[3:0];
										y = bl_2_y + draw_counter[5:4];
										draw_counter = draw_counter + 1'b1;
										colour = bl_2_colour;
									end
									else begin
										draw_counter= 8'b00000000;
										state = INIT_BLOCK_3;
									end
                        end

                        INIT_BLOCK_3: begin
                           bl_3_x = x1;
                           bl_3_y = y1;
                           bl_3_colour = 3'b001;
									if(draw_counter < 6'b100000) begin
                              x = bl_3_x + draw_counter[4:0];
                              y = bl_3_y + draw_counter[6:5];
                              draw_counter = draw_counter + 1'b1;
										colour = bl_3_colour;
                           end
                           else begin
										draw_counter= 8'b00000000;
                              state = START;
                           end
                        end

                        // START HERE
								START: begin
									if(SW[0]) state = WAIT_PRESS_SOURCE;
								end
								
                        WAIT_PRESS_SOURCE: begin
									if(~KEY[3]||~KEY[2]||~KEY[1])
									begin
										if(~KEY[3]) source = 2'b01;
										if(~KEY[2]) source = 2'b10;
										if(~KEY[1]) source = 2'b11;
										state = WAIT_CLOCK;
                          end
                        end

                        WAIT_CLOCK: begin
									if(SW[0]) state = WAIT_PRESS_DEST;
                        end

                        WAIT_PRESS_DEST: begin
									if(~KEY[3]||~KEY[2]||~KEY[1])
									begin
										if(~KEY[3]) destination = 2'b01;
										if(~KEY[2]) destination = 2'b10;
										if(~KEY[1]) destination = 2'b11;
										state = CHECK_INPUT;
                          end	
								end
								
								//CHECK VALIDITY OF INPUT AND LOAD VALUES
                        CHECK_INPUT:begin
										wrong_input=1'b0;
										if(source == destination)
											wrong_input = 1'b0;
	
										//CASE 1
										else if((source == 2'd1) && (destination == 2'd2))
										begin
											//if(TwoBiggerThanOne|| piecenum1 == 2'b00)
											//	wrong_input = 1'b0;
											if(1) begin
												if(piecesizes1[5:4] == 2'b01)
												begin
													bl_1_x = x2;
													if(piecenum2 == 2'b00) bl_1_y = y1;
													if(piecenum2 == 2'b01) bl_1_y = y2;
													if(piecenum2 == 2'b10) bl_1_y = y3;
													state2 = DRAW_BLOCK_1;
												end
												
												if(piecesizes1[5:4] == 2'b10)
												begin
													bl_2_x = x2;
													if(piecenum2 == 2'b00) bl_2_y = y1;
													if(piecenum2 == 2'b01) bl_2_y = y2;
													if(piecenum2 == 2'b10) bl_2_y = y3;
													state2 = DRAW_BLOCK_2;
												end
												if(piecesizes1[5:4] == 2'b11)
												begin
													bl_3_x = x2;
													if(piecenum2 == 2'b00) bl_3_y = y1;
													if(piecenum2 == 2'b01) bl_3_y = y2;
													if(piecenum2 == 2'b10) bl_3_y = y3;
													state2 = DRAW_BLOCK_3;
												end
							
												//DESTINATION
												piecesizes2 = piecesizes2 >> 2;
												piecesizes2[5:4] = piecesizes1[5:4];
							
												//SOURCE
												piecesizes1 = piecesizes1 << 2;
												
												//PIECE NUMBERS
												piecenum2 = piecenum2 + 1'b1;
												piecenum1 = piecenum1 - 1'b1;		
											end
										end
			   
										//CASE 2
										else if((source == 2'd1) && (destination == 2'd3))
										begin
											///if(ThreeBiggerThanOne|| piecenum1 == 2'b00)
											//	wrong_input = 1'b0;
											if(1) begin
												if(piecesizes1[5:4] == 2'b01)
												begin
													bl_1_x = x3;
													if(piecenum3 == 2'b00) bl_1_y = y1;
													if(piecenum3 == 2'b01) bl_1_y = y2;
													if(piecenum3 == 2'b10) bl_1_y = y3;
													state2 = DRAW_BLOCK_1;
												end
												if(piecesizes1[5:4] == 2'b10)
												begin
													bl_2_x = x3;
													if(piecenum3 == 2'b00) bl_2_y = y1;
													if(piecenum3 == 2'b01) bl_2_y = y2;
													if(piecenum3 == 2'b10) bl_2_y = y3;
													state2 = DRAW_BLOCK_2;
												end
												if(piecesizes1[5:4] == 2'b11)
												begin
													bl_3_x = x3;
													if(piecenum3 == 2'b00) bl_3_y = y1;
													if(piecenum3 == 2'b01) bl_3_y = y2;
													if(piecenum3 == 2'b10) bl_3_y = y3;
													state2 = DRAW_BLOCK_3;
												end
												//DESTINATION
												piecesizes3 = piecesizes3 >> 2;
												piecesizes3[5:4] = piecesizes1[5:4];
							
												//SOURCE
												piecesizes1 =piecesizes1 << 2;
												
												//PIECE NUMBERS
												piecenum3 = piecenum3 + 1'b1;
												piecenum1 = piecenum1 - 1'b1;		
											end
										end
						
										//CASE 3
										else if((source == 2'd2) && (destination == 2'd1))
										begin
											//if(OneBiggerThanTwo || piecenum2 == 2'b00)
											//	wrong_input = 1'b0;
											if(1)begin
												if(piecesizes2[5:4] == 2'b01)
												begin
													bl_1_x = x1;
													if(piecenum1 == 2'b00) bl_1_y = y1;
													if(piecenum1 == 2'b01) bl_1_y = y2;
													if(piecenum1 == 2'b10) bl_1_y = y3;
													state2 = DRAW_BLOCK_1;
												end
												if(piecesizes2[5:4] == 2'b10)
												begin
													bl_2_x = x1;
													if(piecenum1 == 2'b00) bl_2_y = y1;
													if(piecenum1 == 2'b01) bl_2_y = y2;
													if(piecenum1 == 2'b10) bl_2_y = y3;
													state2 = DRAW_BLOCK_2;
												end
												if(piecesizes2[5:4] == 2'b11)
												begin
													bl_3_x = x1;
													if(piecenum1 == 2'b00) bl_3_y = y1;
													if(piecenum1 == 2'b01) bl_3_y = y2;
													if(piecenum1 == 2'b10) bl_3_y = y3;
													state2 = DRAW_BLOCK_3;
												end
												//DESTINATION
												piecesizes1 = piecesizes1 >> 2;
												piecesizes1[5:4] = piecesizes2[5:4];
							
												//SOURCE
												piecesizes2 = piecesizes2 << 2;
												
												//PIECE NUMBERS
												piecenum1 = piecenum1 + 1'b1;
												piecenum2 = piecenum2 - 1'b1;	
											end
										end
						
										//CASE 4
										else if((source == 2'd2) && (destination == 2'd3))
										begin
											////if(ThreeBiggerThanTwo || piecenum2 == 2'b00)
											//	wrong_input = 1'b0;
											if(1) begin
												if(piecesizes2[5:4] == 2'b01)
												begin
													bl_1_x = x3;
													if(piecenum3 == 2'b00) bl_1_y = y1;
													if(piecenum3 == 2'b01) bl_1_y = y2;
													if(piecenum3 == 2'b10) bl_1_y = y3;
													state2 = DRAW_BLOCK_1;
												end
												if(piecesizes2[5:4] == 2'b10)
												begin
													bl_2_x = x3;
													if(piecenum3 == 2'b00) bl_2_y = y1;
													if(piecenum3 == 2'b01) bl_2_y = y2;
													if(piecenum3 == 2'b10) bl_2_y = y3;
													state2 = DRAW_BLOCK_2;
												end
												if(piecesizes2[5:4] == 2'b11)
												begin
													bl_3_x = x3;
													if(piecenum3 == 2'b00) bl_3_y = y1;
													if(piecenum3 == 2'b01) bl_3_y = y2;
													if(piecenum3 == 2'b10) bl_3_y = y3;
													state2 = DRAW_BLOCK_3;
												end
												//DESTINATION
												piecesizes3 = piecesizes3 >> 2;
												piecesizes3[5:4] = piecesizes2[5:4];
							
												//SOURCE
												piecesizes2 =piecesizes2 << 2;
												
												//PIECE NUMBERS
												piecenum3 = piecenum3 + 1'b1;
												piecenum2 = piecenum2 - 1'b1;	
											end
										end
						
										//CASE 5
										else if((source == 2'd3) && (destination == 2'd1))
										begin
											//if(OneBiggerThanThree || piecenum3 == 2'b00)
											//	wrong_input = 1'b0;
											if(1) begin
												if(piecesizes3[5:4] == 2'b01)
												begin
													bl_1_x = x1;
													if(piecenum1 == 2'b00) bl_1_y = y1;
													if(piecenum1 == 2'b01) bl_1_y = y2;
													if(piecenum1 == 2'b10) bl_1_y = y3;
													state2 = DRAW_BLOCK_1;
												end
												if(piecesizes3[5:4] == 2'b10)
												begin
													bl_2_x = x1;
													if(piecenum1 == 2'b00) bl_2_y = y1;
													if(piecenum1 == 2'b01) bl_2_y = y2;
													if(piecenum1 == 2'b10) bl_2_y = y3;
													state2 = DRAW_BLOCK_2;
												end
												if(piecesizes3[5:4] == 2'b11)
												begin
													bl_3_x = x1;
													if(piecenum1 == 2'b00) bl_3_y = y1;
													if(piecenum1 == 2'b01) bl_3_y = y2;
													if(piecenum1 == 2'b10) bl_3_y = y3;
													state2 = DRAW_BLOCK_3;
												end
												//DESTINATION
												piecesizes1 = piecesizes1 >> 2;
												piecesizes1[5:4] = piecesizes3[5:4];
							
												//SOURCE
												piecesizes3 =piecesizes3 << 2;
												
												//PIECE NUMBERS
												piecenum1 = piecenum1 + 1'b1;
												piecenum3 = piecenum3 - 1'b1;	
											end
										end
						
						
										//CASE 6
										else if((source == 2'd3) && (destination == 2'd2))
										begin
											//if(TwoBiggerThanThree || piecenum3 == 2'b00)
											//	wrong_input = 1'b0;
											if(1) begin
												if(piecesizes3[5:4] == 2'b01)
												begin
													bl_1_x = x2;
													if(piecenum2 == 2'b00) bl_1_y = y1;
													if(piecenum2 == 2'b01) bl_1_y = y2;
													if(piecenum2 == 2'b10) bl_1_y = y3;
													state2 = DRAW_BLOCK_1;
												end
												if(piecesizes3[5:4] == 2'b10)
												begin
													bl_2_x = x2;
													if(piecenum2 == 2'b00) bl_2_y = y1;
													if(piecenum2 == 2'b01) bl_2_y = y2;
													if(piecenum2 == 2'b10) bl_2_y = y3;
													state2 = DRAW_BLOCK_2;
												end
												if(piecesizes3[5:4] == 2'b11)
												begin
													bl_3_x = x2;
													if(piecenum2 == 2'b00) bl_3_y = y1;
													if(piecenum2 == 2'b01) bl_3_y = y2;
													if(piecenum2 == 2'b10) bl_3_y = y3;
													state2 = DRAW_BLOCK_3;
												end
												//DESTINATION
												piecesizes2 = piecesizes2 >> 2;
												piecesizes2[5:4] = piecesizes3[5:4];
							
												//SOURCE
												piecesizes3 =piecesizes3 << 2;
												
												//PIECE NUMBERS
												piecenum2 = piecenum2 + 1'b1;
												piecenum3 = piecenum3 - 1'b1;	
											end
										end
					
										// NEXT STATE
										state = UPDATE_WRONG_BLOCK;
                        end

                        // DRAWING GREEN SQUARE IF VALID MOVE, RED OTHERWIZE
                        UPDATE_WRONG_BLOCK: begin
									if(wrong_input) bl_wr_colour = 3'b100;
                           else begin 
										bl_wr_colour = 3'b010;
										movecount =  movecount+ 1'b1;
									end
									
									if(piecenum3 == 2'b11) state = INIT_BLOCK_ERASE; 
									else state = DRAW_WRONG_BLOCK;
                        end

                        DRAW_WRONG_BLOCK: begin
									if (draw_counter < 4'b1000) begin
										x = bl_wr_x + draw_counter[2:0];
                              y = bl_wr_y + draw_counter[4:3];
                              draw_counter = draw_counter + 1'b1;
                              colour = bl_wr_colour;
                           end
                           else begin
										draw_counter= 8'b00000000;
                              if(wrong_input) state = START;
                              else state = UPDATE_BLOCK_ERASE;
                           end
                        end

                        // UPDATE AND ERASE TOP-LEVEL BLOCK AT SOURCE

                        UPDATE_BLOCK_ERASE: begin
									if(source == 2'd1) begin
										bl_erase_x = x1;
										if(piecenum1 == 2'd0) bl_erase_y = y1;
										if(piecenum1 == 2'd1) bl_erase_y = y2;
										if(piecenum1 == 2'd2) bl_erase_y = y3;
									end

                           if(source == 2'd2) begin
										bl_erase_x = x2;
										if(piecenum2 == 2'd0) bl_erase_y = y1;
										if(piecenum2 == 2'd1) bl_erase_y = y2;
										if(piecenum2 == 2'd2) bl_erase_y = y3;
									end

                           if(source == 2'd3) begin
										bl_erase_x = x3;
										if(piecenum3 == 2'd0) bl_erase_y = y1;
										if(piecenum3 == 2'd1) bl_erase_y = y2;
										if(piecenum3 == 2'd2) bl_erase_y = y3;
									end

									//NEXT STATE
                           state = DRAW_BLOCK_ERASE;
                        end

                        DRAW_BLOCK_ERASE: begin
									if (draw_counter < 6'b100000) begin
										x = bl_erase_x + draw_counter[4:0];
                              y = bl_erase_y + draw_counter[6:5];
                            	draw_counter = draw_counter + 1'b1;
                              colour = bl_erase_colour;
									end
                           else begin
										draw_counter= 8'b00000000;
                              state = state2;
                           end
								end

                        // MOVE BLOCK 1,2 OR 3 TO DESTINATION

                        //BLOCK 1

                        DRAW_BLOCK_1: begin
									if (draw_counter < 4'b1000) begin
										x = bl_1_x + draw_counter[2:0];
										y = bl_1_y + draw_counter[4:3];
										draw_counter = draw_counter + 1'b1;
										colour = 3'b001;
									end
									else begin
										draw_counter= 8'b00000000;
										state = START;
									end
								end

                        //BLOCK 2

                        DRAW_BLOCK_2: begin
									if (draw_counter < 5'b10000) begin
										x = bl_2_x + draw_counter[3:0];
										y = bl_2_y + draw_counter[5:4];
										draw_counter = draw_counter + 1'b1;
										colour = 3'b001;
									end
									else begin
										draw_counter= 8'b00000000;
										state = START;
									end
                        end
								
								//BLOCK 3
								
                      DRAW_BLOCK_3: begin
									if(draw_counter < 6'b100000) begin
                              x = bl_3_x + draw_counter[4:0];
                              y = bl_3_y + draw_counter[6:5];
                              draw_counter = draw_counter + 1'b1;
										colour = 3'b001;
                           end
                           else begin
										draw_counter= 8'b00000000;
                              state = START;
                           end
                        end
								default :begin
									state = START;
								end
					endcase
        end
		  
endmodule

module hex_display(IN, OUT);
    input [3:0] IN;
	 output reg [6:0] OUT;
	 
	 always @(*)
	 begin
		case(IN[3:0])
			4'b0000: OUT = 7'b1000000;
			4'b0001: OUT = 7'b1111001;
			4'b0010: OUT = 7'b0100100;
			4'b0011: OUT = 7'b0110000;
			4'b0100: OUT = 7'b0011001;
			4'b0101: OUT = 7'b0010010;
			4'b0110: OUT = 7'b0000010;
			4'b0111: OUT = 7'b1111000;
			4'b1000: OUT = 7'b0000000;
			4'b1001: OUT = 7'b0011000;
			4'b1010: OUT = 7'b0001000;
			4'b1011: OUT = 7'b0000011;
			4'b1100: OUT = 7'b1000110;
			4'b1101: OUT = 7'b0100001;
			4'b1110: OUT = 7'b0000110;
			4'b1111: OUT = 7'b0001110;
			default: OUT = 7'b0111111;
		endcase

	end
endmodule


module comparator(A, B, OUT);
	input[1:0] A;
	input[1:0] B;
	output OUT;
	
	assign OUT = A[1]&(~B[1])|
					(
						(
							(A[1]&B[1])|
							((~A[1])&(~B[1]))
						)&
						(A[0]&(~B[0]))
					);

endmodule
