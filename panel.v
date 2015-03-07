`timescale 1ns / 1ps
module Panel(
    input clock,
    input [15:0] write_address,
    input [15:0] write_value,
    input we,
    output oe,
    output stb,
    output r1, g1, b1,
    output r2, g2, b2,
    output a, b, c, d,
    output panel_clock
    );

parameter HEIGHT = 16;
parameter WIDTH  = 32;
parameter RATE   = 10_000_000;

//wire pwm;
//Pwm p(clock, switch, pwm);
assign oe = 0;

reg        active       = 0;
reg        latch        = 0;
reg        red          = 0;
reg        green        = 0;
reg        blue         = 0;
reg  [6:0] column       = 0;
reg  [4:0] row          = 0;
reg  [4:0] actual_row   = 0;
reg  [8:0] frame        = 0;
reg [15:0] color        = 0;
reg  [7:0] red8         = 0;
reg  [7:0] green8       = 0;
reg  [7:0] blue8        = 0;

reg  [15:0] read_address = 0;
wire [15:0] read_value;

Ram_16_12288 r(clock, we, write_address, write_value, clock, read_address, read_value);

// Drive panel with 25MHz subclock.
// Hardware fails if driven faster.
Subclock #(RATE) c1(clock, panel_clock);

// Make assignment syncronous to unfuck this.
always @(posedge panel_clock) begin
    if(actual_row >= HEIGHT - 1) row = 0;
    else row = actual_row + 1;
    // Set the latch at the start of the row, so we don't see the pixels as they flow in.
    if(column == 0) begin
        latch = 0;
        end
    read_address = actual_row * WIDTH + column + 1;
    color = read_value;

    // Adjust color lines for (row, column).
    
    /*
    if(color[:16] >= frame) red = 1;
    else red = 0;
    if(color[15:8] >= frame) green = 1;
    else green = 0;
    if(color[7:0] >= frame) blue = 1;
    else blue = 0;
    */
    
    {red, green, blue} = color[2:0];
    column = column + 1;
    // We've finished clocking in one row.
    if(column >= WIDTH) begin
        column = 0;
        actual_row = actual_row + 1;
        if(actual_row >= HEIGHT) begin
            // New frame.
            frame = frame + 1;
            if(frame > 8'hff) frame = 0;
            actual_row = 0;
            end
        // A rising edge on the latch copies the pixels from the shift-register
        // to the output buffer, so we can see them while we shift in the next row.
        latch = 1;
        end
    
    /*
    color = read_value;
    read_address = actual_row * WIDTH + column;
    red = 0;
    green = 0;
    blue = |color;
   
    if (column >= WIDTH) begin
        latch = 1;
        actual_row = actual_row + 1;
        column = 0;
        end
    else begin
        latch = 0;
        column = column + 1;
        end

    if (actual_row >= HEIGHT) begin
        column = 0;
        actual_row = 0;
        read_address = 0;
        end
       */
    end


assign {d,c,b,a} = actual_row[3:0];
assign r1  = red;
assign g1  = green;
assign b1  = blue;
assign r2  = red;
assign g2  = green;
assign b2  = blue;
assign stb = latch;

/*
// Animation.
// Red.
wire red_c;
Subclock #(2) sc1(clock, red_c);
reg red_direction = 0;
always @(posedge red_c) begin
    if(red_direction) red8 = red8 + 1;
    else red8 = red8 - 1;
    if(red8 <= 0) red_direction = 1;
    else if(red8 >= 8'hff) red_direction = 0;
    end

// Green.
wire green_c;
Subclock #(3) sc2(clock, green_c);
reg green_direction = 0;
always @(posedge green_c) begin
    if(green_direction) green8 = green8 + 1;
    else green8 = green8 - 1;
    if(green8 <= 0) green_direction = 1;
    else if(green8 >= 8'hff) green_direction = 0;
    end

// Blue.
wire blue_c;
Subclock #(4) sc3(clock, blue_c);
reg blue_direction = 0;
always @(posedge blue_c) begin
    if(blue_direction) blue8 = blue8 + 1;
    else blue8 = blue8 - 1;
    if(blue8 <= 0) blue_direction = 1;
    else if(blue8 >= 8'hff) blue_direction = 0;
    end

// Merge 8-bit channel values into one 24-bit reg (for no good reason...)
always @(posedge clock) begin
    color = {red8, green8, blue8};
    end
*/
endmodule
