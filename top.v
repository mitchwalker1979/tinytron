`timescale 1ns / 1ps
module top(
    input clock,
    input  [7:0] switch,
    input  [3:0] button,
    output [7:0] led,
    output [0:3] digit,
    output [0:7] segment,
    output oe,
    output stb,
    output r1, g1, b1,
    output r2, g2, b2,
    output a, b, c, d,
    output clk,
    input write_button,
    input rx,
    output tx
    );

// Nice to have.
reg [15:0] debug = 0;
Debug x(clock, debug, digit, segment);

reg [15:0] write_address = 0;
wire [15:0] write_value;
wire write_enable;
wire tx_enable;

reg [7:0] tx_data;
wire [7:0] rx_data;
wire uart_reset;
wire tx_ready;
wire rx_ready;
wire panel_oe;

Panel #(.HEIGHT(16), .WIDTH(32), .RATE(10_000_000))p(
    clock,
    write_address,
    write_value,
    write_enable,
    panel_oe,
    stb,
    r1, g1, b1,
    r2, g2, b2,
    a, b, c, d,
    clk
    );

Uart #(.BAUD_RATE(115200)) u(
    clock,
    tx,
    rx,
    tx_enable,
    uart_reset,
    tx_data,
    rx_data,
    tx_ready,
    rx_ready
    );

assign led = switch;
assign tx_ready = 0;
assign uart_reset = 0;
assign write_value = rx_data;
assign write_enable = rx_ready;
assign oe = switch[0] || panel_oe;


always @(negedge rx_ready) begin
    write_address = write_address + 1;
    if(write_address >= 16 * 32) begin
        write_address = 0;
        end
    debug = write_address;
    end
    

endmodule
