module Uart(
    input wire clock,
    output tx,
    input rx,
    input write_enable,
    input reset,
    input [7:0] tx_data,
    output wire [7:0] rx_data,
    output wire tx_ready,
    output reg rx_ready
    );

parameter BAUD_RATE  = 115200;
parameter CLOCK_RATE = 50_000_000;
parameter TIMESLICE  = CLOCK_RATE / BAUD_RATE;
parameter HALF_SLICE = TIMESLICE / 2;

localparam STOP  = 1'b1;
localparam START = 1'b0;

//
// TX
//
reg [12:0] tx_counter = 0;
reg  [9:0] frame      = 0; // 1 start, 8 data, 1 stop.
reg        tx_out     = 0;
// If any of the bits in the frame are set, we're still sending.
// Even if we're sending 0x00, the stop bit will be 1, and it's sent last, so
// |frame should work.
wire sending = |frame;
assign tx_ready = !sending;
assign tx = tx_out;

always @(posedge clock) begin
    tx_counter <= tx_counter + 1;
    // TX
    if(tx_counter >= TIMESLICE) begin
        tx_counter <= 0;
        if(sending) begin
            {frame, tx_out} <= {1'b0, frame};
            end
        else if(write_enable) begin
            // The frame is shifted out to the right, so consider the following from
            // right to left.
            frame <= {STOP, tx_data, START};
            end
        end
    end
//
// RX
//
reg [20:0] counter = 0;
reg [15:0] bit_counter = 0;
reg [8:0] buffer = 0;
reg receiving = 0;

assign rx_data[7:0] = buffer[8:1];

always @(posedge clock) begin
    if(rx == START && ~receiving) begin
        receiving <= 1;
        end
    if(receiving) begin
        counter <= counter + 1;
        end
    if(counter > TIMESLICE) begin
        counter <= 0;
        bit_counter <= bit_counter + 1;
        end
    if(counter == HALF_SLICE) begin
        buffer <= {rx, buffer[8:1]};
        end
    if(bit_counter == 9) begin
        receiving <= 0;
        bit_counter <= 0;
        rx_ready <= 1;
        end
    end
endmodule
