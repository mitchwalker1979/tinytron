module Subclock(
    input wire clock,
    output wire tick_out
    );

parameter FREQUENCY = 50_000_000;
parameter CLOCK_FREQUENCY = 50_000_00;

// The subclock will cycle *twice* per CLOCKS_PER_TICK (low, then hi).
localparam TRIP = CLOCK_FREQUENCY / FREQUENCY / 2;

reg [31:0] counter = 0;
reg tick = 0;

always @(posedge clock) begin
    counter <= counter + 1;
    if(counter > TRIP) begin
        counter <= 0;
        tick = ~tick;
        end
    end

assign tick_out = tick;
endmodule
