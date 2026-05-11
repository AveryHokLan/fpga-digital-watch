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

