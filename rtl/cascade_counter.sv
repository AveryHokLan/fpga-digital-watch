

`timescale 1ns / 1ps

module cascade_counter #(
    parameter int N2 = 3,
    parameter int N1 = 4,
    parameter int N0 = 5,
    // Output port widths
    parameter int W2 = 2,
    parameter int W1 = 2,
    parameter int W0 = 3
) (
    input logic clk,
    input logic rst,
    input logic enable,
    output logic [W2 -1:0] count2,
    output logic [W1 -1:0] count1,
    output logic [W0 -1:0] count0
);

  logic count0_rollover;
  logic count1_rollover;

  assign count0_rollover = (count0 == W0'(N0 - 1));
  assign count1_rollover = (count1 == W1'(N1 - 1)) && count0_rollover;

  mod_n_counter #(
      .N(N0),
      .WIDTH(W0)
  ) u_counter0 (
      .clk(clk),
      .rst(rst),
      .enable(enable),
      .count(count0)
  );

  mod_n_counter #(
      .N(N1),
      .WIDTH(W1)
  ) u_counter1 (
      .clk(clk),
      .rst(rst),
      .enable(enable && count0_rollover),
      .count(count1)
  );

  mod_n_counter #(
      .N(N2),
      .WIDTH(W2)
  ) u_counter2 (
      .clk(clk),
      .rst(rst),
      .enable(enable && count1_rollover),
      .count(count2)
  );

endmodule
