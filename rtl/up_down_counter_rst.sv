// UP/Down Counter with Reset
//
//PARAMETERS:
// MAX: Maximum count value (default: 2)
// WIDTH: Bit width of the count output (default: 2)
//
// PORTS:
// clk: Clock signal for synchronizing the counter
// rst: Active-high reset signal to initialize the counter to 0
// enable: When high, the counter updates on the rising edge of 'clk'
// up: When high, the counter counts up; when low, it counts down
// count: output the current count value
//

`timescale 1ns / 1ps

module up_down_counter_rst #(
    parameter int MAX   = 2,
    parameter int WIDTH = 2
) (
    input logic clk,
    input logic rst,
    input logic enable,
    input logic up,
    output logic [WIDTH -1:0] count
);

  initial count = WIDTH'(0);
  logic [WIDTH -1:0] next_count;
  localparam logic [WIDTH -1:0] Max = WIDTH'(MAX);
  localparam logic [WIDTH -1:0] One = WIDTH'(1);


  always_comb
    if (rst) next_count = 0;
    else if (enable) begin
      if (up) begin
        if (count == Max) next_count = 0;
        else next_count = count + One;
      end else begin
        if (count == 0) next_count = Max;
        else next_count = count - One;
      end
    end else next_count = count;

  always_ff @(posedge clk) count <= next_count;

endmodule
