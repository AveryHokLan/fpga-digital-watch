// mod_n_counter - counts from 0 to N-1 and then wraps around to 0 on the next count.
//
// Parameters:
// N - The number of states in the counter (0 to N-1).
// WIDTH - The bit width of the count output.
//
// Ports:
// clk - The clock signal for synchronizing the counter.
// rst - The reset signal for the counter.
// enable - When high, the counter updates on the rising edge of 'clk'.
// count - The current count value.


`timescale 1ns / 1ps

module mod_n_counter #(
    parameter int N = 4,
    parameter int WIDTH = 2
) (
    input logic clk,
    input logic rst,
    input logic enable,
    output logic [WIDTH-1:0] count
);

  initial count = '0;
  logic [WIDTH-1:0] next_count;

  always_ff @(posedge clk) begin
    if (rst) begin
      count <= '0;
    end else if (enable) begin
      if (count == WIDTH'(N - 1)) begin
        count <= '0;
      end else begin
        count <= next_count;
      end
    end
  end

  always_comb begin
    next_count = count + 1;
  end

endmodule

