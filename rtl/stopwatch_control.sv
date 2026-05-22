`timescale 1ns / 1ps

module stopwatch_control (
    input  logic clk,
    input  logic rise_start_stop,
    input  logic rise_lap,
    output logic counter_rst,
    output logic counter_enable,
    output logic lap_hold
);

  initial begin
    counter_rst    = 1'b0;
    counter_enable = 1'b0;
    lap_hold       = 1'b0;
  end

  logic next_counter_rst;
  logic next_counter_enable;
  logic next_lap_hold;

  always_ff @(posedge clk) begin
    counter_rst    <= next_counter_rst;
    counter_enable <= next_counter_enable;
    lap_hold       <= next_lap_hold;
  end

  logic start_stop_only;
  logic lap_only;

  assign start_stop_only = rise_start_stop && !rise_lap;
  assign lap_only = !rise_start_stop && rise_lap;

  //next state logic
  assign next_counter_rst = (lap_only && !counter_enable && !lap_hold) ? 1'b1 : 1'b0;

  assign next_counter_enable = start_stop_only ? ~counter_enable : counter_enable;

  always_comb begin
    next_lap_hold = lap_hold;

    if (lap_only && counter_enable) begin
      next_lap_hold = ~lap_hold;
    end
  end



endmodule
