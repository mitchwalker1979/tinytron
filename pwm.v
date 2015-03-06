// Set wire PWM high power/255 * 100 % of the time.
// Assumes 50MHz oscillator.  1khz refresh rate.
module Pwm(
    input clock,
    input [7:0] power,
    output wire pwm
    );

parameter STEP_DELAY = 195; // t = 0.001s, clk = 5*10^7 Hz, p = clk * t = 5*10^4, sd = t / 256
parameter PERIOD = 50_000;

reg [15:0] counter = 0;
reg state = 0;

always @(posedge clock)
begin
    counter = counter + 1;
    if(counter <= power * STEP_DELAY) state = 1;
    else state = 0;
    if(counter >= PERIOD) counter = 0;
    end
assign pwm = state;
endmodule

