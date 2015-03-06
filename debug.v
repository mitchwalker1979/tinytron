// Displays value in 16-bit register "value" as hex on 4-digit, 7-segment LED display.
module Debug(
    input clock,
    input wire [15:0] value,
    output [0:3] digit,
    output [0:7] segment
    );

parameter PERIOD = 50_000;
parameter BRIGHTNESS = 8'hff;

reg [15:0] counter = 0;
reg [ 1:0] column  = 0;
reg [ 7:0] pattern = 0;
wire pwm;

Pwm x(clock, BRIGHTNESS, pwm);

always @(posedge clock)
begin
    counter = counter + 1;
    if(counter >= PERIOD)
    begin
        counter = 0;
        column = column + 1;
        // Express the 4 bits that correspond to this column as a hex digit (0-F).
        case(value >> (column * 4) & 4'b1111)
        //case(column)
             0: pattern = 8'b11111100;
             1: pattern = 8'b01100000;
             2: pattern = 8'b11011010;
             3: pattern = 8'b11110010;
             4: pattern = 8'b01100110;
             5: pattern = 8'b10110110;
             6: pattern = 8'b10111110;
             7: pattern = 8'b11100000;
             8: pattern = 8'b11111110;
             9: pattern = 8'b11100110;
            10: pattern = 8'b11101110;
            11: pattern = 8'b00111110;
            12: pattern = 8'b10011100;
            13: pattern = 8'b01111010;
            14: pattern = 8'b10011110;
            15: pattern = 8'b10001110;
            default: pattern = 8'b00000001;
            endcase
        if(column > 3) column = 0;
        end
    end

assign digit = ~((1 & pwm) << column);
assign segment = ~pattern;
endmodule
