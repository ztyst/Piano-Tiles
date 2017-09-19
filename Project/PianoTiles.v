`timescale 1ns / 1ns // `timescale time_unit/time_precision

module PianoTiles
	(
		CLOCK_50,						//	On Board 50 MHz 
		KEY, 
		SW,
		HEX0,
		HEX1,
		// Your inputs and outputs here
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B,   						//	VGA Blue[9:0]
		PS2_DAT,
		PS2_CLK
	);
	
	input PS2_DAT;
	input PS2_CLK;
	input			CLOCK_50;				//	50 MHz
	input [3:0] KEY;//This input is used to click on each column
	input [9:0] SW;//Input for reset
	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B; 	//	VGA Blue[9:0]
	output   [6:0] HEX0;
	output   [6:0] HEX1;
	
	wire resetn;
	assign resetn = over;//This is the input to resetn
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.

	reg [2:0] colour;
	reg [7:0] x;
	reg [7:0] y;
	reg writeEn;
	wire writeEn1, writeEn2, writeEn3, writeEn4;
	wire [3:0] shift_r;

	wire [119:0] lut1, lut2, lut3, lut4;
	wire [119:0] lut5, lut6, lut7, lut8; 
	wire [31:0] out1, out2, out3, out4;
	reg [1:0] selectColumn;
	reg draw_column1, draw_column2, draw_column3, draw_column4;
	wire [3:0] c_out1;
	wire [3:0] set;
	wire over1 ,over2, over3, over4;
	reg over;

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(~resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
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
		
		wire [7:0] outCode1, outCode2, outCode3, outCode4;
		wire v1, v2, v3, v4;
		reg signal1 = 1'b0;
		reg signal2 = 1'b0;
		reg signal3 = 1'b0;
		reg signal4 = 1'b0;
		wire make1, make2, make3, make4;
		
					//16 1E 26 25	
		keyboard_press_driver kb1(.CLOCK_50(CLOCK_50),
										 .PS2_DAT(PS2_DAT),
										 .PS2_CLK(PS2_CLK),
										 .reset(SW[8]),
										 .outCode(outCode1),
										 .valid(v1),
										 .makeBreak(make1));
					 

		reg			[7:0]	last_data_received1;

		always @(posedge CLOCK_50)
		begin
			if (SW[5] == 1'b1)
				last_data_received1 <= 8'h00;
			else if (make1== 1'b1)
				last_data_received1 <= outCode1;
			else if (make1 == 1'b0)
				last_data_received1 <= 8'b0;
			end
			
		always@(posedge CLOCK_50) 
		if (last_data_received1 == 8'h16)
		begin 
			signal1 <= 1'b1;
		end
		else
		begin 
			signal1 <=1'b0;
		end
		
		
		
		keyboard_press_driver kb2(.CLOCK_50(CLOCK_50),
										 .PS2_DAT(PS2_DAT),
										 .PS2_CLK(PS2_CLK),
										 .reset(SW[8]),
										 .outCode(outCode2),
										 .valid(v2),
										 .makeBreak(make2));
					 

		reg			[7:0]	last_data_received2;

		always @(posedge CLOCK_50)
		begin
			if (SW[5] == 1'b1)
				last_data_received2 <= 8'h00;
			else if (make2== 1'b1)
				last_data_received2 <= outCode2;
			else if (make2 == 1'b0)
				last_data_received2 <= 8'b0;
			end
			
		always@(posedge CLOCK_50) 
		if (last_data_received2 == 8'h1E)
		begin 
			signal2 <= 1'b1;
		end
		else
		begin 
			signal2 <=1'b0;
		end

		
		keyboard_press_driver kb3(.CLOCK_50(CLOCK_50),
										 .PS2_DAT(PS2_DAT),
										 .PS2_CLK(PS2_CLK),
										 .reset(SW[8]),
										 .outCode(outCode3),
										 .valid(v3),
										 .makeBreak(make3));
					 

		reg			[7:0]	last_data_received3;

		always @(posedge CLOCK_50)
		begin
			if (SW[5] == 1'b1)
				last_data_received3 <= 8'h00;
			else if (make3== 1'b1)
				last_data_received3 <= outCode3;
			else if (make3 == 1'b0)
				last_data_received3 <= 8'b0;
			end
			
		always@(posedge CLOCK_50) 
		if (last_data_received3 == 8'h26)
		begin 
			signal3 <= 1'b1;
		end
		else
		begin 
			signal3 <=1'b0;
		end
		
		
		keyboard_press_driver kb4(.CLOCK_50(CLOCK_50),
										 .PS2_DAT(PS2_DAT),
										 .PS2_CLK(PS2_CLK),
										 .reset(SW[8]),
										 .outCode(outCode4),
										 .valid(v4),
										 .makeBreak(make4));
					 

		reg			[7:0]	last_data_received4;

		always @(posedge CLOCK_50)
		begin
			if (SW[5] == 1'b1)
				last_data_received4 <= 8'h00;
			else if (make4== 1'b1)
				last_data_received4 <= outCode4;
			else if (make4 == 1'b0)
				last_data_received4 <= 8'b0;
			end
			
		always@(posedge CLOCK_50) 
		if (last_data_received4 == 8'h25)
		begin 
			signal4 <= 1'b1;
		end
		else
		begin 
			signal4 <=1'b0;
		end
		

		
		
		
		ratedivider c1(.Clock(CLOCK_50), 
					  .resetn(SW[0]), 
					  .enable(c_out1)); 

			  
		random_generator r1 (.out(out1), 
								   .CLOCK_50(CLOCK_50));
						
		LUT l1(.CLOCK_50(CLOCK_50),
							.random(out1[0]),
							.resetn(SW[0]), 
							.shift_down(Shift[0]),
							.lut(lut1),
							.in(signal1),
							.over(over1));
		
		draw t1(.Clock(CLOCK_50), 
				  .start(draw_column1), 
				  .writeEn(writeEn1), 
				  .shift_r(shift_r[0]), 
				  .set(set[0]), 
				  .resetn(SW[0]), 
				  .lut(lut1), 
				  .lut_row(y1_init),  
				  .delete(done[0]));
		
		datapath d1(.Clock(CLOCK_50),
						.shift_r(shift_r[0]),
						.resetn(resetn),
						.colour(colour1),
						.x_init(x1_init), 
						.y_init(y1_init), 
						.set(set[0]), 
						.clear(clear[0]),
						.x_out(x1), 
						.y_out(y1));

		
		
		random_generator r2 (.out(out2),
									.CLOCK_50(CLOCK_50));
						
		LUT l2(.CLOCK_50(CLOCK_50), 
							.random(out2[1]),
							.resetn(SW[0]), 
							.shift_down(Shift[1]),
							.lut(lut2),
							.in(signal2),
							.over(over2));
		
		draw t2(.Clock(CLOCK_50),
				  .start(draw_column2),
				  .writeEn(writeEn2), 
				  .shift_r(shift_r[1]),
				  .set(set[1]), 
				  .resetn(SW[0]),
				  .lut(lut2),
				  .lut_row(y2_init),
				  .delete(done[1]));
				  
		datapath d2(.Clock(CLOCK_50), 
						.shift_r(shift_r[1]),
						.resetn(resetn),  
						.colour(colour2), 
						.x_init(x2_init), 
						.y_init(y2_init), 
						.set(set[1]),
						.clear(clear[1]), 
						.x_out(x2), 
						.y_out(y2));
		  
		random_generator r3 (.out(out3),
									.CLOCK_50(CLOCK_50));
						
		LUT l3(.CLOCK_50(CLOCK_50), 
							.random(out3[1]), 
							.resetn(SW[0]), 
							.shift_down(Shift[2]), 
							.lut(lut3),
							.in(signal3),
							.over(over3));
		
		draw t3(.Clock(CLOCK_50), 
				  .start(draw_column3), 
				  .writeEn(writeEn3),
				  .shift_r(shift_r[2]), 
				  .set(set[2]),
				  .resetn(SW[0]),
				  .lut(lut3),
				  .lut_row(y3_init),
				  .delete(done[2]));
		
		datapath d3(.Clock(CLOCK_50),
						.shift_r(shift_r[2]), 
						.resetn(resetn), 
						.colour(colour3),
						.x_init(x3_init), 
						.y_init(y3_init), 
						.set(set[2]), 
						.clear(clear[2]), 
						.x_out(x3),
						.y_out(y3));
	  
		random_generator r4 (.out(out4), 
									.CLOCK_50(CLOCK_50));
						
		LUT l4(.CLOCK_50(CLOCK_50),
							.random(out4[1]),
							.resetn(SW[0]), 
							.shift_down(Shift[3]),
							.lut(lut4),
							.in(signal4),
							.over(over4));
							
		draw t4(.Clock(CLOCK_50), 
				  .start(draw_column4), 
				  .writeEn(writeEn4), 
				  .shift_r(shift_r[3]),
				  .set(set[3]),
				  .resetn(SW[0]),
				  .lut(lut4), 
				  .lut_row(y4_init), 
				  .delete(done[3]));
				  
		datapath d4(.Clock(CLOCK_50),
						.shift_r(shift_r[3]),
						.resetn(resetn), 
						.colour(colour4), 
						.x_init(x4_init),
						.y_init(y4_init),
						.set(set[3]),
						.clear(clear[3]), 
						.x_out(x4), 
						.y_out(y4) );
						
						
						
		always@(posedge CLOCK_50)
		begin 
			if ((over1 == 1'b1)^(over2 == 1'b1)^(over3 == 1'b1)^(over4 == 1'b1))
				over <= 1'b1;
			else 
				over <= 1'b0;
		end

	
		
		wire [3:0] done;
		reg [3:0] Shift, clear;
		reg [9:0] current, next;
		wire [7:0] x1, x2, x3, x4;
		wire [7:0] y1, y2, y3, y4;
		wire [7:0] y1_init, y2_init, y3_init, y4_init;
		wire [2:0] colour1, colour2, colour3, colour4;

		wire [7:0] x1_init = 8'd05;
		wire [7:0] x2_init = 8'd45;
		wire [7:0] x3_init = 8'd85;
		wire [7:0] x4_init = 8'd125;


		always@(*)
		begin 
			if (selectColumn == 2'b00)
			begin
				x = x1;
				y = y1;
				colour = colour1;
				writeEn = writeEn1;
			end
			if (selectColumn == 2'b01)
			begin
				x = x2;
				y = y2;
				colour = colour2;
				writeEn = writeEn2;
			end
			if (selectColumn == 2'b10)
			begin
				x = x3;
				y = y3;
				colour = colour3;
				writeEn = writeEn3;
			end
			if (selectColumn == 2'b11)
			begin
				x = x4;
				y = y4;
				colour = colour4;
				writeEn = writeEn4;
			end
		end 
		localparam  
					  
					  COL1DRAW = 10'd0,
					  COL1WAIT = 10'd1,
					  COL2DRAW = 10'd2,
					  COL2WAIT = 10'd3,
					  COL3DRAW = 10'd4,
					  COL3WAIT = 10'd5,
					  COL4DRAW = 10'd6,
					  COL4WAIT = 10'd7,
					  COL1LUT = 10'd8,
					  COL2LUT = 10'd9,
					  COL3LUT = 10'd10,
					  COL4LUT = 10'd11,
					  COL1CLEAR = 10'd12,
					  connection = 10'd13,
					  COL1CLEARWAIT = 10'd14,
					  COL2CLEAR = 10'd15,
					  COL2CLEARWAIT = 10'd16,
					  COL3CLEAR = 10'd17,
					  COL3CLEARWAIT = 10'd18,
					  COL4CLEAR = 10'd19,
					  COL4CLEARWAIT = 10'd20;
					  

		always@(*)
		begin
			case(current)
					  
					  COL1LUT: begin next = COL2LUT; end
					  COL2LUT: begin next = COL3LUT; end
					  COL3LUT: begin next = COL4LUT; end
					  COL4LUT: begin next = COL1DRAW; end
					  COL1DRAW: begin next = COL1WAIT; end
					  COL1WAIT: begin next = done[0] ? COL2DRAW : COL1WAIT; end
					  COL2DRAW: begin next = COL2WAIT; end
					  COL2WAIT: begin next = done[1] ? COL3DRAW : COL2WAIT; end
					  COL3DRAW: begin next = COL3WAIT; end
					  COL3WAIT: begin next = done[2] ? COL4DRAW : COL3WAIT; end
					  COL4DRAW: begin next = COL4WAIT; end 
					  COL4WAIT: begin next = done[3] ? connection : COL4WAIT; end
					  
					  connection: begin next = c_out1 ? COL1CLEAR : connection; end
					  
					  COL1CLEAR: begin next = COL1CLEARWAIT; end
					  COL1CLEARWAIT: begin next = done[0] ? COL2CLEAR : COL1CLEARWAIT; end
					  COL2CLEAR: begin next = COL2CLEARWAIT; end
					  COL2CLEARWAIT: begin next = done[1] ? COL3CLEAR : COL2CLEARWAIT; end
					  COL3CLEAR: begin next = COL3CLEARWAIT; end
					  COL3CLEARWAIT: begin next = done[2] ? COL4CLEAR : COL3CLEARWAIT; end
					  COL4CLEAR: begin next = COL4CLEARWAIT; end
					  COL4CLEARWAIT: begin next = done[3] ? COL1LUT : COL4CLEARWAIT; end

					  default: begin next = connection; end
			endcase
		end
		

		always@(posedge CLOCK_50)
		begin

		Shift[3:0] = 4'd0; clear[3:0] = 4'd0; selectColumn[1:0] = 2'd0;
		draw_column1 = 1'b0;
		draw_column2 = 1'b0;
		draw_column3 = 1'b0;
		draw_column4 = 1'b0;
			case(current)
				connection: 
					begin 
						Shift[3:0] = 4'd0; clear[3:0] = 4'd0; 
						draw_column1 = 1'b0;
						draw_column2 = 1'b0;
						draw_column3 = 1'b0;
						draw_column4 = 1'b0;
					end
				
				COL1LUT: begin Shift[0] = 1'b1; end
				COL2LUT: begin Shift[1] = 1'b1; end
				COL3LUT: begin Shift[2] = 1'b1; end
				COL4LUT: begin Shift[3] = 1'b1; end
				

				COL1DRAW: begin draw_column1 = 1'b1; selectColumn = 2'b00; end

				COL1WAIT: begin draw_column1 = 1'b0; selectColumn = 2'b00; end
				COL2DRAW: begin draw_column2 = 1'b1; selectColumn = 2'b01; end
				COL2WAIT: begin draw_column2 = 1'b0; selectColumn = 2'b01; end
				COL3DRAW: begin draw_column3 = 1'b1; selectColumn = 2'b10; end
				COL3WAIT: begin draw_column3 = 1'b0; selectColumn = 2'b10; end
				COL4DRAW: begin draw_column4 = 1'b1; selectColumn = 2'b11; end
				COL4WAIT: begin draw_column4 = 1'b0; selectColumn = 2'b11; end
				

				COL1CLEAR: begin clear[0] = 1'b1; draw_column1 = 1'b1; selectColumn = 2'b00; end
				COL1CLEARWAIT: begin clear[0] = 1'b1; draw_column1 = 1'b0; selectColumn = 2'b00; end
				COL2CLEAR: begin clear[1] = 1'b1; draw_column2 = 1'b1; selectColumn = 2'b01; end
				COL2CLEARWAIT: begin clear[1] = 1'b1; draw_column2 = 1'b0; selectColumn = 2'b01; end
				COL3CLEAR: begin clear[2] = 1'b1; draw_column3 = 1'b1; selectColumn = 2'b10; end
				COL3CLEARWAIT: begin clear[2] = 1'b1; draw_column3 = 1'b0; selectColumn = 2'b10; end
				COL4CLEAR: begin clear[3] = 1'b1; draw_column4 = 1'b1; selectColumn = 2'b11; end
				COL4CLEARWAIT: begin clear[3] = 1'b1; draw_column4 = 1'b0; selectColumn = 2'b11; end
				
			endcase
		end
		

		always@(posedge CLOCK_50)
		begin
		current <= next;
		end
		
endmodule


module draw (Clock, start, resetn, lut, writeEn, shift_r, set, lut_row, delete);
	input Clock, start, resetn;
	input [119:0] lut;
	output reg writeEn, shift_r, set;
	output reg [7:0] lut_row;
	output reg delete;
	reg [3:0] current;
	reg [3:0] next;
	reg [4:0] count;
	
	localparam WAIT = 4'd0,
				  CHECK = 4'd1,
				  DRAW = 4'd2,
				  NEXT_LUT = 4'd3, 
				  FINISH = 4'd4,
				  SET = 4'd5;


	always@(*)
	begin
		case (current)
			WAIT: 
				begin 
					next = start ? CHECK : WAIT; 
				end
			CHECK: 
				begin 
					if(lut_row < 8'd120)
						begin
							if(lut[lut_row] == 1'b1) 
								next = DRAW;
							else
								next = NEXT_LUT; 
							end
					else 
						begin
							next = FINISH;
						end
				end
			SET:
				begin 
					next = DRAW;
				end
			DRAW: 
				begin 
					if (count == 8'd30)
						next = NEXT_LUT;
					else 
						next = DRAW; 
				end
			NEXT_LUT: 
				begin 
					next = CHECK; 
				end
			FINISH: 
				begin 
					next = WAIT; 
				end 
			default: 
				begin 
					next = WAIT;
				end
		endcase
	end
	

	always@(posedge Clock)
   begin
		writeEn = 1'b0;	
		set = 1'b0;
		shift_r = 1'b0;  
		delete = 1'b0;
        case(current)
					WAIT: 
					begin 
						delete = 1'b0;
						lut_row = 7'd0;
						count = 5'd0;
					end
					SET:
					begin 
						set = 1'b1;
					end
					DRAW: 
					begin 
						writeEn = 1'b1;
						count = count + 1;
						shift_r = 1'b1;
					end
					NEXT_LUT:
					begin 
						lut_row = lut_row + 1; 
						count = 5'd0; 
						set = 1'b1; 
					end
					FINISH: 
					begin 
						delete = 1'b1; 
						lut_row = 7'd0; 
					end
		  endcase
	end 
	
	always@(posedge Clock)
    begin
		current <= next;
    end
endmodule


module ratedivider(Clock, resetn, enable);
	input Clock, resetn;
	output reg enable;
	reg [29:0] count;

	wire [29:0] time_c1 = 30'd2000000;
	

	always@(posedge Clock)
	begin
			if(~resetn) begin
				count = 30'd0;
				enable = 1'b0; end
			else begin
				if(count == time_c1) begin
					enable = 1'b1;
					count = 30'd0; end
				else begin
					count = count + 1;
					enable = 1'b0; end
			end
	end
	
endmodule


module datapath(x_init, y_init,Clock, shift_r, resetn, set, clear, x_out, y_out, colour);
	 input Clock, shift_r, resetn, set, clear;
	 input [7:0] x_init;
	 input [7:0] y_init;
	 output reg [7:0] x_out;
	 output reg [7:0] y_out;
	 output reg [2:0] colour;


	 always@(posedge Clock)
		begin
				if(shift_r)
					x_out = x_out + 1'b1;
				if(set)
					begin 
						x_out = x_init; 
						y_out = y_init; 
					end
				if(clear)
					colour = 3'b000;
				if(~clear)
					colour = 3'b111;
 
		end
endmodule


module LUT (CLOCK_50, shift_down, random, resetn, lut, in, over);
	input CLOCK_50, shift_down, random, resetn, in;
	output reg [119:0] lut;
	reg [119:0] temp_lut;
	output reg over = 1'b0;
	reg [5:0] length;
	reg w1;
	
	localparam size = 10'd119;
	
	always@(posedge shift_down)
	begin
		if(~resetn)
			length <= 5'd0;
		else if(length == 5'd31)
			length <= 5'd0;
		else 
			length <= length + 1;
	end
	

	always@(posedge shift_down)
	begin
		if(~resetn) begin
			lut = 120'd0;
			end
		else if(length == 5'd30) 
		begin
			integer i;
			for(i = 0; i<30; i = i + 1)begin
					lut[i] = random;
				end
			for(i = 0; i<30; i = i + 1)begin
					temp_lut[i] = random;
				end
		end
		else begin
			lut = lut << 1;
			temp_lut = temp_lut <<1;
		end
		
		
		if ((in == 1'b1) &&(lut[size] == 1'b1))
			begin
				lut[size] = 5'd0;
				if(lut[size - 5'd1] == 1'b1)
				begin
					lut[size - 5'd1] = 1'b0;
					if(lut[size - 5'd2] == 1'b1)
					begin
						lut[size - 5'd2] = 1'b0;
						if(lut[size - 5'd3] == 1'b1)
						begin
							lut[size - 5'd3] = 1'b0;
							if(lut[size - 5'd4] == 1'b1)
							begin
								lut[size - 5'd4] = 1'b0;
								if(lut[size - 5'd5] == 1'b1)
								begin
									lut[size - 5'd5] = 1'b0;
									if(lut[size - 5'd6] == 1'b1)
									begin
										lut[size - 5'd6] = 1'b0;
										if(lut[size - 5'd7] == 1'b1)
										begin
											lut[size - 5'd7] = 1'b0;
											if(lut[size - 5'd8] == 1'b1)
											begin
												lut[size - 5'd8] = 1'b0;
												if(lut[size - 5'd9] == 1'b1)
												begin
													lut[size - 5'd9] = 1'b0;
													if(lut[size - 5'd10] == 1'b1)
													begin
														lut[size - 5'd10] = 1'b0;
														if(lut[size - 5'd11] == 1'b1)
														begin
															lut[size - 5'd11] = 1'b0;
															if(lut[size - 5'd12] == 1'b1)
															begin
																lut[size - 5'd12] = 1'b0;
																if(lut[size - 5'd13] == 1'b1)
																begin
																	lut[size - 5'd13] = 1'b0;
																	if(lut[size - 5'd14] == 1'b1)
																	begin
																		lut[size - 5'd14] = 1'b0;
																		if(lut[size - 5'd15] == 1'b1)
																		begin
																			lut[size - 5'd15] = 1'b0;
																			if(lut[size - 5'd16] == 1'b1)
																			begin
																				lut[size - 5'd16] = 1'b0;
																				if(lut[size - 5'd17] == 1'b1)
																				begin
																					lut[size - 5'd17] = 1'b0;
																					if(lut[size - 5'd18] == 1'b1)
																					begin
																						lut[size - 5'd18] = 1'b0;
																						if(lut[size - 5'd19] == 1'b1)
																						begin
																							lut[size - 5'd19] = 1'b0;
																							if(lut[size - 5'd20] == 1'b1)
																							begin
																								lut[size - 5'd20] = 1'b0;
																								if(lut[size - 5'd21] == 1'b1)
																								begin
																									lut[size - 5'd21] = 1'b0;
																									if(lut[size - 5'd22] == 1'b1)
																									begin
																										lut[size - 5'd22] = 1'b0;
																										if(lut[size - 5'd23] == 1'b1)
																										begin
																											lut[size - 5'd23] = 1'b0;
																											if(lut[size - 5'd24] == 1'b1)
																											begin
																												lut[size - 5'd24] = 1'b0;
																												if(lut[size - 5'd25] == 1'b1)
																												begin
																													lut[size - 5'd25] = 1'b0;
																													if(lut[size - 5'd26] == 1'b1)
																													begin
																														lut[size - 5'd26] = 1'b0;
																														if(lut[size - 5'd27] == 1'b1)
																														begin
																															lut[size - 5'd27] = 1'b0;
																															if(lut[size - 5'd28] == 1'b1)
																															begin
																																lut[size - 5'd28] = 1'b0;
																																if(lut[size - 5'd29] == 1'b1)
																																begin
																																	lut[size - 5'd29] = 1'b0;
																																	end
																															 end
																														end
																													end
																												end
																											end
																										end
																									end
																								end
																							end
																						end
																					end
																				end
																			end
																		end
																	end
																end
															end
														end
													end
												end
											end
										end
									end
								end
							end
						end
					end
				end
			end
			if (((in == 1'b1) &&(temp_lut[size] == 1'b0)))
				begin
					over <= 1'b1;
				end
	end

endmodule 


module random_generator (out, CLOCK_50);
  output reg [9:0] out;
  input CLOCK_50;
  reg [19:0] random;
  initial random = ~(20'b0);
  reg [19:0] random_next;
  wire feedback = ~((random[13] ^ random[9] ^ random[3] ^ random[10]) ^ 
							(random[8] ^ random[3] ^ random[4]^ random[9]) ^ 
							(random[16] ^ random[7] ^ random[6] ^ random[0]));


	always @(posedge CLOCK_50)
	begin
			random <= random_next;
			out = random[9:0];
			random_next = {out[9:0],random[9:0], feedback};
  end
endmodule


module hex_decoder(hex_digit, segments);
    input [3:0] hex_digit;
    output reg [6:0] segments;
   
    always @(*)
        case (hex_digit)
            4'h0: segments = 7'b100_0000;
            4'h1: segments = 7'b111_1001;
            4'h2: segments = 7'b010_0100;
            4'h3: segments = 7'b011_0000;
            4'h4: segments = 7'b001_1001;
            4'h5: segments = 7'b001_0010;
            4'h6: segments = 7'b000_0010;
            4'h7: segments = 7'b111_1000;
            4'h8: segments = 7'b000_0000;
            4'h9: segments = 7'b001_1000;
            4'hA: segments = 7'b000_1000;
            4'hB: segments = 7'b000_0011;
            4'hC: segments = 7'b100_0110;
            4'hD: segments = 7'b010_0001;
            4'hE: segments = 7'b000_0110;
            4'hF: segments = 7'b000_1110;   
            default: segments = 7'h7f;
        endcase
endmodule
