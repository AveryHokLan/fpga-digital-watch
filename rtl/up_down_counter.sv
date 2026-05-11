// up_down_counter counts up or down from 0 to MAX (inclusive) based on the 'up' signal.
// When 'enable' is high, the counter updates on the rising edge of 'clk'.
// The count wraps around when it reaches the limits (0 and MAX).
//
// Parameters:
// MAX - The maximum count value (inclusive). Default is 2.
// WIDTH - The bit width of the count output. Default is 2 (sufficient for counting up to 2).
//
// Ports:
// clk - The clock signal for synchronizing the counter.
// enable - When high, the counter updates on the rising edge of 'clk'.
// up - When high, the counter counts up; when low, it counts down.


`timescale 1ns / 1ps

module up_down_counter #(
    parameter int MAX   = 2,
    parameter int WIDTH = 2
) (
    input logic clk,
    input logic enable,
    input logic up,
    output logic [WIDTH-1:0] count
);
  logic [WIDTH-1:0] next_count;
  localparam logic [WIDTH-1:0] Max = WIDTH'(MAX);
  localparam logic [WIDTH-1:0] One = WIDTH'(1);

  initial count = WIDTH'(0);

  always_comb
    if (up) begin
      if (count == Max) next_count = 0;
      else next_count = count + One;
    end else begin
      if (count == 0) next_count = Max;
      else next_count = count - One;
    end

  always_ff @(posedge clk) if (enable) count <= next_count;

endmodule
