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

  initial count = WIDTH'(0);

  always_comb
    if (up) begin
      if (count < Max) next_count = count + WIDTH'(1);
      else next_count = 0;
    end else begin
      if (count > 0) next_count = count - WIDTH'(1);
      else next_count = Max;
    end

  always_ff @(posedge clk) if (enable) count <= next_count;

endmodule
