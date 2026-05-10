`timescale 1ns / 1ps

module hms_counter #(
    parameter int N_HOURS   = 24,
    parameter int N_MINUTES = 60,
    parameter int N_SECONDS = 60,

    //Output port widths
    parameter int W_HOURS   = 5,  // 0-24 needs 5 bits
    parameter int W_MINUTES = 6,  // 0-59 needs 6 bits
    parameter int W_SECONDS = 6   // 0-59 needs 6 bits
) (
    input logic clk,
    input logic enable,

    output logic [  W_HOURS-1:0] hours,
    output logic [W_MINUTES-1:0] minutes,
    output logic [W_SECONDS-1:0] seconds
);

  logic second_rollover;
  logic minute_rollover;

  localparam logic [W_MINUTES -1:0] MaxMinutes = W_MINUTES'(N_MINUTES - 1);
  localparam logic [W_SECONDS -1:0] MaxSeconds = W_SECONDS'(N_SECONDS - 1);

  assign second_rollover = (seconds == MaxSeconds);
  assign minute_rollover = (minutes == MaxMinutes) && second_rollover;


  up_down_counter #(
      .MAX  (N_SECONDS - 1),
      .WIDTH(W_SECONDS)
  ) u_second (
      .clk(clk),
      .enable(enable),
      .up(1'b1),
      .count(seconds)
  );

  up_down_counter #(
      .MAX  (N_MINUTES - 1),
      .WIDTH(W_MINUTES)
  ) u_minute (
      .clk(clk),
      .enable(enable && second_rollover),
      .up(1'b1),
      .count(minutes)
  );

  up_down_counter #(
      .MAX  (N_HOURS - 1),
      .WIDTH(W_HOURS)
  ) u_hour (
      .clk(clk),
      .enable(enable && minute_rollover),
      .up(1'b1),
      .count(hours)
  );

endmodule
